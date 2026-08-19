# frozen_string_literal: true

class Notification < ApplicationRecord
  belongs_to :user
  belongs_to :actor, class_name: "User"
  belongs_to :task

  validates :message, presence: true

  scope :unread, -> { where(read_at: nil) }
  scope :read, -> { where.not(read_at: nil) }

  def read?
    read_at.present?
  end

  def mark_as_read!
    update!(read_at: Time.current)
  end
end