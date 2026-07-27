# frozen_string_literal: true

class Task < ApplicationRecord
  belongs_to :client

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

  validates :title, presence: true
  validates :due_date, presence: true
  validates :status, presence: true
  validates :priority, presence: true
end