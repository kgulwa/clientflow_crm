# frozen_string_literal: true

class ClientTagsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_client
  before_action :set_client_tag, only: :destroy

  def create
    tag = current_user.tags.find(client_tag_params[:tag_id])
    @client_tag = @client.client_tags.new(tag: tag)

    if @client_tag.save
      prepare_tags

      respond_to do |format|
        format.html do
          redirect_to @client,
                      notice: "Tag was assigned successfully."
        end

        format.turbo_stream
      end
    else
      redirect_to(
        @client,
        alert: @client_tag.errors.full_messages.to_sentence
      )
    end
  end

  def destroy
    @client_tag.destroy

    prepare_tags

    respond_to do |format|
      format.html do
        redirect_to @client,
                    notice: "Tag was removed successfully."
      end

      format.turbo_stream
    end
  end

  private

  def set_client
    @client = current_user.clients.find(params[:client_id])
  end

  def set_client_tag
    @client_tag = @client.client_tags.find(params[:id])
  end

  def prepare_tags
    @tag = current_user.tags.new
    @tags = current_user.tags.order(:name)
    @client_tags = @client.client_tags.includes(:tag)
  end

  def client_tag_params
    params.require(:client_tag).permit(:tag_id)
  end
end