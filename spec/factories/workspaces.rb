# frozen_string_literal: true

FactoryBot.define do
  factory :workspace do
    sequence(:name) { |number| "Workspace #{number}" }
  end
end