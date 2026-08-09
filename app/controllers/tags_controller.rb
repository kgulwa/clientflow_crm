# frozen_string_literal: true

class TagsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_client

  def create
    @tag = current_user.workspace.tags.new(
      tag_params.merge(
        user: current_user
      )
    )

    if create_and_assign_tag
      prepare_tags

      respond_to do |format|
        format.html do
          redirect_to @client,
                      notice: "Tag was created and assigned successfully."
        end

        format.turbo_stream
      end
    else
      respond_to do |format|
        format.html do
          redirect_to(
            @client,
            alert: @tag.errors.full_messages.to_sentence
          )
        end

        format.turbo_stream do
          prepare_tags

          render :create, status: :unprocessable_entity
        end
      end
    end
  end

  private

  def set_client
    @client = current_user.workspace.clients.find(params[:client_id])
  end

  def create_and_assign_tag
    Tag.transaction do
      @tag.save!
      @client.client_tags.create!(tag: @tag)
    end

    true
  rescue ActiveRecord::RecordInvalid => error
    copy_assignment_errors(error.record)

    false
  end

  def copy_assignment_errors(record)
    return if record == @tag

    record.errors.full_messages.each do |message|
      @tag.errors.add(:base, message)
    end
  end

  def prepare_tags
    @tags = current_user.workspace.tags.order(:name)
    @client_tags = @client.client_tags.includes(:tag)
  end

  def tag_params
    params.require(:tag).permit(:name, :color)
  end
end