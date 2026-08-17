# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Registrations", type: :request do
  describe "normal signup" do
    it "creates a user through the standard registration flow" do
      expect do
        post user_registration_path, params: {
          user: {
            first_name: "Lerato",
            last_name: "Mokoena",
            email: "lerato@example.com",
            password: "Password123!",
            password_confirmation: "Password123!"
          }
        }
      end.to change(User, :count).by(1)
    end

    it "creates a workspace for the new user" do
      expect do
        post user_registration_path, params: {
          user: {
            first_name: "Lerato",
            last_name: "Mokoena",
            email: "lerato@example.com",
            password: "Password123!",
            password_confirmation: "Password123!"
          }
        }
      end.to change(Workspace, :count).by(1)

      user = User.find_by!(email: "lerato@example.com")

      expect(user.workspace.name).to eq("Lerato Mokoena's Workspace")
    end

    it "makes the first user in a new workspace an admin" do
      post user_registration_path, params: {
        user: {
          first_name: "Lerato",
          last_name: "Mokoena",
          email: "lerato@example.com",
          password: "Password123!",
          password_confirmation: "Password123!"
        }
      }

      user = User.find_by!(email: "lerato@example.com")

      expect(user).to be_admin
    end
  end

  describe "invited signup" do
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
        workspace: workspace
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

    before do
      invitation
    end

    it "shows the signup page for a valid invitation" do
      get new_user_registration_path(
        invitation_token: invitation.token
      )

      expect(response).to have_http_status(:success)
      expect(response.body).to include("invitee@example.com")
    end

    it "creates the invited user in the invitation workspace" do
      expect do
        post user_registration_path, params: {
          invitation_token: invitation.token,
          user: {
            first_name: "Ayanda",
            last_name: "Dlamini",
            email: "different@example.com",
            password: "Password123!",
            password_confirmation: "Password123!"
          }
        }
      end.to change(User, :count).by(1)

      created_user = User.find_by!(email: "invitee@example.com")

      expect(created_user.workspace).to eq(workspace)
    end

    it "forces the invitation email instead of the submitted email" do
      post user_registration_path, params: {
        invitation_token: invitation.token,
        user: {
          first_name: "Ayanda",
          last_name: "Dlamini",
          email: "different@example.com",
          password: "Password123!",
          password_confirmation: "Password123!"
        }
      }

      expect(User.exists?(email: "different@example.com")).to be(false)
      expect(User.exists?(email: "invitee@example.com")).to be(true)
    end

    it "creates the invited user as a member" do
      post user_registration_path, params: {
        invitation_token: invitation.token,
        user: {
          first_name: "Ayanda",
          last_name: "Dlamini",
          email: invitation.email,
          password: "Password123!",
          password_confirmation: "Password123!"
        }
      }

      created_user = User.find_by!(email: invitation.email)

      expect(created_user).to be_member
    end

    it "does not create another workspace for the invited user" do
      expect do
        post user_registration_path, params: {
          invitation_token: invitation.token,
          user: {
            first_name: "Ayanda",
            last_name: "Dlamini",
            email: invitation.email,
            password: "Password123!",
            password_confirmation: "Password123!"
          }
        }
      end.not_to change(Workspace, :count)
    end

    it "marks the invitation as accepted" do
      post user_registration_path, params: {
        invitation_token: invitation.token,
        user: {
          first_name: "Ayanda",
          last_name: "Dlamini",
          email: invitation.email,
          password: "Password123!",
          password_confirmation: "Password123!"
        }
      }

      invitation.reload

      expect(invitation).to be_accepted
      expect(invitation.accepted_at).to be_present
    end

    it "rejects an accepted invitation token" do
      invitation.update!(
        status: :accepted,
        accepted_at: Time.current
      )

      expect do
        post user_registration_path, params: {
          invitation_token: invitation.token,
          user: {
            first_name: "Ayanda",
            last_name: "Dlamini",
            email: invitation.email,
            password: "Password123!",
            password_confirmation: "Password123!"
          }
        }
      end.not_to change(User, :count)

      expect(response).to redirect_to(new_user_registration_path)
      expect(flash[:alert]).to eq(
        "This workspace invitation is invalid or has already been used."
      )
    end

    it "rejects an invalid invitation token" do
      expect do
        post user_registration_path, params: {
          invitation_token: "invalid-token",
          user: {
            first_name: "Ayanda",
            last_name: "Dlamini",
            email: "attacker@example.com",
            password: "Password123!",
            password_confirmation: "Password123!"
          }
        }
      end.not_to change(User, :count)

      expect(response).to redirect_to(new_user_registration_path)
    end
  end
end