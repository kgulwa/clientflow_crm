# frozen_string_literal: true

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

      it 'orders clients from newest to oldest' do
        older_client = create(
          :client,
          user: user,
          first_name: 'Older',
          last_name: 'Client',
          created_at: 2.days.ago
        )

        newer_client = create(
          :client,
          user: user,
          first_name: 'Newer',
          last_name: 'Client',
          created_at: 1.day.ago
        )

        get clients_path

        expect(response.body.index(newer_client.full_name))
          .to be < response.body.index(older_client.full_name)
      end

      it 'searches clients by first name' do
        matching_client = create(
          :client,
          user: user,
          first_name: 'Jordan',
          last_name: 'Smith'
        )

        non_matching_client = create(
          :client,
          user: user,
          first_name: 'Taylor',
          last_name: 'Brown'
        )

        get clients_path(query: 'Jordan')

        expect(response.body).to include(matching_client.full_name)
        expect(response.body).not_to include(non_matching_client.full_name)
      end

      it 'searches clients by last name' do
        matching_client = create(
          :client,
          user: user,
          first_name: 'Jordan',
          last_name: 'Mokoena'
        )

        non_matching_client = create(
          :client,
          user: user,
          first_name: 'Taylor',
          last_name: 'Brown'
        )

        get clients_path(query: 'Mokoena')

        expect(response.body).to include(matching_client.full_name)
        expect(response.body).not_to include(non_matching_client.full_name)
      end

      it 'searches clients by company name' do
        matching_client = create(
          :client,
          user: user,
          first_name: 'Jordan',
          last_name: 'Smith',
          company_name: 'Acme Consulting'
        )

        non_matching_client = create(
          :client,
          user: user,
          first_name: 'Taylor',
          last_name: 'Brown',
          company_name: 'Bright Holdings'
        )

        get clients_path(query: 'Acme')

        expect(response.body).to include(matching_client.full_name)
        expect(response.body).not_to include(non_matching_client.full_name)
      end

      it 'searches clients by email address' do
        matching_client = create(
          :client,
          user: user,
          first_name: 'Jordan',
          last_name: 'Smith',
          email: 'jordan.search@example.com'
        )

        non_matching_client = create(
          :client,
          user: user,
          first_name: 'Taylor',
          last_name: 'Brown',
          email: 'taylor.other@example.com'
        )

        get clients_path(query: 'jordan.search')

        expect(response.body).to include(matching_client.full_name)
        expect(response.body).not_to include(non_matching_client.full_name)
      end

      it 'searches without matching letter case' do
        matching_client = create(
          :client,
          user: user,
          first_name: 'Jordan',
          last_name: 'Smith'
        )

        get clients_path(query: 'jOrDaN')

        expect(response.body).to include(matching_client.full_name)
      end

      it 'ignores whitespace around the search query' do
        matching_client = create(
          :client,
          user: user,
          first_name: 'Jordan',
          last_name: 'Smith'
        )

        get clients_path(query: '  Jordan  ')

        expect(response.body).to include(matching_client.full_name)
      end

      it 'filters clients by lead status' do
        lead_client = create(
          :client,
          user: user,
          first_name: 'Lead',
          last_name: 'Client',
          status: :lead
        )

        active_client = create(
          :client,
          user: user,
          first_name: 'Active',
          last_name: 'Client',
          status: :active
        )

        get clients_path(status: 'lead')

        expect(response.body).to include(lead_client.full_name)
        expect(response.body).not_to include(active_client.full_name)
      end

      it 'filters clients by active status' do
        active_client = create(
          :client,
          user: user,
          first_name: 'Active',
          last_name: 'Client',
          status: :active
        )

        inactive_client = create(
          :client,
          user: user,
          first_name: 'Inactive',
          last_name: 'Client',
          status: :inactive
        )

        get clients_path(status: 'active')

        expect(response.body).to include(active_client.full_name)
        expect(response.body).not_to include(inactive_client.full_name)
      end

      it 'filters clients by inactive status' do
        inactive_client = create(
          :client,
          user: user,
          first_name: 'Inactive',
          last_name: 'Client',
          status: :inactive
        )

        lead_client = create(
          :client,
          user: user,
          first_name: 'Lead',
          last_name: 'Client',
          status: :lead
        )

        get clients_path(status: 'inactive')

        expect(response.body).to include(inactive_client.full_name)
        expect(response.body).not_to include(lead_client.full_name)
      end

      it 'combines search and status filters' do
        matching_client = create(
          :client,
          user: user,
          first_name: 'Jordan',
          last_name: 'Smith',
          company_name: 'Acme Consulting',
          status: :active
        )

        wrong_status_client = create(
          :client,
          user: user,
          first_name: 'Jordan',
          last_name: 'Brown',
          company_name: 'Acme Logistics',
          status: :inactive
        )

        wrong_search_client = create(
          :client,
          user: user,
          first_name: 'Taylor',
          last_name: 'Mokoena',
          company_name: 'Bright Holdings',
          status: :active
        )

        get clients_path(query: 'Acme', status: 'active')

        expect(response.body).to include(matching_client.full_name)
        expect(response.body).not_to include(wrong_status_client.full_name)
        expect(response.body).not_to include(wrong_search_client.full_name)
      end

      it 'does not expose another user’s matching clients in search results' do
        owned_client = create(
          :client,
          user: user,
          first_name: 'Jordan',
          last_name: 'Owned'
        )

        other_client = create(
          :client,
          first_name: 'Jordan',
          last_name: 'Hidden'
        )

        get clients_path(query: 'Jordan')

        expect(response.body).to include(owned_client.full_name)
        expect(response.body).not_to include(other_client.full_name)
      end

      it 'ignores an invalid status filter' do
        client = create(
          :client,
          user: user,
          first_name: 'Visible',
          last_name: 'Client'
        )

        get clients_path(status: 'unknown')

        expect(response).to have_http_status(:success)
        expect(response.body).to include(client.full_name)
      end

      it 'shows a filtered empty state when no clients match' do
        create(
          :client,
          user: user,
          first_name: 'Jordan',
          last_name: 'Smith'
        )

        get clients_path(query: 'NoSuchClient')

        expect(response.body).to include('No matching clients')
        expect(response.body).to include('Clear filters')
        expect(response.body).not_to include('No clients yet')
      end

      it 'shows the new-client empty state when the user has no clients' do
        get clients_path

        expect(response.body).to include('No clients yet')
        expect(response.body).to include('Add your first client')
      end

      it 'preserves the search query in the form' do
        get clients_path(query: 'Jordan')

        expect(response.body).to include('value="Jordan"')
      end

      it 'preserves the selected status in the form' do
        get clients_path(status: 'active')

        expect(response.body).to include(
          '<option selected="selected" value="active">Active</option>'
        )
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

      it 'shows the client activity statistics' do
        client = create(
          :client,
          user: user,
          created_at: Time.zone.local(2026, 7, 1)
        )
        create(
          :task,
          client: client,
          status: :pending,
          due_date: 2.days.from_now.to_date
        )
        create(
          :task,
          client: client,
          status: :in_progress,
          due_date: 3.days.from_now.to_date
        )
        create(
          :task,
          client: client,
          status: :completed
        )
        create(
          :task,
          client: client,
          status: :pending,
          due_date: 2.days.ago.to_date
        )
        create_list(:note, 2, client: client)

        get client_path(client)

        expect(response.body).to include('Client summary')
        expect(response.body).to include('Open tasks')
        expect(response.body).to include('Completed tasks')
        expect(response.body).to include('Overdue tasks')
        expect(response.body).to include('Total notes')
        expect(response.body).to include('July 2026')
      end

      it 'does not include completed tasks in the open task count' do
        client = create(:client, user: user)
        create(:task, client: client, status: :pending)
        create(:task, client: client, status: :in_progress)
        create(:task, client: client, status: :completed)

        get client_path(client)

        expect(response.body).to include('Open tasks')
        expect(response.body).to include('2')
      end

      it 'shows zero statistics when the client has no tasks or notes' do
        client = create(:client, user: user)

        get client_path(client)

        expect(response.body).to include('Client summary')
        expect(response.body).to include('Open tasks')
        expect(response.body).to include('Completed tasks')
        expect(response.body).to include('Overdue tasks')
        expect(response.body).to include('Total notes')
       
        expect(response.body.scan(/>\s*0\s*</).length).to be >= 4
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