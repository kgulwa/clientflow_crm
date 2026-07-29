# frozen_string_literal: true

require "rails_helper"

RSpec.describe Tag, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:user) }

    it do
      is_expected.to have_many(:client_tags)
        .dependent(:destroy)
    end

    it do
      is_expected.to have_many(:clients)
        .through(:client_tags)
    end
  end

  describe "validations" do
    subject(:tag) { build(:tag) }

    it { is_expected.to validate_presence_of(:name) }

    it "does not allow duplicate names for the same user" do
      user = create(:user)

      create(
        :tag,
        user: user,
        name: "VIP"
      )

      duplicate_tag = build(
        :tag,
        user: user,
        name: "VIP"
      )

      expect(duplicate_tag).not_to be_valid
      expect(duplicate_tag.errors[:name])
        .to include("has already been taken")
    end

    it "treats tag names as case-insensitive for the same user" do
      user = create(:user)

      create(
        :tag,
        user: user,
        name: "VIP"
      )

      duplicate_tag = build(
        :tag,
        user: user,
        name: "vip"
      )

      expect(duplicate_tag).not_to be_valid
      expect(duplicate_tag.errors[:name])
        .to include("has already been taken")
    end

    it "allows different users to use the same tag name" do
      create(
        :tag,
        user: create(:user),
        name: "VIP"
      )

      other_user_tag = build(
        :tag,
        user: create(:user),
        name: "VIP"
      )

      expect(other_user_tag).to be_valid
    end
  end

  describe "normalization" do
    it "removes whitespace around the name" do
      tag = build(
        :tag,
        name: "  Hot Lead  "
      )

      tag.validate

      expect(tag.name).to eq("Hot Lead")
    end

    it "sets the default color when the color is nil" do
      tag = build(
        :tag,
        color: nil
      )

      tag.validate

      expect(tag.color).to eq("indigo")
    end

    it "sets the default color when the color is blank" do
      tag = build(
        :tag,
        color: ""
      )

      tag.validate

      expect(tag.color).to eq("indigo")
    end

    it "preserves a supplied color" do
      tag = build(
        :tag,
        color: "amber"
      )

      tag.validate

      expect(tag.color).to eq("amber")
    end
  end

  describe "dependent records" do
    it "destroys associated client tags" do
      user = create(:user)
      client = create(:client, user: user)
      tag = create(:tag, user: user)

      client_tag = create(
        :client_tag,
        client: client,
        tag: tag
      )

      tag.destroy

      expect(ClientTag.exists?(client_tag.id)).to be(false)
    end

    it "does not destroy clients when the tag is destroyed" do
      user = create(:user)
      client = create(:client, user: user)
      tag = create(:tag, user: user)

      create(
        :client_tag,
        client: client,
        tag: tag
      )

      tag.destroy

      expect(Client.exists?(client.id)).to be(true)
    end
  end
end