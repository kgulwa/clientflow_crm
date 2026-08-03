# frozen_string_literal: true

class LeadsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_lead, only: %i[show edit update destroy]

  def index
    leads = current_user.leads
                        .search(params[:search])
                        .with_status(params[:status])
                        .with_source(params[:source])
                        .order(created_at: :desc)

    respond_to do |format|
      format.html do
        @pagy, @leads = pagy(:offset, leads, limit: 10)
      end

      format.csv do
        send_data(
          Lead.to_csv(leads),
          filename: leads_export_filename,
          type: "text/csv; charset=utf-8",
          disposition: "attachment"
        )
      end
    end
  end

  def show; end

  def new
    @lead = current_user.leads.new
  end

  def create
    @lead = current_user.leads.new(lead_params)

    if @lead.save
      redirect_to @lead, notice: "Lead was created successfully."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @lead.update(lead_params)
      redirect_to @lead, notice: "Lead was updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @lead.destroy

    redirect_to leads_path, notice: "Lead was deleted successfully."
  end

  private

  def leads_export_filename
    parts = ["leads"]

    if Lead.statuses.key?(params[:status].to_s)
      parts << params[:status]
    end

    if Lead.sources.key?(params[:source].to_s)
      parts << params[:source]
    end

    parts << Date.current.iso8601

    "#{parts.join("-")}.csv"
  end

  def set_lead
    @lead = current_user.leads.find(params[:id])
  end

  def lead_params
    params.require(:lead).permit(
      :first_name,
      :last_name,
      :company_name,
      :email,
      :phone,
      :source,
      :status,
      :notes
    )
  end
end