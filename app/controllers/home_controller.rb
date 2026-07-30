# frozen_string_literal: true

class HomeController < ApplicationController
  before_action :authenticate_user!

  def index
    @total_clients = current_user.clients.count
    @lead_clients = current_user.clients.lead.count
    @active_clients = current_user.clients.active.count
    @recent_clients = current_user.clients
                                  .order(created_at: :desc)
                                  .limit(5)

    @total_leads = current_user.leads.count
    @new_leads = current_user.leads.new_lead.count
    @qualified_leads = current_user.leads.qualified.count
    @converted_leads = current_user.leads.converted.count
    @lead_status_counts = Lead.statuses.keys.index_with do |status|
      current_user.leads.public_send(status).count
    end

    @recent_leads = current_user.leads
                                .order(created_at: :desc)
                                .limit(5)

    @pending_tasks_count = user_tasks.pending.count
    @overdue_tasks = user_tasks
                     .overdue
                     .order(due_date: :asc)
                     .limit(5)
    @overdue_tasks_count = @overdue_tasks.count

    @upcoming_tasks = user_tasks
                      .outstanding
                      .where(due_date: Date.current..)
                      .order(due_date: :asc)
                      .limit(5)

    @deal_stage_counts = Deal.stages.keys.index_with do |stage|
      current_user.deals.public_send(stage).count
    end

    @open_pipeline_value = current_user.deals
                                       .where.not(
                                         stage: [
                                           Deal.stages[:won],
                                           Deal.stages[:lost]
                                         ]
                                       )
                                       .sum(:value)
  end

  private

  def user_tasks
    Task.joins(:client).where(clients: { user_id: current_user.id })
  end
end