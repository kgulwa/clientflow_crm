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
end