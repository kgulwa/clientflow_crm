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

  describe ".search" do
    let(:user) { create(:user) }

    let(:matching_client) do
      create(
        :client,
        user: user,
        first_name: "Thando",
        last_name: "Mokoena"
      )
    end

    let(:other_client) do
      create(
        :client,
        user: user,
        first_name: "Lerato",
        last_name: "Dlamini"
      )
    end

    let!(:title_match) do
      create(
        :deal,
        client: other_client,
        title: "Website redesign"
      )
    end

    let!(:client_match) do
      create(
        :deal,
        client: matching_client,
        title: "Mobile application"
      )
    end

    let!(:non_match) do
      create(
        :deal,
        client: other_client,
        title: "Accounting support"
      )
    end

    it "returns all deals when the query is blank" do
      expect(described_class.search("")).to contain_exactly(
        title_match,
        client_match,
        non_match
      )
    end

    it "searches by deal title" do
      expect(described_class.search("website")).to contain_exactly(
        title_match
      )
    end

    it "searches by client first name" do
      expect(described_class.search("Thando")).to contain_exactly(
        client_match
      )
    end

    it "searches by client last name" do
      expect(described_class.search("Mokoena")).to contain_exactly(
        client_match
      )
    end

    it "searches by the client's full name" do
      expect(
        described_class.search("Thando Mokoena")
      ).to contain_exactly(client_match)
    end

    it "is case-insensitive" do
      expect(described_class.search("WEBSITE")).to contain_exactly(
        title_match
      )
    end

    it "escapes SQL wildcard characters" do
      percentage_deal = create(
        :deal,
        client: matching_client,
        title: "50% deposit"
      )

      expect(described_class.search("50%")).to contain_exactly(
        percentage_deal
      )
    end
  end

  describe ".with_stage" do
    let!(:prospecting_deal) do
      create(:deal, stage: :prospecting)
    end

    let!(:won_deal) do
      create(:deal, stage: :won)
    end

    it "returns all deals when the stage is blank" do
      expect(described_class.with_stage("")).to contain_exactly(
        prospecting_deal,
        won_deal
      )
    end

    it "returns deals matching the selected stage" do
      expect(described_class.with_stage("won")).to contain_exactly(
        won_deal
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