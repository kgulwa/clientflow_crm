# frozen_string_literal: true

class ReportsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_date_range

  def index
    @new_clients = clients_in_period.count

    @closed_deals = won_deals_in_period.count
    @revenue = won_deals_in_period.sum(:value)

    @total_deals = deals_in_period.count
    @conversion_rate = calculate_conversion_rate

    @tasks_completed = completed_tasks_in_period.count
  end

  private

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
    current_user.clients.where(created_at: datetime_range)
  end

  def user_deals
    Deal.joins(:client)
        .where(clients: { user_id: current_user.id })
  end

  def deals_in_period
    user_deals.where(created_at: datetime_range)
  end

  def won_deals_in_period
    user_deals.won.where(updated_at: datetime_range)
  end

  def completed_tasks_in_period
    Task.for_user(current_user)
        .completed
        .where(completed_at: datetime_range)
  end

  def calculate_conversion_rate
    return 0.0 if @total_deals.zero?

    (@closed_deals.to_f / @total_deals * 100).round(1)
  end
end