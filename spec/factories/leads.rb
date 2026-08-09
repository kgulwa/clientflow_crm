# frozen_string_literal: true

FactoryBot.define do
  factory :lead do
    association :user

    workspace { user.workspace }

    first_name { "Thando" }
    last_name { "Mokoena" }
    company_name { "Mokoena Consulting" }
    sequence(:email) { |number| "lead#{number}@example.com" }
    phone { "+27 82 555 0201" }
    source { :website }
    status { :new_lead }
    notes { "Interested in learning more about ClientFlow services." }

    trait :contacted do
      status { :contacted }
    end

    trait :qualified do
      status { :qualified }
    end

    trait :lost do
      status { :lost }
    end

    trait :converted do
      status { :converted }
    end

    trait :referral do
      source { :referral }
    end

    trait :linkedin do
      source { :linkedin }
    end
  end
end