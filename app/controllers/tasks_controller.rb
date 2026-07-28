# frozen_string_literal: true

class TasksController < ApplicationController
  FILTERS = %w[
    all
    pending
    in_progress
    completed
    overdue
    due_today
  ].freeze

  before_action :authenticate_user!
  before_action :set_client, only: %i[create update destroy]
  before_action :set_task, only: %i[update destroy]

  def index
    @filter = selected_filter
    @tasks = filtered_tasks
             .includes(:client)
             .order(task_order)

    @task_counts = {
      all: user_tasks.count,
      pending: user_tasks.pending.count,
      in_progress: user_tasks.in_progress.count,
      completed: user_tasks.completed.count,
      overdue: user_tasks.overdue.count,
      due_today: user_tasks.due_today.count
    }
  end

  def create
    @task = @client.tasks.new(task_params)

    if @task.save
      redirect_to @client, notice: 'Task was created successfully.'
    else
      prepare_client_page

      render 'clients/show', status: :unprocessable_entity
    end
  end

  def update
    if @task.update(task_params)
      redirect_back(
        fallback_location: client_path(@client),
        notice: 'Task was updated successfully.'
      )
    else
      redirect_back(
        fallback_location: client_path(@client),
        alert: @task.errors.full_messages.to_sentence
      )
    end
  end

  def destroy
    @task.destroy

    redirect_back(
      fallback_location: client_path(@client),
      notice: 'Task was deleted successfully.'
    )
  end

  private

  def user_tasks
    @user_tasks ||= Task.for_user(current_user)
  end

  def selected_filter
    FILTERS.include?(params[:filter]) ? params[:filter] : 'all'
  end

  def filtered_tasks
    case @filter
    when 'pending'
      user_tasks.pending
    when 'in_progress'
      user_tasks.in_progress
    when 'completed'
      user_tasks.completed
    when 'overdue'
      user_tasks.overdue
    when 'due_today'
      user_tasks.due_today
    else
      user_tasks
    end
  end

  def task_order
    Arel.sql(
      <<~SQL.squish
        CASE
          WHEN tasks.status = #{Task.statuses[:completed]} THEN 1
          ELSE 0
        END,
        tasks.due_date ASC,
        tasks.created_at DESC
      SQL
    )
  end

  def set_client
    @client = current_user.clients.find(params[:client_id])
  end

  def set_task
    @task = @client.tasks.find(params[:id])
  end

  def prepare_client_page
    @note = @client.client_notes.new
    @client_notes = @client.client_notes.order(created_at: :desc)

    @tasks = @client.tasks.order(
      Arel.sql(
        "CASE WHEN status = #{Task.statuses[:completed]} THEN 1 ELSE 0 END"
      ),
      due_date: :asc,
      created_at: :desc
    )

    prepare_client_statistics
  end

  def prepare_client_statistics
    client_tasks = @client.tasks

    @client_statistics = {
      open_tasks: client_tasks.outstanding.count,
      completed_tasks: client_tasks.completed.count,
      overdue_tasks: client_tasks.overdue.count,
      total_notes: @client.client_notes.count
    }
  end

  def task_params
    params.require(:task).permit(
      :title,
      :description,
      :due_date,
      :status,
      :priority
    )
  end
end