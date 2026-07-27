class CreateClients < ActiveRecord::Migration[7.0]
  def change
    create_table :clients do |t|
      t.references :user, null: false, foreign_key: true
      t.string :first_name, null: false
      t.string :last_name, null: false
      t.string :company_name
      t.string :email, null: false
      t.string :phone
      t.integer :status, null: false, default: 0
      t.text :notes

      t.timestamps
    end

    add_index :clients, :status
    add_index :clients, %i[user_id email], unique: true
  end
end