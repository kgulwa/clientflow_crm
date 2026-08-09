# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Notes", type: :request do
  let(:user) { create(:user) }
  let(:client) { create(:client, user: user) }

  before do
    sign_in user
  end

  describe "POST /clients/:client_id/notes" do
    let(:valid_attributes) do
      {
        title: "Follow up",
        content: "Call the client next week."
      }
    end

    it "creates a note for a client in the same workspace" do
      expect do
        post client_notes_path(client), params: {
          note: valid_attributes
        }
      end.to change(client.client_notes, :count).by(1)
    end

    it "allows another user in the same workspace to create a note" do
      teammate = create(:user, workspace: user.workspace)
      teammate_client = create(
        :client,
        user: teammate,
        workspace: user.workspace
      )

      expect do
        post client_notes_path(teammate_client), params: {
          note: valid_attributes
        }
      end.to change(teammate_client.client_notes, :count).by(1)
    end

    it "does not allow note creation for a client in another workspace" do
      other_client = create(:client)

      expect do
        post client_notes_path(other_client), params: {
          note: valid_attributes
        }
      end.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  describe "DELETE /clients/:client_id/notes/:id" do
    it "deletes a note from a client in the same workspace" do
      note = create(:note, client: client)

      expect do
        delete client_note_path(client, note)
      end.to change(client.client_notes, :count).by(-1)
    end

    it "allows another user in the same workspace to delete a note" do
      teammate = create(:user, workspace: user.workspace)
      teammate_client = create(
        :client,
        user: teammate,
        workspace: user.workspace
      )
      note = create(:note, client: teammate_client)

      expect do
        delete client_note_path(teammate_client, note)
      end.to change(teammate_client.client_notes, :count).by(-1)
    end

    it "does not allow deleting a note from another workspace" do
      other_client = create(:client)
      note = create(:note, client: other_client)

      expect do
        delete client_note_path(other_client, note)
      end.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end