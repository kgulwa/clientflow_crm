# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Reports", type: :request do
  describe "authentication" do
    it "redirects unauthenticated users to the sign-in page" do
      get reports_path

      expect(response).to redirect_to(new_user_session_path)
    end
  end

  context "when the user is signed in" do
    let(:user) { create(:user) }
    let(:client) { create(:client, user: user) }

    before do
      sign_in user
    end

    describe "GET /reports" do
      it "returns a successful response" do
        get reports_path

        expect(response).to have_http_status(:success)
      end

      it "displays the reporting dashboard" do
        get reports_path

        expect(response.body).to include("Business overview")
        expect(response.body).to include("New clients")
        expect(response.body).to include("Closed deals")
        expect(response.body).to include("Revenue")
        expect(response.body).to include("Conversion rate")
        expect(response.body).to include("Tasks completed")
      end

      it "defaults to the current month" do
        get reports_path

        expect(response.body).to include(
          Date.current.beginning_of_month.strftime("%d %b %Y")
        )

        expect(response.body).to include(
          Date.current.strftime("%d %b %Y")
        )
      end

      it "counts clients created during the selected period" do
        create(
          :client,
          user: user,
          email: "included@example.com",
          created_at: Date.current.noon
        )

        create(
          :client,
          user: user,
          email: "excluded@example.com",
          created_at: 2.months.ago
        )

        get reports_path, params: {
          start_date: Date.current.beginning_of_month.iso8601,
          end_date: Date.current.iso8601
        }

        expect(response.body).to include("New clients")
        expect(response.body).to match(
          /New clients.*?1/m
        )
      end

      it "does not count another user's clients" do
        create(
          :client,
          created_at: Date.current.noon
        )

        get reports_path

        expect(response.body).to match(
          /New clients.*?0/m
        )
      end

      it "counts won deals updated during the selected period" do
        create(
          :deal,
          :won,
          client: client,
          title: "Won this month",
          value: 12_500,
          updated_at: Date.current.noon
        )

        create(
          :deal,
          :won,
          client: client,
          title: "Won previously",
          value: 8_000,
          updated_at: 2.months.ago
        )

        get reports_path

        expect(response.body).to match(
          /Closed deals.*?1/m
        )

        expect(response.body).to include("R12,500.00")
      end

      it "does not count lost deals as closed revenue" do
        create(
          :deal,
          :lost,
          client: client,
          value: 50_000,
          updated_at: Date.current.noon
        )

        get reports_path

        expect(response.body).to match(
          /Closed deals.*?0/m
        )

        expect(response.body).to include("R0.00")
      end

      it "calculates the conversion rate from won and total deals" do
        create(
          :deal,
          :won,
          client: client,
          created_at: Date.current.noon,
          updated_at: Date.current.noon
        )

        create(
          :deal,
          :prospecting,
          client: client,
          created_at: Date.current.noon
        )

        get reports_path

        expect(response.body).to include("50.0%")
      end

      it "returns a zero conversion rate when there are no deals" do
        get reports_path

        expect(response.body).to include("0.0%")
      end

      it "counts tasks completed during the selected period" do
        create(
          :task,
          :completed,
          client: client,
          title: "Included completed task",
          completed_at: Date.current.noon
        )

        create(
          :task,
          :completed,
          client: client,
          title: "Old completed task",
          completed_at: 2.months.ago
        )

        get reports_path

        expect(response.body).to match(
          /Tasks completed.*?1/m
        )
      end

      it "does not count another user's completed tasks" do
        create(
          :task,
          :completed,
          completed_at: Date.current.noon
        )

        get reports_path

        expect(response.body).to match(
          /Tasks completed.*?0/m
        )
      end

      it "applies a custom date range" do
        start_date = 3.months.ago.to_date.beginning_of_month
        end_date = 3.months.ago.to_date.end_of_month

        create(
          :client,
          user: user,
          email: "custom-range@example.com",
          created_at: start_date.noon
        )

        get reports_path, params: {
          start_date: start_date.iso8601,
          end_date: end_date.iso8601
        }

        expect(response).to have_http_status(:success)

        expect(response.body).to include(
          start_date.strftime("%d %b %Y")
        )

        expect(response.body).to include(
          end_date.strftime("%d %b %Y")
        )

        expect(response.body).to match(
          /New clients.*?1/m
        )
      end

      it "handles invalid date parameters without crashing" do
        get reports_path, params: {
          start_date: "not-a-date",
          end_date: "also-not-a-date"
        }

        expect(response).to have_http_status(:success)

        expect(response.body).to include(
          Date.current.beginning_of_month.strftime("%d %b %Y")
        )
      end

      it "normalizes a reversed date range" do
        earlier_date = 1.month.ago.to_date
        later_date = Date.current

        create(
          :client,
          user: user,
          email: "reversed-range@example.com",
          created_at: earlier_date.noon
        )

        get reports_path, params: {
          start_date: later_date.iso8601,
          end_date: earlier_date.iso8601
        }

        expect(response).to have_http_status(:success)

        expect(response.body).to include(
          earlier_date.strftime("%d %b %Y")
        )

        expect(response.body).to include(
          later_date.strftime("%d %b %Y")
        )
      end
    end
  end
end