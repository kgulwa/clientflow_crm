# frozen_string_literal: true

class WorkspaceInvitation < ApplicationRecord
  belongs_to :workspace

  belongs_to :invited_by,
             class_name: "User"

  enum status: {
    pending: 0,
    accepted: 1
  }

  before_validation :normalize_email
  before_validation :generate_token,
                    on: :create

  validates :email,
            presence: true

  validates :token,
            presence: true,
            uniqueness: true

  validates :status,
            presence: true

  validate :email_is_not_already_in_workspace,
           on: :create

  private

  def normalize_email
    self.email = email.to_s.strip.downcase
  end

  def generate_token
    self.token ||= SecureRandom.urlsafe_base64(32)
  end

  def email_is_not_already_in_workspace
    return if email.blank? || workspace.blank?

    existing_user = User.find_by(
      "LOWER(email) = ?",
      email.downcase
    )

    return unless existing_user&.workspace_id == workspace_id

    errors.add(
      :email,
      "already belongs to this workspace"
    )
  end
end