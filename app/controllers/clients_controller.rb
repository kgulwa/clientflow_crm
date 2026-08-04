# frozen_string_literal: true

class ClientsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_client, only: %i[show edit update destroy]

  def index
    @query = params[:query].to_s.strip
    @status = selected_status

    clients = current_user.clients
                          .search(@query)
                          .with_status(@status)
                          .order(created_at: :desc)

    respond_to do |format|
      format.html do
        @pagy, @clients = pagy(:offset, clients, limit: 10)
        @filters_applied = @query.present? || @status.present?
      end

      format.csv do
        send_data(
          Client.to_csv(clients),
          filename: clients_export_filename,
          type: "text/csv; charset=utf-8",
          disposition: "attachment"
        )
      end
    end
  end

  def show
    prepare_client_page
  end

  def new
    @client = current_user.clients.new
  end

  def create
    @client = current_user.clients.new(client_params)

    if @client.save
      redirect_to @client, notice: "Client was created successfully."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @client.update(client_params)
      redirect_to @client, notice: "Client was updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @client.destroy

    redirect_to clients_path, notice: "Client was deleted successfully."
  end

  private

  def selected_status
    status = params[:status].to_s

    status if Client.statuses.key?(status)
  end

  def clients_export_filename
    parts = ["clients"]
    parts << @status if @status.present?
    parts << Date.current.iso8601

    "#{parts.join("-")}.csv"
  end

  def set_client
    @client = current_user.clients.find(params[:id])
  end

  def prepare_client_page
    @contacts = @client.contacts.primary_first

    @editing_contact = @contacts.find do |contact|
      contact.id == params[:edit_contact].to_i
    end

    @note = @client.client_notes.new
    @client_notes = @client.client_notes.order(created_at: :desc)

    @task = @client.tasks.new
    @tasks = @client.tasks.order(
      Arel.sql(
        "CASE WHEN status = #{Task.statuses[:completed]} THEN 1 ELSE 0 END"
      ),
      due_date: :asc,
      created_at: :desc
    )

    @tag = current_user.tags.new
    @tags = current_user.tags.order(:name)
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

  def client_params
    params.require(:client).permit(
      :first_name,
      :last_name,
      :company_name,
      :email,
      :phone,
      :status,
      :notes
    )
  end
end