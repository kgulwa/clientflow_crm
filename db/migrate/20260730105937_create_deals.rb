# frozen_string_literal: true

class CreateDeals < ActiveRecord::Migration[7.0]
  def change
    create_table :deals do |t|
      t.references :client,
                   null: false,
                   foreign_key: true

      t.string :title,
               null: false

      t.integer :stage,
                null: false,
                default: 0

      t.decimal :value,
                precision: 12,
                scale: 2,
                null: false,
                default: 0

      t.date :expected_close_date

      t.text :description

      t.timestamps
    end

    add_index :deals, :stage
    add_index :deals, :expected_close_date
  end
end