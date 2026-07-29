# frozen_string_literal: true

require "rails_helper"

RSpec.describe ClientTag, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:client) }
    it { is_expected.to belong_to(:tag) }
  end

  describe "validations" do
    it "allows a tag belonging to the client's user" do
      user = create(:user)
      client = create(:client, user: user)
      tag = create(:tag, user: user)

      client_tag = build(
        :client_tag,
        client: client,
        tag: tag
      )

      expect(client_tag).to be_valid
    end

    it "does not allow the same tag to be assigned twice" do
      user = create(:user)
      client = create(:client, user: user)
      tag = create(:tag, user: user)

      create(
        :client_tag,
        client: client,
        tag: tag
      )

      duplicate_client_tag = build(
        :client_tag,
        client: client,
        tag: tag
      )

      expect(duplicate_client_tag).not_to be_valid
      expect(duplicate_client_tag.errors[:tag_id])
        .to include("has already been assigned to this client")
    end

    it "does not allow another user's tag to be assigned" do
      client_owner = create(:user)
      tag_owner = create(:user)

      client = create(
        :client,
        user: client_owner
      )

      tag = create(
        :tag,
        user: tag_owner
      )

      client_tag = build(
        :client_tag,
        client: client,
        tag: tag
      )

      expect(client_tag).not_to be_valid
      expect(client_tag.errors[:tag])
        .to include("must belong to the same user as the client")
    end
  end
end