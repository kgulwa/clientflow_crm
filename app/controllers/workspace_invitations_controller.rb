# frozen_string_literal: true

class WorkspaceInvitationsController < ApplicationController
  before_action :authenticate_user!, except: :accept
  before_action :require_admin!, except: :accept
  before_action :set_invitation, only: :destroy

  def index
    @workspace = current_user.workspace

    @workspace_users = @workspace.users.active.order(
      :first_name,
      :last_name,
      :email
    )

    @workspace_invitations = @workspace.workspace_invitations
                                       .order(created_at: :desc)

    @workspace_invitation = @workspace.workspace_invitations.new
  end

  def create
    @workspace_invitation = current_user.workspace.workspace_invitations.new(
      workspace_invitation_params.merge(
        invited_by: current_user
      )
    )

    if @workspace_invitation.save
      send_invitation_email
    else
      prepare_index

      render :index, status: :unprocessable_entity
    end
  end

  def accept
    @workspace_invitation = WorkspaceInvitation.pending.find_by!(
      token: params[:token]
    )

    if User.exists?(
      ["LOWER(email) = ?", @workspace_invitation.email.downcase]
    )
      redirect_to new_user_session_path,
                  alert: "This invitation is only available for new ClientFlow users."
      return
    end
  end

  def destroy
    @workspace_invitation.destroy

    redirect_to workspace_invitations_path,
                notice: "Workspace invitation was removed successfully.",
                status: :see_other
  end

  private

  def send_invitation_email
    WorkspaceInvitationMailer
      .with(invitation: @workspace_invitation)
      .invitation_email
      .deliver_now

    redirect_to workspace_invitations_path,
                notice: "Workspace invitation was sent successfully."
  rescue Net::SMTPError,
         Net::OpenTimeout,
         Net::ReadTimeout,
         Timeout::Error => error
    @workspace_invitation.destroy

    Rails.logger.error(
      "Workspace invitation email failed: #{error.class} - #{error.message}"
    )

    redirect_to workspace_invitations_path,
                alert: "The invitation email could not be sent. Please try again."
  end

  def set_invitation
    @workspace_invitation =
      current_user.workspace.workspace_invitations.find(params[:id])
  end

  def prepare_index
    @workspace = current_user.workspace

    @workspace_users = @workspace.users.active.order(
      :first_name,
      :last_name,
      :email
    )

    @workspace_invitations = @workspace.workspace_invitations
                                       .order(created_at: :desc)
  end

  def require_admin!
    return if current_user.admin?

    redirect_to root_path,
                alert: "You are not authorized to manage workspace invitations."
  end

  def workspace_invitation_params
    params.require(:workspace_invitation).permit(:email)
  end
end