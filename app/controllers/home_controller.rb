# frozen_string_literal: true

class HomeController < ApplicationController
  before_action :authenticate_user!

  def index
    @total_clients = current_user.clients.count
    @lead_clients = current_user.clients.lead.count
    @active_clients = current_user.clients.active.count

    @total_leads = current_user.leads.count
    @new_leads = current_user.leads.new_lead.count
    @qualified_leads = current_user.leads.qualified.count
    @converted_leads = current_user.leads.converted.count

    @recent_leads = current_user.leads
                            .order(created_at: :desc)
                            .limit(5)

    @pending_tasks_count = user_tasks.pending.count
    @overdue_tasks_count = user_tasks
                           .where.not(status: Task.statuses[:completed])
                           .where(due_date: ...Date.current)
                           .count

    @upcoming_tasks = user_tasks
                      .where.not(status: Task.statuses[:completed])
                      .order(due_date: :asc, created_at: :desc)
                      .limit(5)
  end

  private

  def user_tasks
    Task.joins(:client).where(clients: { user_id: current_user.id })
  end
end