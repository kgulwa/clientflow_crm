# frozen_string_literal: true

FactoryBot.define do
  factory :client do
    association :user

    workspace { user.workspace }

    first_name { "Sarah" }
    last_name { "Johnson" }
    company_name { "Johnson Consulting" }
    sequence(:email) { |number| "client#{number}@example.com" }
    phone { "+27 82 555 0101" }
    status { :lead }
    notes { "Interested in learning more about ClientFlow services." }

    trait :active do
      status { :active }
    end

    trait :inactive do
      status { :inactive }
    end
  end
end