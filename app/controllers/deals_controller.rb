# frozen_string_literal: true

class DealsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_deal, only: %i[show edit update destroy]

  def index
    @deals = current_user.deals.recent_first
  end

  def show; end

  def new
    @deal = Deal.new
  end

  def create
    @deal = Deal.new(deal_params)

    if client_belongs_to_current_user? && @deal.save
      redirect_to @deal, notice: "Deal was created successfully."
    else
      add_client_error unless client_belongs_to_current_user?
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    @deal.assign_attributes(deal_params)

    if client_belongs_to_current_user? && @deal.save
      redirect_to @deal, notice: "Deal was updated successfully."
    else
      add_client_error unless client_belongs_to_current_user?
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @deal.destroy

    redirect_to deals_path, notice: "Deal was deleted successfully."
  end

  private

  def set_deal
    @deal = current_user.deals.find(params[:id])
  end

  def deal_params
    params.require(:deal).permit(
      :client_id,
      :title,
      :stage,
      :value,
      :expected_close_date,
      :description
    )
  end

  def client_belongs_to_current_user?
    current_user.clients.exists?(id: @deal.client_id)
  end

  def add_client_error
    @deal.errors.add(:client, "must belong to your account")
  end
end