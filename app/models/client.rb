# frozen_string_literal: true

class Client < ApplicationRecord
  belongs_to :user

  has_many :client_notes,
           class_name: 'Note',
           inverse_of: :client,
           dependent: :destroy

  has_many :tasks,
           inverse_of: :client,
           dependent: :destroy

  enum status: {
    lead: 0,
    active: 1,
    inactive: 2
  }

  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :email, presence: true
  validates :status, presence: true

  scope :search, lambda { |query|
    if query.blank?
      all
    else
      search_term = "%#{sanitize_sql_like(query.to_s.strip)}%"

      where(
        <<~SQL.squish,
          clients.first_name ILIKE :search_term
          OR clients.last_name ILIKE :search_term
          OR clients.company_name ILIKE :search_term
          OR clients.email ILIKE :search_term
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

  def full_name
    "#{first_name} #{last_name}".strip
  end
end