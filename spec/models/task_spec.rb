# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Task, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:client) }
  end

  describe 'validations' do
    subject(:task) { build(:task) }

    it { is_expected.to validate_presence_of(:title) }
    it { is_expected.to validate_presence_of(:due_date) }
    it { is_expected.to validate_presence_of(:status) }
    it { is_expected.to validate_presence_of(:priority) }
  end

  describe 'statuses' do
    it 'defines pending, in progress, and completed statuses' do
      expect(described_class.statuses).to eq(
        'pending' => 0,
        'in_progress' => 1,
        'completed' => 2
      )
    end

    it 'defaults new tasks to pending' do
      task = described_class.new

      expect(task).to be_pending
    end
  end

  describe 'priorities' do
    it 'defines low, medium, and high priorities' do
      expect(described_class.priorities).to eq(
        'low' => 0,
        'medium' => 1,
        'high' => 2
      )
    end

    it 'defaults new tasks to medium priority' do
      task = described_class.new

      expect(task).to be_medium
    end
  end

  describe 'status history timestamps' do
    describe 'when a pending task is started' do
      it 'records when the task was started' do
        task = create(:task, status: :pending)
        started_time = Time.zone.local(2026, 7, 28, 9, 30)

        travel_to(started_time) do
          task.update!(status: :in_progress)
        end

        expect(task.reload.started_at).to eq(started_time)
        expect(task.completed_at).to be_nil
      end
    end

    describe 'when an in-progress task is completed' do
      it 'records when the task was completed' do
        task = create(:task, status: :pending)
        started_time = Time.zone.local(2026, 7, 28, 9, 30)
        completed_time = Time.zone.local(2026, 7, 28, 11, 45)

        travel_to(started_time) do
          task.update!(status: :in_progress)
        end

        travel_to(completed_time) do
          task.update!(status: :completed)
        end

        task.reload

        expect(task.started_at).to eq(started_time)
        expect(task.completed_at).to eq(completed_time)
      end
    end

    describe 'when a pending task is completed directly' do
      it 'records both the started and completed timestamps' do
        task = create(:task, status: :pending)
        completed_time = Time.zone.local(2026, 7, 28, 12, 15)

        travel_to(completed_time) do
          task.update!(status: :completed)
        end

        task.reload

        expect(task.started_at).to eq(completed_time)
        expect(task.completed_at).to eq(completed_time)
      end
    end

    describe 'when a completed task is reopened' do
      it 'clears the completion timestamp' do
        task = create(:task, status: :pending)
        started_time = Time.zone.local(2026, 7, 28, 8, 15)
        completed_time = Time.zone.local(2026, 7, 28, 10, 30)

        travel_to(started_time) do
          task.update!(status: :in_progress)
        end

        travel_to(completed_time) do
          task.update!(status: :completed)
        end

        task.update!(status: :pending)
        task.reload

        expect(task.started_at).to eq(started_time)
        expect(task.completed_at).to be_nil
      end
    end

    describe 'when a reopened task is started again' do
      it 'preserves the original started timestamp' do
        task = create(:task, status: :pending)
        original_started_time = Time.zone.local(2026, 7, 28, 8, 15)
        completed_time = Time.zone.local(2026, 7, 28, 10, 30)
        restarted_time = Time.zone.local(2026, 7, 29, 9, 45)

        travel_to(original_started_time) do
          task.update!(status: :in_progress)
        end

        travel_to(completed_time) do
          task.update!(status: :completed)
        end

        task.update!(status: :pending)

        travel_to(restarted_time) do
          task.update!(status: :in_progress)
        end

        task.reload

        expect(task.started_at).to eq(original_started_time)
        expect(task.completed_at).to be_nil
      end
    end

    describe 'when a reopened task is completed again' do
      it 'records the latest completion time' do
        task = create(:task, status: :pending)
        original_started_time = Time.zone.local(2026, 7, 28, 8, 15)
        original_completed_time = Time.zone.local(2026, 7, 28, 10, 30)
        latest_completed_time = Time.zone.local(2026, 7, 29, 14, 20)

        travel_to(original_started_time) do
          task.update!(status: :in_progress)
        end

        travel_to(original_completed_time) do
          task.update!(status: :completed)
        end

        task.update!(status: :pending)

        travel_to(latest_completed_time) do
          task.update!(status: :completed)
        end

        task.reload

        expect(task.started_at).to eq(original_started_time)
        expect(task.completed_at).to eq(latest_completed_time)
      end
    end

    describe 'when a task is created in progress' do
      it 'records the started timestamp' do
        started_time = Time.zone.local(2026, 7, 28, 13, 10)

        task = travel_to(started_time) do
          create(:task, status: :in_progress)
        end

        expect(task.started_at).to eq(started_time)
        expect(task.completed_at).to be_nil
      end
    end

    describe 'when a task is created as completed' do
      it 'records both history timestamps' do
        completed_time = Time.zone.local(2026, 7, 28, 15, 25)

        task = travel_to(completed_time) do
          create(:task, status: :completed)
        end

        expect(task.started_at).to eq(completed_time)
        expect(task.completed_at).to eq(completed_time)
      end
    end
  end
end