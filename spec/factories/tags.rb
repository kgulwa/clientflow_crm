# frozen_string_literal: true

FactoryBot.define do
  factory :tag do
    association :user

    workspace { user.workspace }

    sequence(:name) { |number| "Tag #{number}" }
    color { "indigo" }

    trait :vip do
      name { "VIP" }
      color { "amber" }
    end

    trait :hot_lead do
      name { "Hot Lead" }
      color { "red" }
    end

    trait :follow_up do
      name { "Follow Up" }
      color { "blue" }
    end
  end
end