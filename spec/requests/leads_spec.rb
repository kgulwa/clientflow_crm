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