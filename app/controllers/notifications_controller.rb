# frozen_string_literal: true

class NotificationsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_notification, only: :read

  def index
    @notifications = current_user.notifications
                                 .includes(:actor, task: :client)
                                 .order(created_at: :desc)

    @unread_count = current_user.notifications.unread.count
  end

  def read
    @notification.mark_as_read!

    redirect_to client_path(
      @notification.task.client,
      anchor: "tasks_section"
    )
  end

  def read_all
    current_user.notifications
                .unread
                .update_all(
                  read_at: Time.current,
                  updated_at: Time.current
                )

    redirect_to notifications_path,
                notice: "All notifications were marked as read."
  end

  private

  def set_notification
    @notification = current_user.notifications.find(params[:id])
  end
end