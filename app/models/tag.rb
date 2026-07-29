# frozen_string_literal: true

class Tag < ApplicationRecord
  DEFAULT_COLOR = "indigo"

  belongs_to :user

  has_many :client_tags,
           inverse_of: :tag,
           dependent: :destroy

  has_many :clients,
           through: :client_tags

  before_validation :normalize_name
  before_validation :set_default_color

  validates :name,
            presence: true,
            uniqueness: {
              scope: :user_id,
              case_sensitive: false
            }

  validates :color, presence: true

  private

  def normalize_name
    self.name = name.to_s.strip.presence
  end

  def set_default_color
    self.color = DEFAULT_COLOR if color.blank?
  end
end