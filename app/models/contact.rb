# frozen_string_literal: true

class Contact < ApplicationRecord
  belongs_to :client

  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :email, presence: true

  scope :primary_first, lambda {
    order(primary_contact: :desc, last_name: :asc, first_name: :asc)
  }

  def full_name
    "#{first_name} #{last_name}".strip
  end
end