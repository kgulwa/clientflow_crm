# frozen_string_literal: true

class TasksController < ApplicationController
  before_action :authenticate_user!
  before_action :set_client
  before_action :set_task, only: %i[update destroy]

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
      redirect_to @client, notice: 'Task was updated successfully.'
    else
      redirect_to @client, alert: @task.errors.full_messages.to_sentence
    end
  end

  def destroy
    @task.destroy

    redirect_to @client, notice: 'Task was deleted successfully.'
  end

  private

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