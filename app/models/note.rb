# frozen_string_literal: true

class Note < ApplicationRecord
  belongs_to :client,
             inverse_of: :client_notes

  validates :title, presence: true
  validates :content, presence: true
end