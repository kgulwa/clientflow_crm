# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Leads", type: :request do
  let(:user) { create(:user) }

  describe "authentication" do
    it "redirects unauthenticated users to the sign-in page" do
      get leads_path

      expect(response).to redirect_to(new_user_session_path)
    end
  end

  context "when the user is signed in" do
    before do
      sign_in user
    end

    describe "GET /leads" do
      it "returns a successful response" do
        get leads_path

        expect(response).to have_http_status(:success)
      end

      it "shows leads belonging to the signed-in user" do
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

        get leads_path

        expect(response.body).to include(owned_lead.full_name)
        expect(response.body).not_to include(other_lead.full_name)
      end

      it "orders leads from newest to oldest" do
        older_lead = create(
          :lead,
          user: user,
          first_name: "Older",
          last_name: "Lead",
          created_at: 2.days.ago
        )

        newer_lead = create(
          :lead,
          user: user,
          first_name: "Newer",
          last_name: "Lead",
          created_at: 1.day.ago
        )

        get leads_path

        expect(response.body.index(newer_lead.full_name))
          .to be < response.body.index(older_lead.full_name)
      end

      it "searches leads by first name" do
        matching_lead = create(
          :lead,
          user: user,
          first_name: "Naledi",
          last_name: "Mokoena"
        )

        other_lead = create(
          :lead,
          user: user,
          first_name: "Sipho",
          last_name: "Dlamini"
        )

        get leads_path, params: { search: "Naledi" }

        expect(response.body).to include(matching_lead.full_name)
        expect(response.body).not_to include(other_lead.full_name)
      end

      it "searches leads by last name" do
        matching_lead = create(
          :lead,
          user: user,
          first_name: "Ayanda",
          last_name: "Khumalo"
        )

        other_lead = create(
          :lead,
          user: user,
          first_name: "Lerato",
          last_name: "Maseko"
        )

        get leads_path, params: { search: "Khumalo" }

        expect(response.body).to include(matching_lead.full_name)
        expect(response.body).not_to include(other_lead.full_name)
      end

      it "searches leads by company name" do
        matching_lead = create(
          :lead,
          user: user,
          first_name: "Zanele",
          last_name: "Ndlovu",
          company_name: "Ubuntu Digital"
        )

        other_lead = create(
          :lead,
          user: user,
          first_name: "Thabo",
          last_name: "Molefe",
          company_name: "Molefe Logistics"
        )

        get leads_path, params: { search: "Ubuntu" }

        expect(response.body).to include(matching_lead.full_name)
        expect(response.body).not_to include(other_lead.full_name)
      end

      it "searches leads by email" do
        matching_lead = create(
          :lead,
          user: user,
          first_name: "Buhle",
          last_name: "Nkosi",
          email: "buhle.nkosi@example.com"
        )

        other_lead = create(
          :lead,
          user: user,
          first_name: "Sizwe",
          last_name: "Zulu",
          email: "sizwe.zulu@example.com"
        )

        get leads_path, params: { search: "buhle.nkosi" }

        expect(response.body).to include(matching_lead.full_name)
        expect(response.body).not_to include(other_lead.full_name)
      end

      it "searches without matching letter case" do
        lead = create(
          :lead,
          user: user,
          first_name: "Nomvula",
          last_name: "Dube"
        )

        get leads_path, params: { search: "nomvula" }

        expect(response.body).to include(lead.full_name)
      end

      it "filters leads by status" do
        qualified_lead = create(
          :lead,
          :qualified,
          user: user,
          first_name: "Qualified",
          last_name: "Lead"
        )

        new_lead = create(
          :lead,
          user: user,
          first_name: "New",
          last_name: "Lead"
        )

        get leads_path, params: { status: "qualified" }

        expect(response.body).to include(qualified_lead.full_name)
        expect(response.body).not_to include(new_lead.full_name)
      end

      it "filters leads by source" do
        linkedin_lead = create(
          :lead,
          :linkedin,
          user: user,
          first_name: "LinkedIn",
          last_name: "Lead"
        )

        website_lead = create(
          :lead,
          user: user,
          first_name: "Website",
          last_name: "Lead"
        )

        get leads_path, params: { source: "linkedin" }

        expect(response.body).to include(linkedin_lead.full_name)
        expect(response.body).not_to include(website_lead.full_name)
      end

      it "combines search and status filters" do
        matching_lead = create(
          :lead,
          :qualified,
          user: user,
          first_name: "Lindiwe",
          last_name: "Mahlangu",
          company_name: "Mahlangu Media"
        )

        wrong_status_lead = create(
          :lead,
          user: user,
          first_name: "Lindiwe",
          last_name: "Nene",
          company_name: "Nene Consulting"
        )

        wrong_search_lead = create(
          :lead,
          :qualified,
          user: user,
          first_name: "Karabo",
          last_name: "Mokoena",
          company_name: "Mokoena Holdings"
        )

        get leads_path, params: {
          search: "Lindiwe",
          status: "qualified"
        }

        expect(response.body).to include(matching_lead.full_name)
        expect(response.body).not_to include(wrong_status_lead.full_name)
        expect(response.body).not_to include(wrong_search_lead.full_name)
      end

      it "combines search and source filters" do
        matching_lead = create(
          :lead,
          :referral,
          user: user,
          first_name: "Refilwe",
          last_name: "Mokoena",
          company_name: "Refilwe Designs"
        )

        wrong_source_lead = create(
          :lead,
          user: user,
          first_name: "Refilwe",
          last_name: "Zulu",
          company_name: "Zulu Designs"
        )

        wrong_search_lead = create(
          :lead,
          :referral,
          user: user,
          first_name: "Tshepo",
          last_name: "Molefe",
          company_name: "Molefe Designs"
        )

        get leads_path, params: {
          search: "Refilwe",
          source: "referral"
        }

        expect(response.body).to include(matching_lead.full_name)
        expect(response.body).not_to include(wrong_source_lead.full_name)
        expect(response.body).not_to include(wrong_search_lead.full_name)
      end

      it "combines search, status, and source filters" do
        matching_lead = create(
          :lead,
          :qualified,
          :linkedin,
          user: user,
          first_name: "Amanda",
          last_name: "Dlamini",
          company_name: "Dlamini Tech"
        )

        wrong_status_lead = create(
          :lead,
          :linkedin,
          user: user,
          first_name: "Amanda",
          last_name: "Mokoena",
          company_name: "Mokoena Tech"
        )

        wrong_source_lead = create(
          :lead,
          :qualified,
          user: user,
          first_name: "Amanda",
          last_name: "Ndlovu",
          company_name: "Ndlovu Tech"
        )

        get leads_path, params: {
          search: "Amanda",
          status: "qualified",
          source: "linkedin"
        }

        expect(response.body).to include(matching_lead.full_name)
        expect(response.body).not_to include(wrong_status_lead.full_name)
        expect(response.body).not_to include(wrong_source_lead.full_name)
      end

      it "ignores an invalid status filter" do
        lead = create(
          :lead,
          user: user,
          first_name: "Visible",
          last_name: "Lead"
        )

        get leads_path, params: { status: "invalid_status" }

        expect(response).to have_http_status(:success)
        expect(response.body).to include(lead.full_name)
      end

      it "ignores an invalid source filter" do
        lead = create(
          :lead,
          user: user,
          first_name: "Visible",
          last_name: "Source"
        )

        get leads_path, params: { source: "invalid_source" }

        expect(response).to have_http_status(:success)
        expect(response.body).to include(lead.full_name)
      end

      it "shows a filtered empty state when no leads match" do
        create(
          :lead,
          user: user,
          first_name: "Existing",
          last_name: "Lead"
        )

        get leads_path, params: { search: "Missing" }

        expect(response.body).to include("No matching leads")
        expect(response.body).to include("Clear filters")
        expect(response.body).not_to include("No leads yet")
      end

      it "shows the empty state when the user has no leads" do
        get leads_path

        expect(response.body).to include("No leads yet")
        expect(response.body).to include("Add your first lead")
      end
    end

    describe "GET /leads/:id" do
      it "returns the signed-in user's lead" do
        lead = create(:lead, user: user)

        get lead_path(lead)

        expect(response).to have_http_status(:success)
        expect(response.body).to include(lead.full_name)
        expect(response.body).to include(lead.email)
      end

      it "does not allow access to another user's lead" do
        other_lead = create(:lead)

        expect do
          get lead_path(other_lead)
        end.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    describe "GET /leads/new" do
      it "returns a successful response" do
        get new_lead_path

        expect(response).to have_http_status(:success)
        expect(response.body).to include("Add a new lead")
      end
    end

    describe "GET /leads/:id/edit" do
      it "returns the edit page for the signed-in user's lead" do
        lead = create(:lead, user: user)

        get edit_lead_path(lead)

        expect(response).to have_http_status(:success)
        expect(response.body).to include("Edit #{lead.full_name}")
      end
    end

    describe "POST /leads" do
      let(:valid_attributes) do
        {
          first_name: "Ayanda",
          last_name: "Dlamini",
          company_name: "Dlamini Holdings",
          email: "ayanda@example.com",
          phone: "+27 82 555 0102",
          source: "referral",
          status: "new_lead",
          notes: "Requested more information."
        }
      end

      it "creates a lead belonging to the signed-in user" do
        expect do
          post leads_path, params: { lead: valid_attributes }
        end.to change(user.leads, :count).by(1)

        created_lead = user.leads.last

        expect(created_lead.email).to eq("ayanda@example.com")
        expect(created_lead).to be_referral
        expect(created_lead).to be_new_lead
      end

      it "redirects to the created lead" do
        post leads_path, params: { lead: valid_attributes }

        expect(response).to redirect_to(user.leads.last)
      end

      it "does not create an invalid lead" do
        expect do
          post leads_path, params: {
            lead: valid_attributes.merge(first_name: "")
          }
        end.not_to change(Lead, :count)

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to include(
          "First name can&#39;t be blank"
        )
      end
    end

    describe "PATCH /leads/:id" do
      it "updates the signed-in user's lead" do
        lead = create(:lead, user: user)

        patch lead_path(lead), params: {
          lead: {
            first_name: "Updated",
            source: "linkedin",
            status: "qualified"
          }
        }

        lead.reload

        expect(lead.first_name).to eq("Updated")
        expect(lead).to be_linkedin
        expect(lead).to be_qualified
        expect(response).to redirect_to(lead_path(lead))
      end

      it "does not update another user's lead" do
        other_lead = create(:lead, first_name: "Original")

        expect do
          patch lead_path(other_lead), params: {
            lead: {
              first_name: "Changed"
            }
          }
        end.to raise_error(ActiveRecord::RecordNotFound)

        expect(other_lead.reload.first_name).to eq("Original")
      end

      it "renders the edit page when the update is invalid" do
        lead = create(:lead, user: user)

        patch lead_path(lead), params: {
          lead: {
            first_name: ""
          }
        }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to include(
          "First name can&#39;t be blank"
        )
      end
    end

    describe "DELETE /leads/:id" do
      it "deletes the signed-in user's lead" do
        lead = create(:lead, user: user)

        expect do
          delete lead_path(lead)
        end.to change(user.leads, :count).by(-1)

        expect(response).to redirect_to(leads_path)
      end

      it "does not delete another user's lead" do
        other_lead = create(:lead)

        expect do
          expect do
            delete lead_path(other_lead)
          end.to raise_error(ActiveRecord::RecordNotFound)
        end.not_to change(Lead, :count)
      end
    end
  end
end