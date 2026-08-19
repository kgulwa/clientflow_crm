# frozen_string_literal: true

FactoryBot.define do
  factory :notification do
    association :user
    association :actor, factory: :user
    association :task

    message { "You were assigned a task." }
    read_at { nil }
  end
end