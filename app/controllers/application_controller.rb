# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include Pagy::Method

  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :set_notification_header_data, if: :user_signed_in?

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

  def set_notification_header_data
    notifications = current_user.notifications

    @unread_notifications_count = notifications.unread.count

    @recent_notifications = notifications
                            .includes(:actor, task: :client)
                            .order(created_at: :desc)
                            .limit(5)
  end
end