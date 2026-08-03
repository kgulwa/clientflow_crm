# frozen_string_literal: true

class DealsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_deal, only: %i[show edit update destroy]

  def index
    deals = current_user.deals
                        .search(params[:search])
                        .with_stage(params[:stage])
                        .recent_first

    respond_to do |format|
      format.html do
        @pagy, @deals = pagy(:offset, deals, limit: 10)
      end

      format.csv do
        send_data(
          Deal.to_csv(deals),
          filename: deals_export_filename,
          type: "text/csv; charset=utf-8",
          disposition: "attachment"
        )
      end
    end
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

  def deals_export_filename
    parts = ["deals"]

    if Deal.stages.key?(params[:stage].to_s)
      parts << params[:stage]
    end

    parts << Date.current.iso8601

    "#{parts.join("-")}.csv"
  end

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