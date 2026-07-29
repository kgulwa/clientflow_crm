# frozen_string_literal: true

class ClientTag < ApplicationRecord
  belongs_to :client,
             inverse_of: :client_tags

  belongs_to :tag,
             inverse_of: :client_tags

  validates :tag_id,
            uniqueness: {
              scope: :client_id,
              message: "has already been assigned to this client"
            }

  validate :client_and_tag_belong_to_same_user

  private

  def client_and_tag_belong_to_same_user
    return if client.blank? || tag.blank?
    return if client.user_id == tag.user_id

    errors.add(:tag, "must belong to the same user as the client")
  end
end