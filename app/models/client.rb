# frozen_string_literal: true

class Client < ApplicationRecord
  belongs_to :user

  has_many :client_notes,
           class_name: 'Note',
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

  def full_name
    "#{first_name} #{last_name}".strip
  end
end