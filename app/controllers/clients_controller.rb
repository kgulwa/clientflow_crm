class ClientsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_client, only: %i[show edit update destroy]

  def index
    @clients = current_user.clients.order(created_at: :desc)
  end

  def show
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

  def edit
  end

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

  def set_client
    @client = current_user.clients.find(params[:id])
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