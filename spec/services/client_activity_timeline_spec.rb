# frozen_string_literal: true

require "rails_helper"

RSpec.describe ClientActivityTimeline do
  describe "#call" do
    it "includes note creation activity" do
      client = create(:client)
      note = create(
        :note,
        client: client,
        title: "Discovery call",
        content: "Discussed project requirements."
      )

      activity = described_class.new(client).call.find do |item|
        item[:event] == :note_created
      end

      expect(activity).to include(
        label: "Note added",
        icon: "N",
        title: note.title,
        description: note.content,
        occurred_at: note.created_at
      )
    end

    it "includes task creation, start, and completion activity" do
      client = create(:client)
      task = create(:task, client: client, status: :pending)

      task.update!(status: :in_progress)
      task.update!(status: :completed)

      events = described_class.new(client).call.map { |item| item[:event] }

      expect(events).to include(
        :task_created,
        :task_started,
        :task_completed
      )
    end

    it "does not include start or completion events without timestamps" do
      client = create(:client)
      create(:task, client: client, status: :pending)

      events = described_class.new(client).call.map { |item| item[:event] }

      expect(events).to eq([:task_created])
    end

    it "orders activity from newest to oldest" do
      client = create(:client)

      older_note = create(
        :note,
        client: client,
        title: "Older activity",
        created_at: 2.days.ago
      )

      newer_note = create(
        :note,
        client: client,
        title: "Newer activity",
        created_at: 1.day.ago
      )

      activities = described_class.new(client).call

      expect(activities.map { |item| item[:title] }).to eq(
        [newer_note.title, older_note.title]
      )
    end

    it "places completion before start and creation when timestamps match" do
      client = create(:client)
      timestamp = Time.zone.local(2026, 7, 28, 10, 30)

      task = travel_to(timestamp) do
        create(:task, client: client, status: :completed)
      end

      events = described_class.new(client).call
                              .select { |item| item[:title] == task.title }
                              .map { |item| item[:event] }

      expect(events).to eq(
        %i[task_completed task_started task_created]
      )
    end

    it "does not include unsaved task form objects" do
      client = create(:client)
      persisted_task = create(
        :task,
        client: client,
        title: "Saved task"
      )

      client.tasks.new(
        title: "Unsaved task",
        due_date: Date.current
      )

      activities = described_class.new(client).call
      activity_titles = activities.map { |item| item[:title] }

      expect(activity_titles).to include(persisted_task.title)
      expect(activity_titles).not_to include("Unsaved task")
    end

    it "does not include unsaved note form objects" do
      client = create(:client)
      persisted_note = create(
        :note,
        client: client,
        title: "Saved note"
      )

      client.client_notes.new(
        title: "Unsaved note",
        content: "This note has not been saved."
      )

      activities = described_class.new(client).call
      activity_titles = activities.map { |item| item[:title] }

      expect(activity_titles).to include(persisted_note.title)
      expect(activity_titles).not_to include("Unsaved note")
    end
  end
end