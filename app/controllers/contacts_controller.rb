# frozen_string_literal: true

class ContactsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_client
  before_action :set_contact, only: %i[show edit update destroy]

  def show; end

  def new
    @contact = @client.contacts.new
  end

  def create
    @contact = @client.contacts.new(contact_params)

    if @contact.save
      redirect_to @client, notice: "Contact was created successfully."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @contact.update(contact_params)
      redirect_to @client, notice: "Contact was updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @contact.destroy

    redirect_to @client, notice: "Contact was deleted successfully."
  end

  private

  def set_client
    @client = current_user.clients.find(params[:client_id])
  end

  def set_contact
    @contact = @client.contacts.find(params[:id])
  end

  def contact_params
    params.require(:contact).permit(
      :first_name,
      :last_name,
      :job_title,
      :department,
      :email,
      :phone,
      :primary_contact,
      :notes
    )
  end
end