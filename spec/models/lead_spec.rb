# frozen_string_literal: true

require "rails_helper"

RSpec.describe Lead, type: :model do
  describe "associations" do
    it "belongs to a user" do
      association = described_class.reflect_on_association(:user)

      expect(association.macro).to eq(:belongs_to)
    end
  end

  describe "validations" do
    subject(:lead) { build(:lead) }

    it "is valid with valid attributes" do
      expect(lead).to be_valid
    end

    it "requires a first name" do
      lead.first_name = nil

      expect(lead).not_to be_valid
      expect(lead.errors[:first_name]).to include("can't be blank")
    end

    it "requires a last name" do
      lead.last_name = nil

      expect(lead).not_to be_valid
      expect(lead.errors[:last_name]).to include("can't be blank")
    end

    it "requires an email address" do
      lead.email = nil

      expect(lead).not_to be_valid
      expect(lead.errors[:email]).to include("can't be blank")
    end

    it "requires a source" do
      lead.source = nil

      expect(lead).not_to be_valid
      expect(lead.errors[:source]).to include("can't be blank")
    end

    it "requires a status" do
      lead.status = nil

      expect(lead).not_to be_valid
      expect(lead.errors[:status]).to include("can't be blank")
    end
  end

  describe "enums" do
    it "defines the expected statuses" do
      expect(described_class.statuses).to eq(
        "new_lead" => 0,
        "contacted" => 1,
        "qualified" => 2,
        "lost" => 3,
        "converted" => 4
      )
    end

    it "defines the expected sources" do
      expect(described_class.sources).to eq(
        "website" => 0,
        "referral" => 1,
        "linkedin" => 2,
        "email" => 3,
        "phone" => 4,
        "walk_in" => 5,
        "other" => 6
      )
    end
  end

  describe ".search" do
    let(:user) { create(:user) }

    it "returns all leads when the query is blank" do
      first_lead = create(:lead, user: user)
      second_lead = create(:lead, user: user)

      expect(described_class.search("")).to contain_exactly(
        first_lead,
        second_lead
      )
    end

    it "searches by first name" do
      matching_lead = create(
        :lead,
        user: user,
        first_name: "Thando",
        last_name: "Mokoena"
      )

      create(
        :lead,
        user: user,
        first_name: "Lerato",
        last_name: "Nkosi"
      )

      expect(described_class.search("Thando")).to contain_exactly(
        matching_lead
      )
    end

    it "searches by last name" do
      matching_lead = create(
        :lead,
        user: user,
        first_name: "Thando",
        last_name: "Mokoena",
        company_name: "Ubuntu Holdings"
      )

      create(
        :lead,
        user: user,
        first_name: "Lerato",
        last_name: "Nkosi",
        company_name: "Imbokodo Consulting"
      )

      expect(described_class.search("Mokoena")).to contain_exactly(
        matching_lead
      )
    end

    it "searches by company name" do
      matching_lead = create(
        :lead,
        user: user,
        company_name: "Ubuntu Holdings"
      )

      create(
        :lead,
        user: user,
        company_name: "Imbokodo Consulting"
      )

      expect(described_class.search("Ubuntu")).to contain_exactly(
        matching_lead
      )
    end

    it "searches by email address" do
      matching_lead = create(
        :lead,
        user: user,
        email: "thando.search@example.com"
      )

      create(
        :lead,
        user: user,
        email: "lerato.other@example.com"
      )

      expect(described_class.search("thando.search")).to contain_exactly(
        matching_lead
      )
    end

    it "searches without matching letter case" do
      matching_lead = create(
        :lead,
        user: user,
        first_name: "Thando"
      )

      expect(described_class.search("tHaNdO")).to contain_exactly(
        matching_lead
      )
    end

    it "escapes SQL wildcard characters in the query" do
      matching_lead = create(
        :lead,
        user: user,
        company_name: "Growth_Company"
      )

      create(
        :lead,
        user: user,
        company_name: "GrowthXCompany"
      )

      expect(described_class.search("Growth_")).to contain_exactly(
        matching_lead
      )
    end
  end

  describe ".with_status" do
    let(:user) { create(:user) }

    it "returns all leads when the status is blank" do
      new_lead = create(:lead, user: user, status: :new_lead)
      qualified_lead = create(:lead, user: user, status: :qualified)

      expect(described_class.with_status("")).to contain_exactly(
        new_lead,
        qualified_lead
      )
    end

    it "returns leads matching the supplied status" do
      qualified_lead = create(
        :lead,
        user: user,
        status: :qualified
      )

      create(
        :lead,
        user: user,
        status: :contacted
      )

      expect(described_class.with_status("qualified")).to contain_exactly(
        qualified_lead
      )
    end

    it "returns all leads when the status is invalid" do
      first_lead = create(:lead, user: user)
      second_lead = create(:lead, user: user)

      expect(described_class.with_status("unknown")).to contain_exactly(
        first_lead,
        second_lead
      )
    end
  end

  describe ".with_source" do
    let(:user) { create(:user) }

    it "returns all leads when the source is blank" do
      website_lead = create(:lead, user: user, source: :website)
      referral_lead = create(:lead, user: user, source: :referral)

      expect(described_class.with_source("")).to contain_exactly(
        website_lead,
        referral_lead
      )
    end

    it "returns leads matching the supplied source" do
      linkedin_lead = create(
        :lead,
        user: user,
        source: :linkedin
      )

      create(
        :lead,
        user: user,
        source: :website
      )

      expect(described_class.with_source("linkedin")).to contain_exactly(
        linkedin_lead
      )
    end

    it "returns all leads when the source is invalid" do
      first_lead = create(:lead, user: user)
      second_lead = create(:lead, user: user)

      expect(described_class.with_source("unknown")).to contain_exactly(
        first_lead,
        second_lead
      )
    end
  end

  describe "#full_name" do
    it "combines the first and last name" do
      lead = build(
        :lead,
        first_name: "Thando",
        last_name: "Mokoena"
      )

      expect(lead.full_name).to eq("Thando Mokoena")
    end

    it "does not leave unnecessary surrounding whitespace" do
      lead = build(
        :lead,
        first_name: "Thando",
        last_name: ""
      )

      expect(lead.full_name).to eq("Thando")
    end
  end

  describe "#display_status" do
    it "displays new_lead as New" do
      lead = build(:lead, status: :new_lead)

      expect(lead.display_status).to eq("New")
    end

    it "titleizes other statuses" do
      lead = build(:lead, status: :qualified)

      expect(lead.display_status).to eq("Qualified")
    end
  end
end