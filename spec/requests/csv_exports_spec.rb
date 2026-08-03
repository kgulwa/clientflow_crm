# frozen_string_literal: true

require "csv"
require "rails_helper"

RSpec.describe "CSV exports", type: :request do
  let(:user) { create(:user) }

  before do
    sign_in user
  end

  describe "GET /clients.csv" do
    it "returns a CSV attachment with the expected filename" do
      get clients_path(format: :csv)

      expect(response).to have_http_status(:success)
      expect(response.media_type).to eq("text/csv")
      expect(response.headers["Content-Disposition"]).to include(
        "clients-#{Date.current}.csv"
      )
    end

    it "exports only clients belonging to the signed-in user" do
      owned_client = create(
        :client,
        user: user,
        first_name: "Owned",
        last_name: "Client"
      )

      other_client = create(
        :client,
        first_name: "Hidden",
        last_name: "Client"
      )

      get clients_path(format: :csv)

      expect(response.body).to include(owned_client.first_name)
      expect(response.body).not_to include(other_client.first_name)
    end

    it "respects client search and status filters" do
      matching_client = create(
        :client,
        user: user,
        first_name: "Jordan",
        last_name: "Smith",
        status: :active
      )

      non_matching_client = create(
        :client,
        user: user,
        first_name: "Taylor",
        last_name: "Brown",
        status: :inactive
      )

      get clients_path(
        format: :csv,
        query: "Jordan",
        status: "active"
      )

      expect(response.body).to include(matching_client.first_name)
      expect(response.body).not_to include(non_matching_client.first_name)
    end

    it "exports all matching clients instead of only one paginated page" do
      create_list(:client, 12, user: user)

      get clients_path(format: :csv)

      rows = CSV.parse(response.body, headers: true)

      expect(rows.length).to eq(12)
    end
  end

  describe "GET /leads.csv" do
    it "returns a CSV attachment with the expected filename" do
      get leads_path(format: :csv)

      expect(response).to have_http_status(:success)
      expect(response.media_type).to eq("text/csv")
      expect(response.headers["Content-Disposition"]).to include(
        "leads-#{Date.current}.csv"
      )
    end

    it "exports only leads belonging to the signed-in user" do
      owned_lead = create(
        :lead,
        user: user,
        first_name: "Owned",
        last_name: "Lead"
      )

      other_lead = create(
        :lead,
        first_name: "Hidden",
        last_name: "Lead"
      )

      get leads_path(format: :csv)

      expect(response.body).to include(owned_lead.first_name)
      expect(response.body).not_to include(other_lead.first_name)
    end

    it "respects lead search, status, and source filters" do
      matching_lead = create(
        :lead,
        :qualified,
        :linkedin,
        user: user,
        first_name: "Amanda",
        last_name: "Dlamini"
      )

      non_matching_lead = create(
        :lead,
        user: user,
        first_name: "Thabo",
        last_name: "Molefe"
      )

      get leads_path(
        format: :csv,
        search: "Amanda",
        status: "qualified",
        source: "linkedin"
      )

      expect(response.body).to include(matching_lead.first_name)
      expect(response.body).not_to include(non_matching_lead.first_name)
      expect(response.headers["Content-Disposition"]).to include(
        "leads-qualified-linkedin-#{Date.current}.csv"
      )
    end

    it "exports all matching leads instead of only one paginated page" do
      create_list(:lead, 12, user: user)

      get leads_path(format: :csv)

      rows = CSV.parse(response.body, headers: true)

      expect(rows.length).to eq(12)
    end
  end

  describe "GET /deals.csv" do
    let(:client) { create(:client, user: user) }

    it "returns a CSV attachment with the expected filename" do
      get deals_path(format: :csv)

      expect(response).to have_http_status(:success)
      expect(response.media_type).to eq("text/csv")
      expect(response.headers["Content-Disposition"]).to include(
        "deals-#{Date.current}.csv"
      )
    end

    it "exports only deals belonging to the signed-in user" do
      owned_deal = create(
        :deal,
        client: client,
        title: "Owned opportunity"
      )

      other_deal = create(
        :deal,
        title: "Hidden opportunity"
      )

      get deals_path(format: :csv)

      expect(response.body).to include(owned_deal.title)
      expect(response.body).not_to include(other_deal.title)
    end

    it "respects deal search and stage filters" do
      matching_deal = create(
        :deal,
        client: client,
        title: "Website redesign",
        stage: :won
      )

      non_matching_deal = create(
        :deal,
        client: client,
        title: "Mobile application",
        stage: :prospecting
      )

      get deals_path(
        format: :csv,
        search: "Website",
        stage: "won"
      )

      expect(response.body).to include(matching_deal.title)
      expect(response.body).not_to include(non_matching_deal.title)
      expect(response.headers["Content-Disposition"]).to include(
        "deals-won-#{Date.current}.csv"
      )
    end

    it "exports all matching deals instead of only one paginated page" do
      create_list(:deal, 12, client: client)

      get deals_path(format: :csv)

      rows = CSV.parse(response.body, headers: true)

      expect(rows.length).to eq(12)
    end
  end
end