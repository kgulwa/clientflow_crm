class Client < ApplicationRecord
  belongs_to :user

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