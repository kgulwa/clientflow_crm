# frozen_string_literal: true

require "csv"

class Lead < ApplicationRecord
  belongs_to :user
  belongs_to :workspace

  enum source: {
    website: 0,
    referral: 1,
    linkedin: 2,
    email: 3,
    phone: 4,
    walk_in: 5,
    other: 6
  }

  enum status: {
    new_lead: 0,
    contacted: 1,
    qualified: 2,
    lost: 3,
    converted: 4
  }

  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :email, presence: true
  validates :source, presence: true
  validates :status, presence: true

  scope :search, lambda { |query|
    if query.blank?
      all
    else
      search_term = "%#{sanitize_sql_like(query.to_s.strip)}%"

      where(
        <<~SQL.squish,
          leads.first_name ILIKE :search_term
          OR leads.last_name ILIKE :search_term
          OR leads.company_name ILIKE :search_term
          OR leads.email ILIKE :search_term
        SQL
        search_term: search_term
      )
    end
  }

  scope :with_status, lambda { |status|
    if status.present? && statuses.key?(status.to_s)
      where(status: statuses.fetch(status.to_s))
    else
      all
    end
  }

  scope :with_source, lambda { |source|
    if source.present? && sources.key?(source.to_s)
      where(source: sources.fetch(source.to_s))
    else
      all
    end
  }

  def self.to_csv(records = all)
    CSV.generate(headers: true) do |csv|
      csv << [
        "First Name",
        "Last Name",
        "Company",
        "Email",
        "Phone",
        "Source",
        "Status",
        "Notes",
        "Created At"
      ]

      records.each do |lead|
        csv << [
          lead.first_name,
          lead.last_name,
          lead.company_name,
          lead.email,
          lead.phone,
          lead.source.titleize,
          lead.display_status,
          lead.notes,
          lead.created_at.iso8601
        ]
      end
    end
  end

  def full_name
    "#{first_name} #{last_name}".strip
  end

  def display_status
    return "New" if new_lead?

    status.titleize
  end
end