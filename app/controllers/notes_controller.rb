# frozen_string_literal: true

class NotesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_client
  before_action :set_note, only: :destroy

  def create
    @note = @client.client_notes.new(note_params)

    if @note.save
      prepare_notes

      respond_to do |format|
        format.html do
          redirect_to @client, notice: "Note was added successfully."
        end

        format.turbo_stream
      end
    else
      respond_to do |format|
        format.html do
          prepare_client_page

          render "clients/show", status: :unprocessable_entity
        end

        format.turbo_stream do
          prepare_notes

          render :create, status: :unprocessable_entity
        end
      end
    end
  end

  def destroy
    @note.destroy
    prepare_notes

    respond_to do |format|
      format.html do
        redirect_to @client, notice: "Note was deleted successfully."
      end

      format.turbo_stream
    end
  end

  private

  def set_client
    @client = current_user.workspace.clients.find(params[:client_id])
  end

  def set_note
    @note = @client.client_notes.find(params[:id])
  end

  def prepare_notes
    @client_notes = @client.client_notes.order(created_at: :desc)
  end

  def prepare_client_page
    @contacts = @client.contacts.primary_first

    @client_notes = @client.client_notes.order(created_at: :desc)

    @task = @client.tasks.new
    @tasks = @client.tasks.order(
      Arel.sql(
        "CASE WHEN status = #{Task.statuses[:completed]} THEN 1 ELSE 0 END"
      ),
      due_date: :asc,
      created_at: :desc
    )

    @tag = current_user.workspace.tags.new(
      user: current_user
    )
    @tags = current_user.workspace.tags.order(:name)
    @client_tags = @client.client_tags.includes(:tag)

    @activities = ClientActivityTimeline.new(@client).call

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

  def note_params
    params.require(:note).permit(:title, :content)
  end
end