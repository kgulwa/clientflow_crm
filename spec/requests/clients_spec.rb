require 'rails_helper'

RSpec.describe 'Clients', type: :request do
  let(:user) { create(:user) }

  describe 'authentication' do
    it 'redirects unauthenticated users to the sign-in page' do
      get clients_path

      expect(response).to redirect_to(new_user_session_path)
    end
  end

  context 'when the user is signed in' do
    before do
      sign_in user
    end

    describe 'GET /clients' do
      it 'returns a successful response' do
        get clients_path

        expect(response).to have_http_status(:success)
      end

      it 'shows clients belonging to the signed-in user' do
        client = create(
          :client,
          user: user,
          first_name: 'Owned',
          last_name: 'Client'
        )

        other_client = create(
          :client,
          first_name: 'Hidden',
          last_name: 'Client'
        )

        get clients_path

        expect(response.body).to include(client.full_name)
        expect(response.body).not_to include(other_client.full_name)
      end
    end

    describe 'GET /clients/:id' do
      it "returns the signed-in user's client" do
        client = create(:client, user: user)

        get client_path(client)

        expect(response).to have_http_status(:success)
        expect(response.body).to include(client.full_name)
      end

      it "does not allow access to another user's client" do
        other_client = create(:client)

        expect do
          get client_path(other_client)
        end.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    describe 'POST /clients' do
      let(:valid_attributes) do
        {
          first_name: 'Jordan',
          last_name: 'Smith',
          company_name: 'Smith Holdings',
          email: 'jordan@example.com',
          phone: '+27 82 555 0123',
          status: 'lead',
          notes: 'Requested a follow-up call.'
        }
      end

      it 'creates a client belonging to the signed-in user' do
        expect do
          post clients_path, params: { client: valid_attributes }
        end.to change(user.clients, :count).by(1)

        expect(user.clients.last.email).to eq('jordan@example.com')
      end

      it 'redirects to the created client' do
        post clients_path, params: { client: valid_attributes }

        expect(response).to redirect_to(user.clients.last)
      end

      it 'does not create an invalid client' do
        expect do
          post clients_path, params: {
            client: valid_attributes.merge(first_name: '')
          }
        end.not_to change(Client, :count)

        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    describe 'PATCH /clients/:id' do
      it "updates the signed-in user's client" do
        client = create(:client, user: user)

        patch client_path(client), params: {
          client: {
            first_name: 'Updated',
            status: 'active'
          }
        }

        expect(client.reload.first_name).to eq('Updated')
        expect(client).to be_active
      end
    end

    describe 'DELETE /clients/:id' do
      it "deletes the signed-in user's client" do
        client = create(:client, user: user)

        expect do
          delete client_path(client)
        end.to change(user.clients, :count).by(-1)

        expect(response).to redirect_to(clients_path)
      end
    end
  end
end
