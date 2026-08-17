# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Workspace invitations", type: :request do
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
    it "redirects unauthenticated users from the team page" do
      get workspace_invitations_path

      expect(response).to redirect_to(new_user_session_path)
    end
  end

  context "when an admin is signed in" do
    before do
      sign_in admin
    end

    describe "GET /workspace_invitations" do
      it "returns a successful response" do
        get workspace_invitations_path

        expect(response).to have_http_status(:success)
      end

      it "shows users belonging to the workspace" do
        member

        other_workspace_user = create(
          :user,
          first_name: "Hidden",
          last_name: "User"
        )

        get workspace_invitations_path

        expect(response.body).to include(member.full_name)
        expect(response.body).not_to include(other_workspace_user.full_name)
      end

      it "does not show inactive workspace members" do
        inactive_member = create(
          :user,
          workspace: workspace,
          first_name: "Removed",
          last_name: "Member",
          active: false,
          deactivated_at: Time.current
        )

        get workspace_invitations_path

        expect(response.body).not_to include(inactive_member.full_name)
      end
    end

    describe "POST /workspace_invitations" do
      it "creates an invitation for the current workspace" do
        expect do
          post workspace_invitations_path, params: {
            workspace_invitation: {
              email: "teammate@example.com"
            }
          }
        end.to change(workspace.workspace_invitations, :count).by(1)

        invitation = workspace.workspace_invitations.last

        expect(invitation.email).to eq("teammate@example.com")
        expect(invitation.workspace).to eq(workspace)
        expect(invitation.invited_by).to eq(admin)
        expect(invitation).to be_pending
      end

      it "normalizes the invitation email" do
        post workspace_invitations_path, params: {
          workspace_invitation: {
            email: "  Teammate@Example.COM  "
          }
        }

        expect(workspace.workspace_invitations.last.email)
          .to eq("teammate@example.com")
      end

      it "does not invite a user who already belongs to the workspace" do
        member.update!(email: "member@example.com")

        expect do
          post workspace_invitations_path, params: {
            workspace_invitation: {
              email: member.email
            }
          }
        end.not_to change(WorkspaceInvitation, :count)

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to include(
          "Email already belongs to this workspace"
        )
      end

      it "removes the invitation and shows an alert when email delivery fails" do
        allow_any_instance_of(ActionMailer::MessageDelivery)
          .to receive(:deliver_now)
          .and_raise(Net::SMTPFatalError.new("550 delivery failed"))

        expect do
          post workspace_invitations_path, params: {
            workspace_invitation: {
              email: "failed@example.com"
            }
          }
        end.not_to change(WorkspaceInvitation, :count)

        expect(response).to redirect_to(workspace_invitations_path)
        expect(flash[:alert]).to eq(
          "The invitation email could not be sent. Please try again."
        )
      end
    end

    describe "DELETE /workspace_invitations/:id" do
      it "deletes an invitation belonging to the workspace" do
        invitation = create(
          :workspace_invitation,
          workspace: workspace,
          invited_by: admin
        )

        expect do
          delete workspace_invitation_path(invitation)
        end.to change(workspace.workspace_invitations, :count).by(-1)
      end

      it "does not allow deleting an invitation from another workspace" do
        other_invitation = create(:workspace_invitation)

        expect do
          delete workspace_invitation_path(other_invitation)
        end.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  context "when a member is signed in" do
    before do
      sign_in member
    end

    it "does not allow access to invitation management" do
      get workspace_invitations_path

      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq(
        "You are not authorized to manage workspace invitations."
      )
    end

    it "does not allow creating invitations" do
      expect do
        post workspace_invitations_path, params: {
          workspace_invitation: {
            email: "teammate@example.com"
          }
        }
      end.not_to change(WorkspaceInvitation, :count)

      expect(response).to redirect_to(root_path)
    end
  end

  describe "GET /workspace_invitations/:token/accept" do
    let(:workspace) do
      create(
        :workspace,
        name: "Shared Workspace"
      )
    end

    let(:admin) do
      create(
        :user,
        :admin,
        workspace: workspace,
        first_name: "Konke",
        last_name: "Gulwa"
      )
    end

    let(:invitation) do
      create(
        :workspace_invitation,
        workspace: workspace,
        invited_by: admin,
        email: "invitee@example.com"
      )
    end

    it "shows a valid pending invitation without requiring authentication" do
      get accept_workspace_invitation_path(invitation.token)

      expect(response).to have_http_status(:success)
    end

    it "shows the workspace name" do
      get accept_workspace_invitation_path(invitation.token)

      expect(response.body).to include("Shared Workspace")
    end

    it "shows the inviter's name" do
      get accept_workspace_invitation_path(invitation.token)

      expect(response.body).to include("Konke Gulwa")
    end

    it "shows the invited email address" do
      get accept_workspace_invitation_path(invitation.token)

      expect(response.body).to include("invitee@example.com")
    end

    it "links to registration with the invitation token" do
      get accept_workspace_invitation_path(invitation.token)

      expected_path = new_user_registration_path(
        invitation_token: invitation.token
      )
      expect(response.body).to include(expected_path)
    end

    it "does not allow an accepted invitation to be reused" do
      invitation.update!(
        status: :accepted,
        accepted_at: Time.current
      )

      expect do
        get accept_workspace_invitation_path(invitation.token)
      end.to raise_error(ActiveRecord::RecordNotFound)
    end

    it "does not allow an invalid invitation token" do
      expect do
        get accept_workspace_invitation_path("invalid-token")
      end.to raise_error(ActiveRecord::RecordNotFound)
    end

    it "redirects when the invited email already belongs to a ClientFlow user" do
      create(
        :user,
        email: invitation.email
      )

      get accept_workspace_invitation_path(invitation.token)

      expect(response).to redirect_to(new_user_session_path)
      expect(flash[:alert]).to eq(
        "This invitation is only available for new ClientFlow users."
      )
    end
  end
end