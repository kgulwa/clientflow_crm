# frozen_string_literal: true

require "rails_helper"

RSpec.describe Deal, type: :model do
  describe "associations" do
    it "belongs to a client" do
      association = described_class.reflect_on_association(:client)

      expect(association.macro).to eq(:belongs_to)
    end
  end

  describe "validations" do
    subject(:deal) { build(:deal) }

    it "is valid with valid attributes" do
      expect(deal).to be_valid
    end

    it "requires a title" do
      deal.title = nil

      expect(deal).not_to be_valid
      expect(deal.errors[:title]).to include("can't be blank")
    end

    it "requires a stage" do
      deal.stage = nil

      expect(deal).not_to be_valid
      expect(deal.errors[:stage]).to include("can't be blank")
    end

    it "allows a zero value" do
      deal.value = 0

      expect(deal).to be_valid
    end

    it "allows a positive value" do
      deal.value = 15_000.50

      expect(deal).to be_valid
    end

    it "does not allow a negative value" do
      deal.value = -1

      expect(deal).not_to be_valid
      expect(deal.errors[:value]).to include(
        "must be greater than or equal to 0"
      )
    end

    it "does not allow a non-numeric value" do
      deal.value = "not a number"

      expect(deal).not_to be_valid
      expect(deal.errors[:value]).to include("is not a number")
    end
  end

  describe "enums" do
    it "defines the expected stages" do
      expect(described_class.stages).to eq(
        "prospecting" => 0,
        "qualified" => 1,
        "proposal_sent" => 2,
        "negotiation" => 3,
        "won" => 4,
        "lost" => 5
      )
    end
  end

  describe ".recent_first" do
    it "returns the newest deals first" do
      older_deal = create(
        :deal,
        created_at: 2.days.ago
      )

      newer_deal = create(
        :deal,
        created_at: 1.day.ago
      )

      expect(described_class.recent_first).to eq(
        [newer_deal, older_deal]
      )
    end
  end

  describe "#display_stage" do
    it "titleizes a single-word stage" do
      deal = build(:deal, stage: :qualified)

      expect(deal.display_stage).to eq("Qualified")
    end

    it "titleizes a multi-word stage" do
      deal = build(:deal, stage: :proposal_sent)

      expect(deal.display_stage).to eq("Proposal Sent")
    end
  end

  describe "#formatted_value" do
    it "returns the value as a float" do
      deal = build(:deal, value: 12_500.75)

      expect(deal.formatted_value).to eq(12_500.75)
    end
  end

  describe "client ownership" do
    it "is available through the client's user" do
      user = create(:user)
      client = create(:client, user: user)
      deal = create(:deal, client: client)

      expect(user.deals).to contain_exactly(deal)
    end

    it "is destroyed when its client is destroyed" do
      client = create(:client)
      deal = create(:deal, client: client)

      client.destroy

      expect(described_class.exists?(deal.id)).to be(false)
    end
  end
end