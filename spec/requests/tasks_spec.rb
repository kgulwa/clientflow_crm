# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Tasks', type: :request do
  let(:user) { create(:user) }
  let(:client) { create(:client, user: user) }

  describe 'authentication' do
    it 'redirects unauthenticated users from the tasks index' do
      get tasks_path

      expect(response).to redirect_to(new_user_session_path)
    end

    it 'redirects unauthenticated users when creating a task' do
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

    describe 'GET /tasks' do
      let!(:pending_task) do
        create(
          :task,
          client: client,
          title: 'Pending task',
          status: :pending,
          due_date: 2.days.from_now.to_date
        )
      end

      let!(:in_progress_task) do
        create(
          :task,
          :in_progress,
          client: client,
          title: 'In progress task',
          due_date: 3.days.from_now.to_date
        )
      end

      let!(:completed_task) do
        create(
          :task,
          :completed,
          client: client,
          title: 'Completed task'
        )
      end

      let!(:overdue_task) do
        create(
          :task,
          :overdue,
          client: client,
          title: 'Overdue task'
        )
      end

      let!(:today_task) do
        create(
          :task,
          client: client,
          title: 'Today task',
          due_date: Date.current
        )
      end

      before do
        other_client = create(:client)

        create(
          :task,
          client: other_client,
          title: 'Hidden task'
        )
      end

      it 'returns a successful response' do
        get tasks_path

        expect(response).to have_http_status(:success)
      end

      it "shows only the signed-in user's tasks" do
        get tasks_path

        expect(response.body).to include('Pending task')
        expect(response.body).to include('In progress task')
        expect(response.body).to include('Completed task')
        expect(response.body).to include('Overdue task')
        expect(response.body).to include('Today task')
        expect(response.body).not_to include('Hidden task')
      end

      it 'shows task management actions' do
        get tasks_path

        expect(response.body).to include('Start')
        expect(response.body).to include('Complete')
        expect(response.body).to include('Reopen')
        expect(response.body).to include('Delete')
      end

      it 'filters pending tasks' do
        get tasks_path(filter: :pending)

        expect(response.body).to include('Pending task')
        expect(response.body).not_to include('Completed task')
      end

      it 'filters in progress tasks' do
        get tasks_path(filter: :in_progress)

        expect(response.body).to include('In progress task')
        expect(response.body).not_to include('Pending task')
      end

      it 'filters completed tasks' do
        get tasks_path(filter: :completed)

        expect(response.body).to include('Completed task')
        expect(response.body).not_to include('Pending task')
      end

      it 'filters overdue tasks' do
        get tasks_path(filter: :overdue)

        expect(response.body).to include('Overdue task')
        expect(response.body).not_to include('Today task')
      end

      it 'filters tasks due today' do
        get tasks_path(filter: :due_today)

        expect(response.body).to include('Today task')
        expect(response.body).not_to include('Overdue task')
      end

      it 'falls back to all tasks for an invalid filter' do
        get tasks_path(filter: :invalid)

        expect(response.body).to include('Pending task')
        expect(response.body).to include('Completed task')
        expect(response.body).to include('Today task')
      end
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

      it 'records when a task is started' do
        task = create(:task, client: client, status: :pending)
        started_time = Time.zone.local(2026, 7, 28, 9, 30)

        travel_to(started_time) do
          patch client_task_path(client, task), params: {
            task: {
              status: 'in_progress'
            }
          }
        end

        task.reload

        expect(task).to be_in_progress
        expect(task.started_at).to eq(started_time)
        expect(task.completed_at).to be_nil
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

      it 'records when an in-progress task is completed' do
        started_time = Time.zone.local(2026, 7, 28, 8, 15)
        completed_time = Time.zone.local(2026, 7, 28, 11, 45)
        task = create(:task, client: client, status: :pending)

        travel_to(started_time) do
          task.update!(status: :in_progress)
        end

        travel_to(completed_time) do
          patch client_task_path(client, task), params: {
            task: {
              status: 'completed'
            }
          }
        end

        task.reload

        expect(task).to be_completed
        expect(task.started_at).to eq(started_time)
        expect(task.completed_at).to eq(completed_time)
      end

      it 'records both timestamps when completing a pending task' do
        task = create(:task, client: client, status: :pending)
        completed_time = Time.zone.local(2026, 7, 28, 12, 30)

        travel_to(completed_time) do
          patch client_task_path(client, task), params: {
            task: {
              status: 'completed'
            }
          }
        end

        task.reload

        expect(task).to be_completed
        expect(task.started_at).to eq(completed_time)
        expect(task.completed_at).to eq(completed_time)
      end

      it 'clears completed_at when a task is reopened' do
        started_time = Time.zone.local(2026, 7, 28, 8, 15)
        completed_time = Time.zone.local(2026, 7, 28, 10, 30)
        task = create(:task, client: client, status: :pending)

        travel_to(started_time) do
          task.update!(status: :in_progress)
        end

        travel_to(completed_time) do
          task.update!(status: :completed)
        end

        patch client_task_path(client, task), params: {
          task: {
            status: 'pending'
          }
        }

        task.reload

        expect(task).to be_pending
        expect(task.started_at).to eq(started_time)
        expect(task.completed_at).to be_nil
      end

      it 'returns to the tasks index after starting a task there' do
        task = create(:task, client: client, status: :pending)

        patch client_task_path(client, task),
              params: {
                task: {
                  status: 'in_progress'
                }
              },
              headers: {
                'HTTP_REFERER' => tasks_url(filter: 'pending')
              }

        expect(task.reload).to be_in_progress
        expect(response).to redirect_to(tasks_url(filter: 'pending'))
      end

      it 'returns to the tasks index after completing a task there' do
        task = create(:task, client: client, status: :in_progress)

        patch client_task_path(client, task),
              params: {
                task: {
                  status: 'completed'
                }
              },
              headers: {
                'HTTP_REFERER' => tasks_url(filter: 'in_progress')
              }

        expect(task.reload).to be_completed
        expect(response).to redirect_to(tasks_url(filter: 'in_progress'))
      end

      it 'reopens a completed task from the tasks index' do
        task = create(:task, client: client, status: :completed)

        patch client_task_path(client, task),
              params: {
                task: {
                  status: 'pending'
                }
              },
              headers: {
                'HTTP_REFERER' => tasks_url(filter: 'completed')
              }

        task.reload

        expect(task).to be_pending
        expect(task.completed_at).to be_nil
        expect(response).to redirect_to(tasks_url(filter: 'completed'))
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

      it 'returns to the tasks index after deleting a task there' do
        task = create(:task, client: client)

        expect do
          delete client_task_path(client, task),
                 headers: {
                   'HTTP_REFERER' => tasks_url(filter: 'pending')
                 }
        end.to change(client.tasks, :count).by(-1)

        expect(response).to redirect_to(tasks_url(filter: 'pending'))
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