# frozen_string_literal: true

require "rails_helper"

RSpec.describe Contact, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:client) }
  end

  describe "validations" do
    subject(:contact) { build(:contact) }

    it { is_expected.to validate_presence_of(:first_name) }
    it { is_expected.to validate_presence_of(:last_name) }
    it { is_expected.to validate_presence_of(:email) }
  end

  describe ".primary_first" do
    let(:client) { create(:client) }

    let!(:zulu_contact) do
      create(
        :contact,
        client: client,
        first_name: "Zanele",
        last_name: "Zulu"
      )
    end

    let!(:primary_contact) do
      create(
        :contact,
        :primary,
        client: client,
        first_name: "Sarah",
        last_name: "Jones"
      )
    end

    let!(:adams_contact) do
      create(
        :contact,
        client: client,
        first_name: "David",
        last_name: "Adams"
      )
    end

    it "returns primary contacts first" do
      expect(described_class.primary_first.first).to eq(primary_contact)
    end

    it "orders remaining contacts alphabetically by surname" do
      expect(described_class.primary_first).to eq(
        [
          primary_contact,
          adams_contact,
          zulu_contact
        ]
      )
    end
  end

  describe "#full_name" do
    it "returns the contact's first and last name" do
      contact = build(
        :contact,
        first_name: "John",
        last_name: "Smith"
      )

      expect(contact.full_name).to eq("John Smith")
    end
  end
end