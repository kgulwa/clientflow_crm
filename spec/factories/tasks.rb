# frozen_string_literal: true

FactoryBot.define do
  factory :task do
    association :client

    sequence(:title) { |number| "Client task #{number}" }
    description { 'Follow up with the client about the next steps.' }
    due_date { 3.days.from_now.to_date }
    status { :pending }
    priority { :medium }

    trait :in_progress do
      status { :in_progress }
    end

    trait :completed do
      status { :completed }
    end

    trait :low_priority do
      priority { :low }
    end

    trait :high_priority do
      priority { :high }
    end

    trait :overdue do
      due_date { 2.days.ago.to_date }
    end
  end
end