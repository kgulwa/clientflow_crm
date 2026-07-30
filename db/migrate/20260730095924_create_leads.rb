# frozen_string_literal: true

class CreateLeads < ActiveRecord::Migration[7.0]
  def change
    create_table :leads do |t|
      t.references :user,
                   null: false,
                   foreign_key: true

      t.string :first_name,
               null: false

      t.string :last_name,
               null: false

      t.string :company_name

      t.string :email,
               null: false

      t.string :phone

      t.integer :source,
                null: false,
                default: 0

      t.integer :status,
                null: false,
                default: 0

      t.text :notes

      t.timestamps
    end

    add_index :leads, :status
    add_index :leads, :source
    add_index :leads, %i[user_id status]
  end
end