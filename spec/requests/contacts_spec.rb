# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Contacts", type: :request do
  let(:user) { create(:user) }
  let(:client) { create(:client, user: user) }

  describe "workspace isolation" do
    before do
      sign_in user
    end

    it "allows access to a contact belonging to a client in the same workspace" do
      teammate = create(:user, workspace: user.workspace)
      teammate_client = create(
        :client,
        user: teammate,
        workspace: user.workspace
      )
      contact = create(:contact, client: teammate_client)

      get client_contact_path(teammate_client, contact)

      expect(response).to have_http_status(:success)
    end

    it "does not allow access to a contact in another workspace" do
      other_client = create(:client)
      contact = create(:contact, client: other_client)

      expect do
        get client_contact_path(other_client, contact)
      end.to raise_error(ActiveRecord::RecordNotFound)
    end

    it "allows creating a contact for a client in the same workspace" do
      teammate = create(:user, workspace: user.workspace)
      teammate_client = create(
        :client,
        user: teammate,
        workspace: user.workspace
      )

      expect do
        post client_contacts_path(teammate_client), params: {
          contact: {
            first_name: "Lerato",
            last_name: "Mokoena",
            email: "lerato@example.com",
            phone: "+27 82 555 0101"
          }
        }
      end.to change(teammate_client.contacts, :count).by(1)
    end

    it "does not allow creating a contact for a client in another workspace" do
      other_client = create(:client)

      expect do
        post client_contacts_path(other_client), params: {
          contact: {
            first_name: "Lerato",
            last_name: "Mokoena",
            email: "lerato@example.com"
          }
        }
      end.to raise_error(ActiveRecord::RecordNotFound)
    end

    it "allows updating a contact belonging to the same workspace" do
      teammate = create(:user, workspace: user.workspace)
      teammate_client = create(
        :client,
        user: teammate,
        workspace: user.workspace
      )
      contact = create(:contact, client: teammate_client)

      patch client_contact_path(teammate_client, contact), params: {
        contact: {
          first_name: "Updated"
        }
      }

      expect(contact.reload.first_name).to eq("Updated")
    end

    it "allows deleting a contact belonging to the same workspace" do
      teammate = create(:user, workspace: user.workspace)
      teammate_client = create(
        :client,
        user: teammate,
        workspace: user.workspace
      )
      contact = create(:contact, client: teammate_client)

      expect do
        delete client_contact_path(teammate_client, contact)
      end.to change(Contact, :count).by(-1)
    end
  end
end