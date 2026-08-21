# frozen_string_literal: true

class HomeController < ApplicationController
  before_action :authenticate_user!

  def index
    @total_clients = current_user.workspace.clients.count
    @lead_clients = current_user.workspace.clients.lead.count
    @active_clients = current_user.workspace.clients.active.count

    @recent_clients = current_user.workspace.clients
                                  .order(created_at: :desc)
                                  .limit(5)

    @total_leads = current_user.workspace.leads.count
    @new_leads = current_user.workspace.leads.new_lead.count
    @qualified_leads = current_user.workspace.leads.qualified.count
    @converted_leads = current_user.workspace.leads.converted.count

    @lead_status_counts = Lead.statuses.keys.index_with do |status|
      current_user.workspace.leads.public_send(status).count
    end

    @recent_leads = current_user.workspace.leads
                                .order(created_at: :desc)
                                .limit(5)

    @pending_tasks_count = workspace_tasks.pending.count

    @overdue_tasks = workspace_tasks
                     .overdue
                     .order(due_date: :asc)
                     .limit(5)

    @overdue_tasks_count = @overdue_tasks.count

    @upcoming_tasks = workspace_tasks
                      .outstanding
                      .where(due_date: Date.current..)
                      .order(due_date: :asc)
                      .limit(5)

    @deal_stage_counts = Deal.stages.keys.index_with do |stage|
      workspace_deals.public_send(stage).count
    end

    @open_pipeline_value = workspace_deals
                           .where.not(
                             stage: [
                               Deal.stages[:won],
                               Deal.stages[:lost]
                             ]
                           )
                           .sum(:value)
  end

  private

  def workspace_tasks
    Task.joins(:client).where(
      clients: {
        workspace_id: current_user.workspace_id
      }
    )
  end

  def workspace_deals
    Deal.joins(:client).where(
      clients: {
        workspace_id: current_user.workspace_id
      }
    )
  end
end