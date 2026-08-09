# frozen_string_literal: true

class ReportsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_date_range

  def index
    set_period_metrics
    set_revenue_trends
  end

  private

  def set_period_metrics
    @new_clients = clients_in_period.count

    @closed_deals = won_deals_in_period.count
    @revenue = won_deals_in_period.sum(:value)

    @total_deals = deals_in_period.count
    @conversion_rate = calculate_conversion_rate

    @tasks_completed = completed_tasks_in_period.count
  end

  def set_revenue_trends
    @selected_year = parsed_year(params[:year]) || Date.current.year
    @available_years = available_revenue_years
    @monthly_revenue = empty_monthly_revenue

    won_deals_for_selected_year.pluck(:updated_at, :value).each do |updated_at, value|
      @monthly_revenue[updated_at.month] += value.to_d
    end

    @yearly_revenue = @monthly_revenue.values.sum
    @average_monthly_revenue = @yearly_revenue / 12

    set_best_revenue_month
  end

  def set_best_revenue_month
    if @yearly_revenue.positive?
      month_number, revenue = @monthly_revenue.max_by do |_month, monthly_total|
        monthly_total
      end

      @best_revenue_month = Date::MONTHNAMES[month_number]
      @best_month_revenue = revenue
    else
      @best_revenue_month = nil
      @best_month_revenue = 0.to_d
    end
  end

  def available_revenue_years
    deal_years = workspace_deals
                 .won
                 .where.not(updated_at: nil)
                 .pluck(:updated_at)
                 .map(&:year)

    (deal_years + [Date.current.year, @selected_year])
      .uniq
      .sort
      .reverse
  end

  def empty_monthly_revenue
    (1..12).index_with { 0.to_d }
  end

  def parsed_year(value)
    return if value.blank?

    year = Integer(value, 10)

    year if year.between?(1900, 2100)
  rescue ArgumentError, TypeError
    nil
  end

  def won_deals_for_selected_year
    start_date = Date.new(@selected_year, 1, 1)
    end_date = start_date.end_of_year

    workspace_deals
      .won
      .where(updated_at: start_date.beginning_of_day..end_date.end_of_day)
  end

  def set_date_range
    @start_date = parsed_date(params[:start_date]) || Date.current.beginning_of_month
    @end_date = parsed_date(params[:end_date]) || Date.current

    normalize_date_range
  end

  def parsed_date(value)
    return if value.blank?

    Date.iso8601(value)
  rescue Date::Error
    nil
  end

  def normalize_date_range
    return unless @start_date > @end_date

    @start_date, @end_date = @end_date, @start_date
  end

  def datetime_range
    @start_date.beginning_of_day..@end_date.end_of_day
  end

  def clients_in_period
    current_user.workspace.clients.where(
      created_at: datetime_range
    )
  end

  def workspace_deals
    Deal.joins(:client).where(
      clients: {
        workspace_id: current_user.workspace_id
      }
    )
  end

  def deals_in_period
    workspace_deals.where(created_at: datetime_range)
  end

  def won_deals_in_period
    workspace_deals.won.where(updated_at: datetime_range)
  end

  def completed_tasks_in_period
    workspace_tasks
      .completed
      .where(completed_at: datetime_range)
  end

  def workspace_tasks
    Task.joins(:client).where(
      clients: {
        workspace_id: current_user.workspace_id
      }
    )
  end

  def calculate_conversion_rate
    return 0.0 if @total_deals.zero?

    (@closed_deals.to_f / @total_deals * 100).round(1)
  end
end