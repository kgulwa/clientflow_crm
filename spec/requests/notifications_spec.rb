# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Notifications", type: :request do
  let(:user) { create(:user) }
  let(:actor) do
    create(
      :user,
      workspace: user.workspace
    )
  end

  let(:client) do
    create(
      :client,
      workspace: user.workspace,
      user: actor
    )
  end

  let(:task) do
    create(
      :task,
      client: client,
      assigned_user: user,
      title: "Call client for follow-up"
    )
  end

  describe "authentication" do
    it "redirects unauthenticated users from notifications" do
      get notifications_path

      expect(response).to redirect_to(new_user_session_path)
    end
  end

  context "when the user is signed in" do
    before do
      sign_in user
    end

    describe "GET /notifications" do
      it "returns a successful response" do
        get notifications_path

        expect(response).to have_http_status(:success)
      end

      it "shows notifications belonging to the signed-in user" do
        create(
          :notification,
          user: user,
          actor: actor,
          task: task,
          message: "Your notification"
        )

        other_user = create(:user)

        create(
          :notification,
          user: other_user,
          message: "Another user's notification"
        )

        get notifications_path

        expect(response.body).to include("Your notification")
        expect(response.body).not_to include("Another user's notification")
      end
    end

    describe "PATCH /notifications/:id/read" do
      it "marks the notification as read" do
        notification = create(
          :notification,
          user: user,
          actor: actor,
          task: task,
          read_at: nil
        )

        patch read_notification_path(notification)

        expect(notification.reload).to be_read
      end

      it "redirects to the relevant client task section" do
        notification = create(
          :notification,
          user: user,
          actor: actor,
          task: task
        )

        patch read_notification_path(notification)

        expect(response).to redirect_to(
          client_path(
            client,
            anchor: "tasks_section"
          )
        )
      end

      it "does not allow access to another user's notification" do
        other_user = create(:user)

        notification = create(
          :notification,
          user: other_user
        )

        expect do
          patch read_notification_path(notification)
        end.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    describe "PATCH /notifications/read_all" do
      it "marks all of the signed-in user's notifications as read" do
        first_notification = create(
          :notification,
          user: user,
          actor: actor,
          task: task,
          read_at: nil
        )

        second_notification = create(
          :notification,
          user: user,
          actor: actor,
          task: task,
          read_at: nil
        )

        patch read_all_notifications_path

        expect(first_notification.reload).to be_read
        expect(second_notification.reload).to be_read
      end

      it "does not mark another user's notifications as read" do
        other_user = create(:user)

        notification = create(
          :notification,
          user: other_user,
          read_at: nil
        )

        patch read_all_notifications_path

        expect(notification.reload).not_to be_read
      end
    end
  end
end