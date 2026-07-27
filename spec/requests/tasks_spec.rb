# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Tasks', type: :request do
  let(:user) { create(:user) }
  let(:client) { create(:client, user: user) }

  describe 'authentication' do
    it 'redirects unauthenticated users to the sign-in page' do
      post client_tasks_path(client), params: {
        task: {
          title: 'Follow up',
          due_date: 2.days.from_now.to_date,
          status: 'pending',
          priority: 'medium'
        }
      }

      expect(response).to redirect_to(new_user_session_path)
    end
  end

  context 'when the user is signed in' do
    before do
      sign_in user
    end

    describe 'POST /clients/:client_id/tasks' do
      let(:valid_attributes) do
        {
          title: 'Send proposal',
          description: 'Send the updated proposal to the client.',
          due_date: 3.days.from_now.to_date,
          status: 'pending',
          priority: 'high'
        }
      end

      it "creates a task for the signed-in user's client" do
        expect do
          post client_tasks_path(client), params: {
            task: valid_attributes
          }
        end.to change(client.tasks, :count).by(1)

        task = client.tasks.last

        expect(task.title).to eq('Send proposal')
        expect(task).to be_pending
        expect(task).to be_high
      end

      it 'redirects to the client after creating the task' do
        post client_tasks_path(client), params: {
          task: valid_attributes
        }

        expect(response).to redirect_to(client_path(client))
      end

      it 'does not create an invalid task' do
        expect do
          post client_tasks_path(client), params: {
            task: valid_attributes.merge(
              title: '',
              due_date: ''
            )
          }
        end.not_to change(Task, :count)

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to include("Title can&#39;t be blank")
        expect(response.body).to include("Due date can&#39;t be blank")
      end

      it "does not allow task creation for another user's client" do
        other_client = create(:client)

        expect do
          post client_tasks_path(other_client), params: {
            task: valid_attributes
          }
        end.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    describe 'PATCH /clients/:client_id/tasks/:id' do
      it 'updates the task status' do
        task = create(:task, client: client, status: :pending)

        patch client_task_path(client, task), params: {
          task: {
            status: 'in_progress'
          }
        }

        expect(task.reload).to be_in_progress
        expect(response).to redirect_to(client_path(client))
      end

      it 'marks a task as completed' do
        task = create(:task, client: client, status: :in_progress)

        patch client_task_path(client, task), params: {
          task: {
            status: 'completed'
          }
        }

        expect(task.reload).to be_completed
      end

      it "does not allow updates to another user's task" do
        other_task = create(:task)

        expect do
          patch client_task_path(other_task.client, other_task), params: {
            task: {
              status: 'completed'
            }
          }
        end.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    describe 'DELETE /clients/:client_id/tasks/:id' do
      it "deletes the signed-in user's task" do
        task = create(:task, client: client)

        expect do
          delete client_task_path(client, task)
        end.to change(client.tasks, :count).by(-1)

        expect(response).to redirect_to(client_path(client))
      end

      it "does not allow deletion of another user's task" do
        other_task = create(:task)

        expect do
          delete client_task_path(other_task.client, other_task)
        end.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end