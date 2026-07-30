# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Client tag form", type: :request do
  let(:user) { create(:user) }
  let(:client) { create(:client, user: user) }

  before do
    sign_in user
  end

  describe "GET /clients/:id" do
    it "submits an existing tag using the client_tag parameter scope" do
      tag = create(
        :tag,
        user: user,
        name: "VIP client"
      )

      get client_path(client)

      expect(response).to have_http_status(:success)
      expect(response.body).to include(
        %(name="client_tag[tag_id]")
      )
      expect(response.body).to include(
        %(<option value="#{tag.id}">VIP client</option>)
      )
    end

    it "displays all tags assigned to the client" do
      vip_tag = create(
        :tag,
        user: user,
        name: "VIP client"
      )

      returning_tag = create(
        :tag,
        user: user,
        name: "Returning client"
      )

      create(
        :client_tag,
        client: client,
        tag: vip_tag
      )

      create(
        :client_tag,
        client: client,
        tag: returning_tag
      )

      get client_path(client)

      expect(response).to have_http_status(:success)
      expect(response.body).to include("VIP client")
      expect(response.body).to include("Returning client")
    end
  end
end