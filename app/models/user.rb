# frozen_string_literal: true

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

  belongs_to :workspace

  has_many :clients,
           dependent: :destroy

  has_many :deals,
           through: :clients

  has_many :leads,
           dependent: :destroy

  has_many :tags,
           dependent: :destroy

  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :role, presence: true

  scope :active, -> { where(active: true) }

  def full_name
    "#{first_name} #{last_name}".strip
  end

  def active_for_authentication?
    super && active?
  end

  def inactive_message
    active? ? super : :deactivated
  end

  def deactivate!
    update!(
      active: false,
      deactivated_at: Time.current
    )
  end

  def activate!
    update!(
      active: true,
      deactivated_at: nil
    )
  end
end