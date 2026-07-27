class User < ApplicationRecord
  devise :database_authenticatable,
         :registerable,
         :recoverable,
         :rememberable,
         :validatable

  enum role: {
    member: 0,
    admin: 1
  }

  has_many :clients, dependent: :destroy

  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :role, presence: true

  def full_name
    "#{first_name} #{last_name}".strip
  end
end
