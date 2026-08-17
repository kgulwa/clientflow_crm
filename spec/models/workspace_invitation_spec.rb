# frozen_string_literal: true

require "rails_helper"

RSpec.describe WorkspaceInvitation, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:workspace) }

    it do
      is_expected.to belong_to(:invited_by)
        .class_name("User")
    end
  end

  describe "status" do
    it "defines pending and accepted statuses" do
      expect(described_class.statuses).to eq(
        "pending" => 0,
        "accepted" => 1
      )
    end

    it "defaults new invitations to pending" do
      invitation = described_class.new

      expect(invitation).to be_pending
    end
  end

  describe "validations" do
    subject(:invitation) { build(:workspace_invitation) }

    it { is_expected.to validate_presence_of(:email) }
    it { is_expected.to validate_presence_of(:status) }

    it "requires a token after validation" do
      invitation.token = nil

      invitation.valid?

      expect(invitation.token).to be_present
    end

    it "does not allow duplicate tokens" do
      create(
        :workspace_invitation,
        token: "duplicate-token",
        email: "first@example.com"
      )

      duplicate = build(
        :workspace_invitation,
        token: "duplicate-token",
        email: "second@example.com"
      )

      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:token]).to include("has already been taken")
    end
  end

  describe "email normalization" do
    it "strips whitespace and downcases the email" do
      invitation = create(
        :workspace_invitation,
        email: "  Teammate@Example.COM  "
      )

      expect(invitation.email).to eq("teammate@example.com")
    end
  end

  describe "token generation" do
    it "generates a token when one is not supplied" do
      invitation = build(
        :workspace_invitation,
        token: nil
      )

      invitation.valid?

      expect(invitation.token).to be_present
    end

    it "does not replace an existing token" do
      invitation = build(
        :workspace_invitation,
        token: "existing-token"
      )

      invitation.valid?

      expect(invitation.token).to eq("existing-token")
    end
  end

  describe "workspace membership validation" do
    it "does not allow inviting a user who already belongs to the workspace" do
      workspace = create(:workspace)

      existing_user = create(
        :user,
        workspace: workspace,
        email: "member@example.com"
      )

      invitation = build(
        :workspace_invitation,
        workspace: workspace,
        invited_by: create(:user, workspace: workspace),
        email: existing_user.email
      )

      expect(invitation).not_to be_valid
      expect(invitation.errors[:email])
        .to include("already belongs to this workspace")
    end

    it "allows inviting a user who belongs to another workspace" do
      workspace = create(:workspace)

      existing_user = create(
        :user,
        email: "member@example.com"
      )

      invitation = build(
        :workspace_invitation,
        workspace: workspace,
        invited_by: create(:user, workspace: workspace),
        email: existing_user.email
      )

      expect(invitation).to be_valid
    end

    it "allows inviting an email that does not belong to an existing user" do
      workspace = create(:workspace)

      invitation = build(
        :workspace_invitation,
        workspace: workspace,
        invited_by: create(:user, workspace: workspace),
        email: "newteammate@example.com"
      )

      expect(invitation).to be_valid
    end
  end
end