# frozen_string_literal: true

class AddHistoryTimestampsToTasks < ActiveRecord::Migration[7.0]
  def change
    add_column :tasks, :started_at, :datetime
    add_column :tasks, :completed_at, :datetime
  end
end