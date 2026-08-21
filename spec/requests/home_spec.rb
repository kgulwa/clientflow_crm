# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Home', type: :request do
  describe 'GET /' do
    context 'when the user is signed in' do
      let(:user) { create(:user) }

      before do
        sign_in user
      end

      it 'returns a successful response' do
        get root_path

        expect(response).to have_http_status(:success)
      end

      it "displays the user's first name" do
        get root_path

        expect(response.body).to include(user.first_name)
      end

      it "displays the signed-in user's client totals" do
        create(:client, user: user, status: :lead)
        create(:client, user: user, status: :active)
        create(:client, status: :active)

        get root_path

        expect(response.body).to include('Total clients')
        expect(response.body).to include('Active leads')
        expect(response.body).to include('Active clients')
      end

      it "displays the signed-in user's pending task count" do
        client = create(:client, user: user)

        create(:task, client: client, status: :pending)
        create(:task, client: client, status: :pending)
        create(:task, client: client, status: :completed)

        get root_path

        expect(response.body).to include('Pending tasks')
        expect(response.body).to include('2')
      end

      it 'displays pending and in-progress tasks in the upcoming tasks section' do
        client = create(
          :client,
          user: user,
          first_name: 'Jordan',
          last_name: 'Smith'
        )

        pending_task = create(
          :task,
          client: client,
          title: 'Send proposal',
          status: :pending,
          due_date: 2.days.from_now.to_date
        )

        in_progress_task = create(
          :task,
          client: client,
          title: 'Prepare contract',
          status: :in_progress,
          due_date: 3.days.from_now.to_date
        )

        get root_path

        expect(response.body).to include(pending_task.title)
        expect(response.body).to include(in_progress_task.title)
        expect(response.body).to include(client.full_name)
      end

      it 'does not display completed tasks in the upcoming tasks section' do
        client = create(:client, user: user)

        completed_task = create(
          :task,
          client: client,
          title: 'Completed follow-up',
          status: :completed,
          due_date: Date.current
        )

        get root_path

        expect(response.body).not_to include(completed_task.title)
      end

      it "does not display another user's tasks" do
        other_task = create(
          :task,
          title: 'Private task',
          status: :pending,
          due_date: Date.current
        )

        get root_path

        expect(response.body).not_to include(other_task.title)
      end

      it 'displays overdue tasks in a separate overdue tasks section' do
        client = create(
          :client,
          user: user,
          first_name: 'Lerato',
          last_name: 'Molefe'
        )

        overdue_task = create(
          :task,
          client: client,
          title: 'Overdue client follow-up',
          status: :pending,
          due_date: 2.days.ago.to_date
        )

        get root_path

        expect(response.body).to include('Overdue tasks')
        expect(response.body).to include(overdue_task.title)
        expect(response.body).to include(client.full_name)
        expect(response.body).to include('1 overdue task')
      end

      it 'does not display completed overdue tasks' do
        client = create(:client, user: user)

        completed_task = create(
          :task,
          client: client,
          title: 'Completed overdue task',
          status: :completed,
          due_date: 2.days.ago.to_date
        )

        get root_path

        expect(response.body).not_to include(completed_task.title)
      end

      it 'displays the overdue tasks empty state' do
        get root_path

        expect(response.body).to include('No overdue tasks')
      end

      it 'displays the five most recently added clients' do
        older_client = create(
          :client,
          user: user,
          first_name: 'Older',
          last_name: 'Client',
          created_at: 10.days.ago
        )

        recent_clients = Array.new(5) do |index|
          create(
            :client,
            user: user,
            first_name: "Recent#{index}",
            last_name: 'Client',
            created_at: index.days.ago
          )
        end

        get root_path

        expect(response.body).to include('Recently added clients')

        recent_clients.each do |client|
          expect(response.body).to include(client.full_name)
        end

        expect(response.body).not_to include(older_client.full_name)
      end

      it "does not display another user's recent clients" do
        other_client = create(
          :client,
          first_name: 'Private',
          last_name: 'Client'
        )

        get root_path

        expect(response.body).not_to include(other_client.full_name)
      end

      it 'displays lead counts for every status' do
        create(:lead, user: user, status: :new_lead)
        create(:lead, user: user, status: :contacted)
        create(:lead, user: user, status: :qualified)
        create(:lead, user: user, status: :converted)
        create(:lead, user: user, status: :lost)

        get root_path

        expect(response.body).to include('Leads by status')
        expect(response.body).to include('New')
        expect(response.body).to include('Contacted')
        expect(response.body).to include('Qualified')
        expect(response.body).to include('Converted')
        expect(response.body).to include('Lost')
      end

      it "does not include another user's leads in the lead totals" do
        create_list(:lead, 2, user: user, status: :qualified)
        create_list(:lead, 3, status: :qualified)

        get root_path

        expect(response.body).to include('Leads by status')
        expect(response.body).to include('Qualified')
      end

      it 'displays deal counts for every pipeline stage' do
        client = create(:client, user: user)

        create(:deal, client: client, stage: :prospecting)
        create(:deal, client: client, stage: :qualified)
        create(:deal, client: client, stage: :proposal_sent)
        create(:deal, client: client, stage: :negotiation)
        create(:deal, client: client, stage: :won)
        create(:deal, client: client, stage: :lost)

        get root_path

        expect(response.body).to include('Deals by stage')
        expect(response.body).to include('Prospecting')
        expect(response.body).to include('Qualified')
        expect(response.body).to include('Proposal sent')
        expect(response.body).to include('Negotiation')
        expect(response.body).to include('Won')
        expect(response.body).to include('Lost')
      end

      it 'displays the value of open deals' do
        client = create(:client, user: user)

        create(
          :deal,
          client: client,
          stage: :prospecting,
          value: 15_000
        )

        create(
          :deal,
          client: client,
          stage: :negotiation,
          value: 25_000
        )

        create(
          :deal,
          client: client,
          stage: :won,
          value: 100_000
        )

        create(
          :deal,
          client: client,
          stage: :lost,
          value: 50_000
        )

        get root_path

        expect(response.body).to include('Open pipeline value')
        expect(response.body).to include('R40,000.00')
      end

      it "does not include another user's deals in the pipeline" do
        user_client = create(:client, user: user)
        other_client = create(:client)

        create(
          :deal,
          client: user_client,
          stage: :prospecting,
          value: 12_345
        )

        create(
          :deal,
          client: other_client,
          stage: :prospecting,
          value: 99_999
        )

        get root_path

        expect(response.body).to include('R12,345.00')
        expect(response.body).not_to include('R99,999.00')
      end

      it 'displays the upcoming tasks empty state when there are no upcoming tasks' do
        get root_path

        expect(response.body).to include('No upcoming tasks')
      end
    end

    context 'when the user is not signed in' do
      it 'redirects to the sign-in page' do
        get root_path

        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end
end