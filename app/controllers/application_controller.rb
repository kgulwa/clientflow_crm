# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include Pagy::Method

  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :set_unread_notifications_count, if: :user_signed_in?

  protected

  def configure_permitted_parameters
    added_attributes = %i[first_name last_name]

    devise_parameter_sanitizer.permit(
      :sign_up,
      keys: added_attributes
    )

    devise_parameter_sanitizer.permit(
      :account_update,
      keys: added_attributes
    )
  end

  private

  def set_unread_notifications_count
    @unread_notifications_count = current_user.notifications.unread.count
  end
end