# frozen_string_literal: true

class TagsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_client

  def create
    @tag = current_user.tags.new(tag_params)

    if create_and_assign_tag
      redirect_to @client, notice: "Tag was created and assigned successfully."
    else
      redirect_to(
        @client,
        alert: @tag.errors.full_messages.to_sentence
      )
    end
  end

  private

  def set_client
    @client = current_user.clients.find(params[:client_id])
  end

  def create_and_assign_tag
    Tag.transaction do
      @tag.save!
      @client.client_tags.create!(tag: @tag)
    end

    true
  rescue ActiveRecord::RecordInvalid
    false
  end

  def tag_params
    params.require(:tag).permit(:name, :color)
  end
end