# frozen_string_literal: true

class WorkspaceMembersController < ApplicationController
  before_action :authenticate_user!
  before_action :require_admin!
  before_action :set_member

  def update
    if role_change_blocked?
      redirect_to workspace_invitations_path,
                  alert: role_change_error_message
      return
    end

    @member.update!(role: member_params[:role])

    redirect_to workspace_invitations_path,
                notice: "Workspace member role was updated successfully."
  end

  def destroy
    if @member == current_user
      redirect_to workspace_invitations_path,
                  alert: "You cannot remove yourself from the workspace."
      return
    end

    if removing_last_admin?
      redirect_to workspace_invitations_path,
                  alert: "The workspace must have at least one active admin."
      return
    end

    @member.deactivate!

    redirect_to workspace_invitations_path,
                notice: "Workspace member was removed successfully.",
                status: :see_other
  end

  private

  def set_member
    @member = current_user.workspace.users.find(params[:id])
  end

  def require_admin!
    return if current_user.admin?

    redirect_to root_path,
                alert: "You are not authorized to manage workspace members."
  end

  def member_params
    params.require(:user).permit(:role)
  end

  def role_change_blocked?
    invalid_role? ||
      demoting_self? ||
      demoting_last_admin?
  end

  def invalid_role?
    !User.roles.key?(member_params[:role].to_s)
  end

  def demoting_self?
    @member == current_user &&
      @member.admin? &&
      member_params[:role] == "member"
  end

  def demoting_last_admin?
    @member.admin? &&
      member_params[:role] == "member" &&
      active_admin_count == 1
  end

  def removing_last_admin?
    @member.admin? && active_admin_count == 1
  end

  def active_admin_count
    current_user.workspace.users.active.admin.count
  end

  def role_change_error_message
    if invalid_role?
      "Role is invalid."
    elsif demoting_self?
      "You cannot demote yourself."
    else
      "The workspace must have at least one active admin."
    end
  end
end