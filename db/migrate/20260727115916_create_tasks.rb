# frozen_string_literal: true

class CreateTasks < ActiveRecord::Migration[7.0]
  def change
    create_table :tasks do |t|
      t.references :client, null: false, foreign_key: true
      t.string :title, null: false
      t.text :description
      t.date :due_date, null: false
      t.integer :status, null: false, default: 0
      t.integer :priority, null: false, default: 1

      t.timestamps
    end

    add_index :tasks, %i[client_id due_date]
    add_index :tasks, %i[client_id status]
  end
end