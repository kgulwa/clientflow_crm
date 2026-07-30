# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Client tags", type: :request do
  let(:user) { create(:user) }
  let(:client) { create(:client, user: user) }
  let(:tag) { create(:tag, user: user) }

  describe "authentication" do
    it "redirects unauthenticated users when assigning a tag" do
      post client_client_tags_path(client), params: {
        client_tag: {
          tag_id: tag.id
        }
      }

      expect(response).to redirect_to(new_user_session_path)
    end

    it "redirects unauthenticated users when removing a tag" do
      client_tag = create(
        :client_tag,
        client: client,
        tag: tag
      )

      delete client_client_tag_path(client, client_tag)

      expect(response).to redirect_to(new_user_session_path)
    end
  end

  context "when the user is signed in" do
    before do
      sign_in user
    end

    describe "POST /clients/:client_id/client_tags" do
      it "assigns an existing tag to the client" do
        expect do
          post client_client_tags_path(client), params: {
            client_tag: {
              tag_id: tag.id
            }
          }
        end.to change(client.client_tags, :count).by(1)

        expect(client.tags).to include(tag)
      end

      it "redirects to the client after assigning the tag" do
        post client_client_tags_path(client), params: {
          client_tag: {
            tag_id: tag.id
          }
        }

        expect(response).to redirect_to(client_path(client))
        expect(flash[:notice]).to eq("Tag was assigned successfully.")
      end

      it "does not assign the same tag more than once" do
        create(
          :client_tag,
          client: client,
          tag: tag
        )

        expect do
          post client_client_tags_path(client), params: {
            client_tag: {
              tag_id: tag.id
            }
          }
        end.not_to change(ClientTag, :count)

        expect(response).to redirect_to(client_path(client))
        expect(flash[:alert]).to include("Tag has already been assigned to this client")
      end

      it "does not allow assignment of another user's tag" do
        other_tag = create(:tag)

        expect do
          post client_client_tags_path(client), params: {
            client_tag: {
              tag_id: other_tag.id
            }
          }
        end.to raise_error(ActiveRecord::RecordNotFound)
      end

      it "does not allow tag assignment to another user's client" do
        other_client = create(:client)

        expect do
          post client_client_tags_path(other_client), params: {
            client_tag: {
              tag_id: tag.id
            }
          }
        end.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    describe "DELETE /clients/:client_id/client_tags/:id" do
      it "removes the tag from the client" do
        client_tag = create(
          :client_tag,
          client: client,
          tag: tag
        )

        expect do
          delete client_client_tag_path(client, client_tag)
        end.to change(client.client_tags, :count).by(-1)

        expect(client.reload.tags).not_to include(tag)
      end

      it "preserves the tag after removing it from the client" do
        client_tag = create(
          :client_tag,
          client: client,
          tag: tag
        )

        expect do
          delete client_client_tag_path(client, client_tag)
        end.not_to change(Tag, :count)

        expect(Tag.exists?(tag.id)).to be(true)
      end

      it "redirects to the client after removing the tag" do
        client_tag = create(
          :client_tag,
          client: client,
          tag: tag
        )

        delete client_client_tag_path(client, client_tag)

        expect(response).to redirect_to(client_path(client))
        expect(flash[:notice]).to eq("Tag was removed successfully.")
      end

      it "does not remove a client tag belonging to another client" do
        other_client = create(:client, user: user)
        other_client_tag = create(
          :client_tag,
          client: other_client,
          tag: tag
        )

        expect do
          delete client_client_tag_path(client, other_client_tag)
        end.to raise_error(ActiveRecord::RecordNotFound)

        expect(ClientTag.exists?(other_client_tag.id)).to be(true)
      end

      it "does not allow removal from another user's client" do
        other_client_tag = create(:client_tag)

        expect do
          delete client_client_tag_path(
            other_client_tag.client,
            other_client_tag
          )
        end.to raise_error(ActiveRecord::RecordNotFound)

        expect(ClientTag.exists?(other_client_tag.id)).to be(true)
      end
    end
  end
end