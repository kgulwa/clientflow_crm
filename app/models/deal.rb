# frozen_string_literal: true

class Deal < ApplicationRecord
  belongs_to :client

  enum stage: {
    prospecting: 0,
    qualified: 1,
    proposal_sent: 2,
    negotiation: 3,
    won: 4,
    lost: 5
  }

  validates :title,
            presence: true

  validates :stage,
            presence: true

  validates :value,
            numericality: {
              greater_than_or_equal_to: 0
            }

  scope :recent_first, lambda {
    order(created_at: :desc)
  }

  def display_stage
    stage.titleize
  end

  def formatted_value
    value.to_f
  end
end