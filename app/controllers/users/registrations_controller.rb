# frozen_string_literal: true

module Users
  class RegistrationsController < Devise::RegistrationsController
    before_action :set_workspace_invitation, only: %i[new create]
    before_action :configure_account_update_params, only: :update

    def new
      if invitation_token_supplied? && @workspace_invitation.blank?
        redirect_to new_user_registration_path,
                    alert: "This workspace invitation is invalid or has already been used."
        return
      end

      super do |resource|
        next unless @workspace_invitation

        resource.email = @workspace_invitation.email
      end
    end

    def create
      if invitation_token_supplied?
        if @workspace_invitation
          create_invited_user
        else
          redirect_to new_user_registration_path,
                      alert: "This workspace invitation is invalid or has already been used."
        end
      else
        create_standard_user
      end
    end

    def destroy
      current_user.deactivate!

      Devise.sign_out_all_scopes ? sign_out : sign_out(resource_name)

      redirect_to new_user_session_path,
                  status: :see_other,
                  notice: "Your account has been deleted."
    end

    protected

    def update_resource(resource, params)
      resource.update_with_password(params)
    end

    def after_update_path_for(_resource)
      edit_user_registration_path
    end

    private

    def configure_account_update_params
      devise_parameter_sanitizer.permit(
        :account_update,
        keys: %i[first_name last_name]
      )
    end

    def create_standard_user
      build_resource(sign_up_params)

      resource.workspace = Workspace.new(
        name: workspace_name_for(resource)
      )
      resource.role = :admin

      save_and_respond(resource)
    end

    def create_invited_user
      build_resource(sign_up_params)

      resource.email = @workspace_invitation.email
      resource.workspace = @workspace_invitation.workspace
      resource.role = :member

      if resource.save
        @workspace_invitation.update!(
          status: :accepted,
          accepted_at: Time.current
        )

        respond_to_successful_signup(resource)
      else
        respond_to_failed_signup(resource)
      end
    end

    def save_and_respond(resource)
      if resource.save
        respond_to_successful_signup(resource)
      else
        respond_to_failed_signup(resource)
      end
    end

    def respond_to_successful_signup(resource)
      yield resource if block_given?

      if resource.active_for_authentication?
        set_flash_message! :notice, :signed_up
        sign_up(resource_name, resource)

        respond_with resource,
                     location: after_sign_up_path_for(resource)
      else
        set_flash_message! :notice,
                           :"signed_up_but_#{resource.inactive_message}"

        expire_data_after_sign_in!

        respond_with resource,
                     location: after_inactive_sign_up_path_for(resource)
      end
    end

    def respond_to_failed_signup(resource)
      clean_up_passwords resource
      set_minimum_password_length

      respond_with resource
    end

    def set_workspace_invitation
      return unless invitation_token_supplied?

      @workspace_invitation = WorkspaceInvitation.pending.find_by(
        token: invitation_token
      )
    end

    def invitation_token_supplied?
      invitation_token.present?
    end

    def invitation_token
      params[:invitation_token].presence ||
        params.dig(:user, :invitation_token).presence
    end

    def workspace_name_for(user)
      name = "#{user.first_name} #{user.last_name}".strip

      if name.present?
        "#{name}'s Workspace"
      else
        "My Workspace"
      end
    end
  end
end