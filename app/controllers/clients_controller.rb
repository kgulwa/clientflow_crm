# frozen_string_literal: true

class ClientsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_client, only: %i[show edit update destroy]

  def index
    @query = params[:query].to_s.strip
    @status = selected_status

    @clients = current_user.clients
                           .search(@query)
                           .with_status(@status)
                           .order(created_at: :desc)

    @filters_applied = @query.present? || @status.present?
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
      redirect_to @client, notice: 'Client was created successfully.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @client.update(client_params)
      redirect_to @client, notice: 'Client was updated successfully.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @client.destroy

    redirect_to clients_path, notice: 'Client was deleted successfully.'
  end

  private

  def selected_status
    status = params[:status].to_s

    status if Client.statuses.key?(status)
  end

  def set_client
    @client = current_user.clients.find(params[:id])
  end

  def prepare_client_page
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