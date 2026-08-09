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

  validate :client_and_tag_belong_to_same_workspace

  private

  def client_and_tag_belong_to_same_workspace
    return if client.blank? || tag.blank?
    return if client.workspace_id == tag.workspace_id

    errors.add(:tag, "must belong to the same workspace as the client")
  end
end