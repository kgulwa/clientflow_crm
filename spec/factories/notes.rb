# frozen_string_literal: true

FactoryBot.define do
  factory :note do
    association :client

    sequence(:title) { |number| "Client interaction #{number}" }
    content { 'Discussed the client requirements and agreed on the next steps.' }
  end
end