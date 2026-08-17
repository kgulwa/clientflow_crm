# frozen_string_literal: true

class Workspace < ApplicationRecord
  has_many :users,
           dependent: :restrict_with_error

  has_many :clients,
           dependent: :restrict_with_error

  has_many :leads,
           dependent: :restrict_with_error

  has_many :tags,
           dependent: :restrict_with_error

  has_many :workspace_invitations,
           dependent: :destroy

  validates :name, presence: true
end