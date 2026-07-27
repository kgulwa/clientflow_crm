require "rails_helper"

RSpec.describe Client, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:user) }
  end

  describe "validations" do
    subject(:client) { build(:client) }

    it { is_expected.to validate_presence_of(:first_name) }
    it { is_expected.to validate_presence_of(:last_name) }
    it { is_expected.to validate_presence_of(:email) }
    it { is_expected.to validate_presence_of(:status) }
  end

  describe "statuses" do
    it "defines lead, active, and inactive statuses" do
      expect(described_class.statuses).to eq(
        "lead" => 0,
        "active" => 1,
        "inactive" => 2
      )
    end

    it "defaults new clients to lead status" do
      client = described_class.new

      expect(client).to be_lead
    end
  end

  describe "#full_name" do
    it "returns the client's first and last name" do
      client = build(
        :client,
        first_name: "Sarah",
        last_name: "Johnson"
      )

      expect(client.full_name).to eq("Sarah Johnson")
    end
  end
end