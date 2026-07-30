# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Deals", type: :request do
  let(:user) { create(:user) }
  let(:client) { create(:client, user: user) }

  describe "authentication" do
    it "redirects unauthenticated users to the sign-in page" do
      get deals_path

      expect(response).to redirect_to(new_user_session_path)
    end
  end

  context "when the user is signed in" do
    before do
      sign_in user
    end

    describe "GET /deals" do
      it "returns a successful response" do
        get deals_path

        expect(response).to have_http_status(:success)
      end

      it "shows deals belonging to the signed-in user" do
        owned_deal = create(
          :deal,
          client: client,
          title: "Owned opportunity"
        )

        other_deal = create(
          :deal,
          title: "Hidden opportunity"
        )

        get deals_path

        expect(response.body).to include(owned_deal.title)
        expect(response.body).not_to include(other_deal.title)
      end

      it "orders deals from newest to oldest" do
        older_deal = create(
          :deal,
          client: client,
          title: "Older opportunity",
          created_at: 2.days.ago
        )

        newer_deal = create(
          :deal,
          client: client,
          title: "Newer opportunity",
          created_at: 1.day.ago
        )

        get deals_path

        expect(response.body.index(newer_deal.title))
          .to be < response.body.index(older_deal.title)
      end

      it "shows the empty state when the user has no deals" do
        get deals_path

        expect(response.body).to include("No deals yet")
        expect(response.body).to include("Add your first deal")
      end

      it "searches deals by title" do
        matching_deal = create(
          :deal,
          client: client,
          title: "Website redesign"
        )

        non_matching_deal = create(
          :deal,
          client: client,
          title: "Mobile application"
        )

        get deals_path, params: {
          search: "website"
        }

        expect(response).to have_http_status(:success)
        expect(response.body).to include(matching_deal.title)
        expect(response.body).not_to include(non_matching_deal.title)
      end

      it "searches deals by client name" do
        matching_client = create(
          :client,
          user: user,
          first_name: "Thando",
          last_name: "Mokoena"
        )

        other_client = create(
          :client,
          user: user,
          first_name: "Lerato",
          last_name: "Dlamini"
        )

        matching_deal = create(
          :deal,
          client: matching_client,
          title: "Website opportunity"
        )

        non_matching_deal = create(
          :deal,
          client: other_client,
          title: "Support opportunity"
        )

        get deals_path, params: {
          search: "Thando Mokoena"
        }

        expect(response.body).to include(matching_deal.title)
        expect(response.body).not_to include(non_matching_deal.title)
      end

      it "filters deals by stage" do
        won_deal = create(
          :deal,
          client: client,
          title: "Won opportunity",
          stage: :won
        )

        prospecting_deal = create(
          :deal,
          client: client,
          title: "Prospecting opportunity",
          stage: :prospecting
        )

        get deals_path, params: {
          stage: "won"
        }

        expect(response.body).to include(won_deal.title)
        expect(response.body).not_to include(prospecting_deal.title)
      end

      it "combines search and stage filters" do
        matching_deal = create(
          :deal,
          client: client,
          title: "Website redesign",
          stage: :won
        )

        wrong_stage = create(
          :deal,
          client: client,
          title: "Website maintenance",
          stage: :prospecting
        )

        wrong_search = create(
          :deal,
          client: client,
          title: "Mobile application",
          stage: :won
        )

        get deals_path, params: {
          search: "website",
          stage: "won"
        }

        expect(response.body).to include(matching_deal.title)
        expect(response.body).not_to include(wrong_stage.title)
        expect(response.body).not_to include(wrong_search.title)
      end

      it "shows the no matching deals state when filters return no results" do
        create(
          :deal,
          client: client,
          title: "Website redesign"
        )

        get deals_path, params: {
          search: "Something impossible"
        }

        expect(response.body).to include("No matching deals")
        expect(response.body).to include("Clear filters")
        expect(response.body).not_to include("No deals yet")
      end

      it "preserves the selected filters in the form" do
        get deals_path, params: {
          search: "website",
          stage: "negotiation"
        }

        expect(response.body).to include('value="website"')
        expect(response.body).to include(
          '<option selected="selected" value="negotiation">Negotiation</option>'
        )
      end

      it "does not show the clear button when no filters are active" do
        create(:deal, client: client)

        get deals_path

        expect(response.body).not_to include(">Clear<")
      end
    end

    describe "GET /deals/:id" do
      it "returns the signed-in user's deal" do
        deal = create(
          :deal,
          client: client,
          title: "Mobile application project"
        )

        get deal_path(deal)

        expect(response).to have_http_status(:success)
        expect(response.body).to include(deal.title)
        expect(response.body).to include(client.full_name)
      end

      it "does not allow access to another user's deal" do
        other_deal = create(:deal)

        expect do
          get deal_path(other_deal)
        end.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    describe "GET /deals/new" do
      it "returns a successful response" do
        client

        get new_deal_path

        expect(response).to have_http_status(:success)
        expect(response.body).to include("Add a new deal")
      end

      it "only shows clients belonging to the signed-in user" do
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

        get new_deal_path

        expect(response.body).to include(owned_client.full_name)
        expect(response.body).not_to include(other_client.full_name)
      end
    end

    describe "GET /deals/:id/edit" do
      it "returns the edit page for the signed-in user's deal" do
        deal = create(:deal, client: client)

        get edit_deal_path(deal)

        expect(response).to have_http_status(:success)
        expect(response.body).to include("Edit #{deal.title}")
      end

      it "does not allow editing another user's deal" do
        other_deal = create(:deal)

        expect do
          get edit_deal_path(other_deal)
        end.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    describe "POST /deals" do
      let(:valid_attributes) do
        {
          client_id: client.id,
          title: "New software platform",
          stage: "qualified",
          value: "45000.50",
          expected_close_date: "2026-09-30",
          description: "A possible software development project."
        }
      end

      it "creates a deal for one of the signed-in user's clients" do
        expect do
          post deals_path, params: { deal: valid_attributes }
        end.to change(user.deals, :count).by(1)

        created_deal = user.deals.last

        expect(created_deal.title).to eq("New software platform")
        expect(created_deal.client).to eq(client)
        expect(created_deal).to be_qualified
        expect(created_deal.value).to eq(45_000.50)
      end

      it "redirects to the created deal" do
        post deals_path, params: { deal: valid_attributes }

        expect(response).to redirect_to(user.deals.last)
      end

      it "does not create an invalid deal" do
        expect do
          post deals_path, params: {
            deal: valid_attributes.merge(title: "")
          }
        end.not_to change(Deal, :count)

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to include(
          "Title can&#39;t be blank"
        )
      end

      it "does not create a deal for another user's client" do
        other_client = create(:client)

        expect do
          post deals_path, params: {
            deal: valid_attributes.merge(client_id: other_client.id)
          }
        end.not_to change(Deal, :count)

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to include(
          "Client must belong to your account"
        )
      end
    end

    describe "PATCH /deals/:id" do
      it "updates the signed-in user's deal" do
        deal = create(:deal, client: client)

        patch deal_path(deal), params: {
          deal: {
            title: "Updated opportunity",
            stage: "negotiation",
            value: "60000.00"
          }
        }

        deal.reload

        expect(deal.title).to eq("Updated opportunity")
        expect(deal).to be_negotiation
        expect(deal.value).to eq(60_000.00)
        expect(response).to redirect_to(deal_path(deal))
      end

      it "allows moving a deal to another owned client" do
        deal = create(:deal, client: client)
        other_owned_client = create(:client, user: user)

        patch deal_path(deal), params: {
          deal: {
            client_id: other_owned_client.id
          }
        }

        expect(deal.reload.client).to eq(other_owned_client)
        expect(response).to redirect_to(deal_path(deal))
      end

      it "does not move a deal to another user's client" do
        deal = create(:deal, client: client)
        other_client = create(:client)

        patch deal_path(deal), params: {
          deal: {
            client_id: other_client.id
          }
        }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to include(
          "Client must belong to your account"
        )
        expect(deal.reload.client).to eq(client)
      end

      it "does not update another user's deal" do
        other_deal = create(
          :deal,
          title: "Original opportunity"
        )

        expect do
          patch deal_path(other_deal), params: {
            deal: {
              title: "Changed opportunity"
            }
          }
        end.to raise_error(ActiveRecord::RecordNotFound)

        expect(other_deal.reload.title).to eq("Original opportunity")
      end

      it "renders the edit page when the update is invalid" do
        deal = create(:deal, client: client)

        patch deal_path(deal), params: {
          deal: {
            title: ""
          }
        }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to include(
          "Title can&#39;t be blank"
        )
      end
    end

    describe "DELETE /deals/:id" do
      it "deletes the signed-in user's deal" do
        deal = create(:deal, client: client)

        expect do
          delete deal_path(deal)
        end.to change(user.deals, :count).by(-1)

        expect(response).to redirect_to(deals_path)
      end

      it "does not delete another user's deal" do
        other_deal = create(:deal)

        expect do
          expect do
            delete deal_path(other_deal)
          end.to raise_error(ActiveRecord::RecordNotFound)
        end.not_to change(Deal, :count)
      end
    end
  end
end