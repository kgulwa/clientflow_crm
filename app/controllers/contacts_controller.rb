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
      prepare_contacts

      respond_to do |format|
        format.html do
          redirect_to @client,
                      notice: "Contact was created successfully."
        end

        format.turbo_stream
      end
    else
      respond_to do |format|
        format.html do
          render :new, status: :unprocessable_entity
        end

        format.turbo_stream do
          prepare_contacts

          render :create, status: :unprocessable_entity
        end
      end
    end
  end

  def edit; end

  def update
    if @contact.update(contact_params)
      prepare_contacts

      respond_to do |format|
        format.html do
          redirect_to @client,
                      notice: "Contact was updated successfully."
        end

        format.turbo_stream
      end
    else
      respond_to do |format|
        format.html do
          render :edit, status: :unprocessable_entity
        end

        format.turbo_stream do
          prepare_contacts

          render :update, status: :unprocessable_entity
        end
      end
    end
  end

  def destroy
    @contact.destroy
    prepare_contacts

    if params[:return_to_client].present?
      redirect_to(
        client_path(@client, anchor: "contacts_section"),
        notice: "Contact was deleted successfully.",
        status: :see_other
      )

      return
    end

    respond_to do |format|
      format.html do
        redirect_to(
          client_path(@client, anchor: "contacts_section"),
          notice: "Contact was deleted successfully.",
          status: :see_other
        )
      end

      format.turbo_stream
    end
  end

  private

  def set_client
    @client = current_user.clients.find(params[:client_id])
  end

  def set_contact
    @contact = @client.contacts.find(params[:id])
  end

  def prepare_contacts
    @contacts = @client.contacts.primary_first
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