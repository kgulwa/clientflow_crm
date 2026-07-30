FactoryBot.define do
  factory :contact do
    association :client

    first_name { "John" }
    last_name { "Smith" }
    job_title { "Procurement Manager" }
    department { "Procurement" }
    sequence(:email) { |number| "contact#{number}@example.com" }
    phone { "+27 82 555 0102" }
    primary_contact { false }
    notes { "Main procurement contact for this client." }

    trait :primary do
      primary_contact { true }
    end
  end
end