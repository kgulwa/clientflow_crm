# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Workspace members", type: :request do
  let(:workspace) { create(:workspace) }

  let(:admin) do
    create(
      :user,
      :admin,
      workspace: workspace
    )
  end

  let(:member) do
    create(
      :user,
      workspace: workspace
    )
  end

  describe "authentication" do
    it "redirects unauthenticated users when updating a member" do
      patch workspace_member_path(member), params: {
        user: {
          role: "admin"
        }
      }

      expect(response).to redirect_to(new_user_session_path)
    end
  end

  context "when an admin is signed in" do
    before do
      sign_in admin
    end

    describe "PATCH /workspace_members/:id" do
      it "promotes a member to admin" do
        patch workspace_member_path(member), params: {
          user: {
            role: "admin"
          }
        }

        expect(member.reload).to be_admin
      end

      it "demotes another admin to member when another active admin remains" do
        other_admin = create(
          :user,
          :admin,
          workspace: workspace
        )

        patch workspace_member_path(other_admin), params: {
          user: {
            role: "member"
          }
        }

        expect(other_admin.reload).to be_member
      end

      it "does not allow an admin to demote themselves" do
        patch workspace_member_path(admin), params: {
          user: {
            role: "member"
          }
        }

        expect(admin.reload).to be_admin
        expect(response).to redirect_to(workspace_invitations_path)
        expect(flash[:alert]).to eq(
          "You cannot demote yourself."
        )
      end

      it "does not allow an invalid role" do
        patch workspace_member_path(member), params: {
          user: {
            role: "owner"
          }
        }

        expect(member.reload).to be_member
        expect(flash[:alert]).to eq("Role is invalid.")
      end

      it "does not allow managing a member from another workspace" do
        other_member = create(:user)

        expect do
          patch workspace_member_path(other_member), params: {
            user: {
              role: "admin"
            }
          }
        end.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    describe "DELETE /workspace_members/:id" do
      it "deactivates a member" do
        delete workspace_member_path(member)

        expect(member.reload).not_to be_active
        expect(member.deactivated_at).to be_present
      end

      it "does not destroy the user record" do
        member

        expect do
          delete workspace_member_path(member)
        end.not_to change(User, :count)

        expect(User.exists?(member.id)).to be(true)
      end

      it "preserves CRM data created by the member" do
        client = create(
          :client,
          user: member,
          workspace: workspace
        )

        lead = create(
          :lead,
          user: member,
          workspace: workspace
        )

        tag = create(
          :tag,
          user: member,
          workspace: workspace
        )

        delete workspace_member_path(member)

        expect(Client.exists?(client.id)).to be(true)
        expect(Lead.exists?(lead.id)).to be(true)
        expect(Tag.exists?(tag.id)).to be(true)
      end

      it "does not allow an admin to remove themselves" do
        delete workspace_member_path(admin)

        expect(admin.reload).to be_active
        expect(flash[:alert]).to eq(
          "You cannot remove yourself from the workspace."
        )
      end

      it "does not allow removing a member from another workspace" do
        other_member = create(:user)

        expect do
          delete workspace_member_path(other_member)
        end.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  context "when a member is signed in" do
    before do
      sign_in member
    end

    it "does not allow role changes" do
      patch workspace_member_path(admin), params: {
        user: {
          role: "member"
        }
      }

      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq(
        "You are not authorized to manage workspace members."
      )
    end

    it "does not allow member removal" do
      delete workspace_member_path(admin)

      expect(response).to redirect_to(root_path)
    end
  end
end