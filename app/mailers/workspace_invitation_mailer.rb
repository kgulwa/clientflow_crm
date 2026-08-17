# frozen_string_literal: true

class WorkspaceInvitationMailer < ApplicationMailer
  def invitation_email
    @invitation = params[:invitation]
    @workspace = @invitation.workspace
    @invited_by = @invitation.invited_by
    @accept_url = accept_workspace_invitation_url(
      @invitation.token,
      host: ENV.fetch("APP_HOST", "localhost"),
      port: ENV.fetch("APP_PORT", 3000).to_i,
      protocol: ENV.fetch("APP_PROTOCOL", "http")
    )

    mail(
      to: @invitation.email,
      subject: "You've been invited to #{@workspace.name}"
    )
  end
end