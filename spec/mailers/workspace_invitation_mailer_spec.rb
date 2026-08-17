# frozen_string_literal: true

require "rails_helper"

RSpec.describe WorkspaceInvitationMailer, type: :mailer do
  describe "#invitation_email" do
    let(:workspace) do
      create(
        :workspace,
        name: "ClientFlow Demo Workspace"
      )
    end

    let(:invited_by) do
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
        invited_by: invited_by,
        email: "teammate@example.com"
      )
    end

    let(:mail) do
      described_class
        .with(invitation: invitation)
        .invitation_email
    end

    it "sends the email to the invited address" do
      expect(mail.to).to eq(["teammate@example.com"])
    end

    it "uses the workspace name in the subject" do
      expect(mail.subject).to eq(
        "You've been invited to ClientFlow Demo Workspace"
      )
    end

    it "includes the inviter's name" do
      expect(mail.body.encoded).to include("Konke Gulwa")
    end

    it "includes the workspace name" do
      expect(mail.body.encoded).to include(
        "ClientFlow Demo Workspace"
      )
    end

    it "includes the invitation acceptance URL" do
      expected_url = accept_workspace_invitation_url(
        invitation.token,
        host: "localhost",
        port: 3000,
        protocol: "http"
      )

      expect(mail.body.encoded).to include(expected_url)
    end
  end
end