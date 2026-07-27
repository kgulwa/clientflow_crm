# frozen_string_literal: true

class NotesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_client
  before_action :set_note, only: :destroy

  def create
    @note = @client.client_notes.new(note_params)

    if @note.save
      redirect_to @client, notice: 'Note was added successfully.'
    else
      @client_notes = @client.client_notes.order(created_at: :desc)

      render 'clients/show', status: :unprocessable_entity
    end
  end

  def destroy
    @note.destroy

    redirect_to @client, notice: 'Note was deleted successfully.'
  end

  private

  def set_client
    @client = current_user.clients.find(params[:client_id])
  end

  def set_note
    @note = @client.client_notes.find(params[:id])
  end

  def note_params
    params.require(:note).permit(:title, :content)
  end
end