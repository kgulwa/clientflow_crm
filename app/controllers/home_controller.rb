# frozen_string_literal: true

class HomeController < ApplicationController
  before_action :authenticate_user!

  def index
    @total_clients = current_user.workspace.clients.count
    @lead_clients = current_user.workspace.clients.lead.count
    @active_clients = current_user.workspace.clients.active.count

    @total_leads = current_user.workspace.leads.count
    @new_leads = current_user.workspace.leads.new_lead.count
    @qualified_leads = current_user.workspace.leads.qualified.count
    @converted_leads = current_user.workspace.leads.converted.count

    @recent_leads = current_user.workspace.leads
                                .order(created_at: :desc)
                                .limit(5)

    @pending_tasks_count = workspace_tasks.pending.count
    @overdue_tasks_count = workspace_tasks
                           .where.not(status: Task.statuses[:completed])
                           .where(due_date: ...Date.current)
                           .count

    @upcoming_tasks = workspace_tasks
                      .where.not(status: Task.statuses[:completed])
                      .order(due_date: :asc, created_at: :desc)
                      .limit(5)
  end

  private

  def workspace_tasks
    Task.joins(:client).where(
      clients: {
        workspace_id: current_user.workspace_id
      }
    )
  end
end