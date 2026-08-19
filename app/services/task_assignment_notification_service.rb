# frozen_string_literal: true

class TaskAssignmentNotificationService
  attr_reader :task, :actor

  def initialize(task:, actor:)
    @task = task
    @actor = actor
  end

  def call
    return if task.assigned_user.blank?
    return if task.assigned_user == actor

    Notification.create!(
      user: task.assigned_user,
      actor: actor,
      task: task,
      message: notification_message
    )
  end

  private

  def notification_message
    "#{actor.full_name} assigned you a task: #{task.title}"
  end
end