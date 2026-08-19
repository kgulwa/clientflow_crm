# frozen_string_literal: true

class Task < ApplicationRecord
  belongs_to :client

  belongs_to :assigned_user,
             class_name: "User",
             optional: true

  has_many :notifications,
            dependent: :destroy

  enum status: {
    pending: 0,
    in_progress: 1,
    completed: 2
  }

  enum priority: {
    low: 0,
    medium: 1,
    high: 2
  }

  scope :for_user, lambda { |user|
    joins(:client).where(clients: { user_id: user.id })
  }

  scope :assigned_to, lambda { |user|
    where(assigned_user_id: user.id)
  }

  scope :outstanding, lambda {
    where.not(status: statuses[:completed])
  }

  scope :overdue, lambda {
    outstanding.where(due_date: ...Date.current)
  }

  scope :due_today, lambda {
    where(due_date: Date.current)
  }

  validates :title, presence: true
  validates :due_date, presence: true
  validates :status, presence: true
  validates :priority, presence: true

  validate :assigned_user_belongs_to_client_workspace
  validate :assigned_user_is_active

  before_validation :record_status_history,
                    if: :will_save_change_to_status?

  private

  def assigned_user_belongs_to_client_workspace
    return if assigned_user.blank? || client.blank?
    return if assigned_user.workspace_id == client.workspace_id

    errors.add(
      :assigned_user,
      "must belong to the same workspace as the client"
    )
  end

  def assigned_user_is_active
    return if assigned_user.blank? || assigned_user.active?

    errors.add(
      :assigned_user,
      "must be active"
    )
  end

  def record_status_history
    case status
    when "pending"
      self.completed_at = nil
    when "in_progress"
      self.started_at ||= Time.current
      self.completed_at = nil
    when "completed"
      self.started_at ||= Time.current
      self.completed_at ||= Time.current
    end
  end
end