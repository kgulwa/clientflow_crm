# frozen_string_literal: true

FactoryBot.define do
  factory :workspace_invitation do
    association :workspace
    association :invited_by, factory: :user

    sequence(:email) do |number|
      "invitee#{number}@example.com"
    end

    status { :pending }

    after(:build) do |invitation|
      invitation.invited_by.workspace = invitation.workspace
    end

    trait :accepted do
      status { :accepted }
      accepted_at { Time.current }
    end
  end
end