FactoryBot.define do
  factory :user do
    sequence(:email) { |number| "user#{number}@example.com" }
    first_name { "Test" }
    last_name { "User" }
    password { "Password123!" }
    password_confirmation { "Password123!" }
    role { :member }

    trait :admin do
      role { :admin }
    end
  end
end