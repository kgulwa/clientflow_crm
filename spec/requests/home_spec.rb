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

      it 'displays an overdue badge for overdue tasks' do
        client = create(:client, user: user)

        create(
          :task,
          client: client,
          title: 'Overdue follow-up',
          status: :pending,
          due_date: 2.days.ago.to_date
        )

        get root_path

        expect(response.body).to include('Overdue follow-up')
        expect(response.body).to include('Overdue')
        expect(response.body).to include('1 overdue task')
      end

      it 'displays the empty state when there are no outstanding tasks' do
        get root_path

        expect(response.body).to include('You are all caught up')
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