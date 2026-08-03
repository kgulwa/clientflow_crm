# frozen_string_literal: true

require "csv"

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

  scope :search, lambda { |query|
    return all if query.blank?

    joins(:client)
      .where(
        <<~SQL.squish,
          deals.title ILIKE :query
          OR clients.first_name ILIKE :query
          OR clients.last_name ILIKE :query
          OR CONCAT(
            clients.first_name,
            ' ',
            clients.last_name
          ) ILIKE :query
        SQL
        query: "%#{sanitize_sql_like(query)}%"
      )
  }

  scope :with_stage, lambda { |stage|
    return all if stage.blank?

    where(stage: stage)
  }

  scope :recent_first, lambda {
    order(created_at: :desc)
  }

  def self.to_csv(records = all)
    CSV.generate(headers: true) do |csv|
      csv << [
        "Title",
        "Client",
        "Company",
        "Stage",
        "Value",
        "Expected Close Date",
        "Description",
        "Created At"
      ]

      records.each do |deal|
        csv << [
          deal.title,
          deal.client.full_name,
          deal.client.company_name,
          deal.display_stage,
          deal.value.to_s,
          deal.expected_close_date&.iso8601,
          deal.description,
          deal.created_at.iso8601
        ]
      end
    end
  end

  def display_stage
    stage.titleize
  end

  def formatted_value
    value.to_f
  end
end