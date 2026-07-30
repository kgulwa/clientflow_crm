# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Tags", type: :request do
  let(:user) { create(:user) }
  let(:client) { create(:client, user: user) }

  describe "authentication" do
    it "redirects unauthenticated users when creating a tag" do
      post client_tags_path(client), params: {
        tag: {
          name: "VIP",
          color: "indigo"
        }
      }

      expect(response).to redirect_to(new_user_session_path)
    end
  end

  context "when the user is signed in" do
    before do
      sign_in user
    end

    describe "POST /clients/:client_id/tags" do
      let(:valid_attributes) do
        {
          name: "VIP",
          color: "purple"
        }
      end

      it "creates a tag belonging to the signed-in user" do
        expect do
          post client_tags_path(client), params: {
            tag: valid_attributes
          }
        end.to change(user.tags, :count).by(1)

        tag = user.tags.last

        expect(tag.name).to eq("VIP")
        expect(tag.color).to eq("purple")
      end

      it "assigns the new tag to the client" do
        expect do
          post client_tags_path(client), params: {
            tag: valid_attributes
          }
        end.to change(client.tags, :count).by(1)

        expect(client.tags.last.name).to eq("VIP")
      end

      it "creates the tag and assignment together" do
        expect do
          post client_tags_path(client), params: {
            tag: valid_attributes
          }
        end.to change(Tag, :count).by(1)
          .and change(ClientTag, :count).by(1)
      end

      it "redirects to the client after creating and assigning the tag" do
        post client_tags_path(client), params: {
          tag: valid_attributes
        }

        expect(response).to redirect_to(client_path(client))
        expect(flash[:notice]).to eq(
          "Tag was created and assigned successfully."
        )
      end

      it "uses the default color when no color is supplied" do
        post client_tags_path(client), params: {
          tag: {
            name: "Follow Up",
            color: ""
          }
        }

        expect(user.tags.last.color).to eq(Tag::DEFAULT_COLOR)
      end

      it "normalizes whitespace around the tag name" do
        post client_tags_path(client), params: {
          tag: {
            name: "  Important Client  ",
            color: "indigo"
          }
        }

        expect(user.tags.last.name).to eq("Important Client")
      end

      it "does not create a tag with a blank name" do
        expect do
          post client_tags_path(client), params: {
            tag: valid_attributes.merge(name: "")
          }
        end.not_to change(Tag, :count)

        expect(response).to redirect_to(client_path(client))
        expect(flash[:alert]).to include("Name can't be blank")
      end

      it "does not create a client-tag assignment when the tag is invalid" do
        expect do
          post client_tags_path(client), params: {
            tag: valid_attributes.merge(name: "")
          }
        end.not_to change(ClientTag, :count)
      end

      it "does not create a duplicate tag name for the same user" do
        create(
          :tag,
          user: user,
          name: "VIP"
        )

        expect do
          post client_tags_path(client), params: {
            tag: {
              name: "vip",
              color: "indigo"
            }
          }
        end.not_to change(Tag, :count)

        expect(response).to redirect_to(client_path(client))
        expect(flash[:alert]).to include("Name has already been taken")
      end

      it "does not allow tag creation for another user's client" do
        other_client = create(:client)

        expect do
          post client_tags_path(other_client), params: {
            tag: valid_attributes
          }
        end.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end