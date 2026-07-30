# frozen_string_literal: true

FactoryBot.define do
  factory :deal do
    association :client

    title { "Website redesign opportunity" }
    stage { :prospecting }
    value { 25_000.00 }
    expected_close_date { 30.days.from_now.to_date }
    description { "Potential website redesign and support agreement." }

    trait :qualified do
      stage { :qualified }
    end

    trait :proposal_sent do
      stage { :proposal_sent }
    end

    trait :negotiation do
      stage { :negotiation }
    end

    trait :won do
      stage { :won }
    end

    trait :lost do
      stage { :lost }
    end
  end
end