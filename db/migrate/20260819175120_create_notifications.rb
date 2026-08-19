class CreateNotifications < ActiveRecord::Migration[7.0]
  def change
    create_table :notifications do |t|
      t.references :user,
                   null: false,
                   foreign_key: true

      t.references :actor,
                   null: false,
                   foreign_key: { to_table: :users }

      t.references :task,
                   null: false,
                   foreign_key: true

      t.string :message,
               null: false

      t.datetime :read_at

      t.timestamps
    end
  end
end