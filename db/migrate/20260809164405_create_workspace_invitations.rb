# frozen_string_literal: true

class CreateWorkspaceInvitations < ActiveRecord::Migration[7.0]
  def change
    create_table :workspace_invitations do |t|
      t.references :workspace,
                   null: false,
                   foreign_key: true

      t.references :invited_by,
                   null: false,
                   foreign_key: {
                     to_table: :users
                   }

      t.string :email,
               null: false

      t.string :token,
               null: false

      t.integer :status,
                null: false,
                default: 0

      t.datetime :accepted_at

      t.timestamps
    end

    add_index :workspace_invitations,
              :token,
              unique: true

    add_index :workspace_invitations,
              %i[workspace_id email],
              unique: true,
              where: "status = 0",
              name: "index_pending_workspace_invitations_on_workspace_and_email"
  end
end