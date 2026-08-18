# frozen_string_literal: true

class TasksController < ApplicationController
  FILTERS = %w[
    all
    my_tasks
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

    tasks = filtered_tasks
            .includes(:client, :assigned_user)
            .order(task_order)

    @pagy, @tasks = pagy(:offset, tasks, limit: 10)

    @task_counts = {
      all: workspace_tasks.count,
      my_tasks: workspace_tasks.assigned_to(current_user).count,
      pending: workspace_tasks.pending.count,
      in_progress: workspace_tasks.in_progress.count,
      completed: workspace_tasks.completed.count,
      overdue: workspace_tasks.overdue.count,
      due_today: workspace_tasks.due_today.count
    }
  end

  def create
    @task = @client.tasks.new(task_params)

    if @task.save
      prepare_tasks

      respond_to do |format|
        format.html do
          redirect_to @client,
                      notice: "Task was created successfully."
        end

        format.turbo_stream
      end
    else
      respond_to do |format|
        format.html do
          prepare_client_page

          render "clients/show",
                 status: :unprocessable_entity
        end

        format.turbo_stream do
          prepare_tasks

          render :create,
                 status: :unprocessable_entity
        end
      end
    end
  end

  def update
    if @task.update(task_params)
      prepare_tasks

      respond_to do |format|
        format.html do
          redirect_back(
            fallback_location: client_path(@client),
            notice: "Task was updated successfully."
          )
        end

        format.turbo_stream
      end
    else
      respond_to do |format|
        format.html do
          redirect_back(
            fallback_location: client_path(@client),
            alert: @task.errors.full_messages.to_sentence
          )
        end

        format.turbo_stream do
          prepare_tasks

          render :update,
                 status: :unprocessable_entity
        end
      end
    end
  end

  def destroy
    @task.destroy
    prepare_tasks

    respond_to do |format|
      format.html do
        redirect_back(
          fallback_location: client_path(@client),
          notice: "Task was deleted successfully."
        )
      end

      format.turbo_stream
    end
  end

  private

  def workspace_tasks
    @workspace_tasks ||= Task.joins(:client).where(
      clients: {
        workspace_id: current_user.workspace_id
      }
    )
  end

  def selected_filter
    FILTERS.include?(params[:filter]) ? params[:filter] : "all"
  end

  def filtered_tasks
    case @filter
    when "my_tasks"
      workspace_tasks.assigned_to(current_user)
    when "pending"
      workspace_tasks.pending
    when "in_progress"
      workspace_tasks.in_progress
    when "completed"
      workspace_tasks.completed
    when "overdue"
      workspace_tasks.overdue
    when "due_today"
      workspace_tasks.due_today
    else
      workspace_tasks
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
    @client = current_user.workspace.clients.find(params[:client_id])
  end

  def set_task
    @task = @client.tasks.find(params[:id])
  end

  def prepare_tasks
    @tasks = @client.tasks
                    .includes(:assigned_user)
                    .order(
                      Arel.sql(
                        "CASE WHEN status = #{Task.statuses[:completed]} THEN 1 ELSE 0 END"
                      ),
                      due_date: :asc,
                      created_at: :desc
                    )

    prepare_active_workspace_members
    prepare_client_statistics
  end

  def prepare_client_page
    @contacts = @client.contacts.primary_first
    @note = @client.client_notes.new
    @client_notes = @client.client_notes.order(created_at: :desc)

    @task ||= @client.tasks.new
    prepare_tasks

    @tag = current_user.workspace.tags.new(
      user: current_user
    )
    @tags = current_user.workspace.tags.order(:name)
    @client_tags = @client.client_tags.includes(:tag)

    @activities = ClientActivityTimeline.new(@client).call
  end

  def prepare_active_workspace_members
    @workspace_members = current_user.workspace.users.active.order(
      :first_name,
      :last_name,
      :email
    )
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
      :priority,
      :assigned_user_id
    )
  end
end