class HomeController < ApplicationController
  before_action :authenticate_user!

  def index
    @total_clients = current_user.clients.count
    @lead_clients = current_user.clients.lead.count
    @active_clients = current_user.clients.active.count
  end
end
