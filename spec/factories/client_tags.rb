# frozen_string_literal: true

FactoryBot.define do
  factory :client_tag do
    association :client

    tag do
      association(
        :tag,
        user: client.user
      )
    end
  end
end