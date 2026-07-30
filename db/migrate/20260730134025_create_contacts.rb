class CreateContacts < ActiveRecord::Migration[7.0]
  def change
    create_table :contacts do |t|
      t.references :client, null: false, foreign_key: true
      t.string :first_name
      t.string :last_name
      t.string :job_title
      t.string :department
      t.string :email
      t.string :phone
      t.boolean :primary_contact, null: false, default: false
      t.text :notes

      t.timestamps
    end
  end
end