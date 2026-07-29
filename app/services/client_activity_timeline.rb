# frozen_string_literal: true

class ClientActivityTimeline
  def initialize(client)
    @client = client
  end

  def call
    activities
      .select { |activity| activity[:occurred_at].present? }
      .sort_by do |activity|
        [activity[:occurred_at], activity[:sequence]]
      end
      .reverse
  end

  private

  attr_reader :client

  def activities
    note_activities + task_activities
  end

  def note_activities
    client.client_notes.select(&:persisted?).map do |note|
      {
        event: :note_created,
        label: "Note added",
        icon: "N",
        title: note.title,
        description: note.content,
        occurred_at: note.created_at,
        sequence: 1
      }
    end
  end

  def task_activities
    client.tasks.select(&:persisted?).flat_map do |task|
      [
        task_created_activity(task),
        task_started_activity(task),
        task_completed_activity(task)
      ].compact
    end
  end

  def task_created_activity(task)
    {
      event: :task_created,
      label: "Task created",
      icon: "T",
      title: task.title,
      description: task_description(task),
      occurred_at: task.created_at,
      sequence: 1
    }
  end

  def task_started_activity(task)
    return if task.started_at.blank?

    {
      event: :task_started,
      label: "Task started",
      icon: "S",
      title: task.title,
      description: nil,
      occurred_at: task.started_at,
      sequence: 2
    }
  end

  def task_completed_activity(task)
    return if task.completed_at.blank?

    {
      event: :task_completed,
      label: "Task completed",
      icon: "C",
      title: task.title,
      description: nil,
      occurred_at: task.completed_at,
      sequence: 3
    }
  end

  def task_description(task)
    [
      priority_description(task),
      due_date_description(task)
    ].join(" · ")
  end

  def priority_description(task)
    "#{task.priority.titleize} priority"
  end

  def due_date_description(task)
    return "No due date" if task.due_date.blank?

    "Due #{task.due_date.strftime('%B %-d, %Y')}"
  end
end