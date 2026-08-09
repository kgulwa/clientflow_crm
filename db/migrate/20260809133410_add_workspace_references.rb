# frozen_string_literal: true

class AddWorkspaceReferences < ActiveRecord::Migration[7.0]
  class MigrationUser < ActiveRecord::Base
    self.table_name = "users"
  end

  class MigrationWorkspace < ActiveRecord::Base
    self.table_name = "workspaces"
  end

  class MigrationClient < ActiveRecord::Base
    self.table_name = "clients"
  end

  class MigrationLead < ActiveRecord::Base
    self.table_name = "leads"
  end

  class MigrationTag < ActiveRecord::Base
    self.table_name = "tags"
  end

  def up
    add_reference :users,
                  :workspace,
                  index: true,
                  foreign_key: true

    add_reference :clients,
                  :workspace,
                  index: true,
                  foreign_key: true

    add_reference :leads,
                  :workspace,
                  index: true,
                  foreign_key: true

    add_reference :tags,
                  :workspace,
                  index: true,
                  foreign_key: true

    reset_migration_models

    MigrationUser.find_each do |user|
      workspace = MigrationWorkspace.create!(
        name: workspace_name_for(user)
      )

      user.update_columns(workspace_id: workspace.id)

      MigrationClient.where(user_id: user.id)
                     .update_all(workspace_id: workspace.id)

      MigrationLead.where(user_id: user.id)
                   .update_all(workspace_id: workspace.id)

      MigrationTag.where(user_id: user.id)
                  .update_all(workspace_id: workspace.id)
    end

    change_column_null :users, :workspace_id, false
    change_column_null :clients, :workspace_id, false
    change_column_null :leads, :workspace_id, false
    change_column_null :tags, :workspace_id, false
  end

  def down
    remove_reference :tags,
                     :workspace,
                     foreign_key: true

    remove_reference :leads,
                     :workspace,
                     foreign_key: true

    remove_reference :clients,
                     :workspace,
                     foreign_key: true

    remove_reference :users,
                     :workspace,
                     foreign_key: true
  end

  private

  def reset_migration_models
    MigrationUser.reset_column_information
    MigrationWorkspace.reset_column_information
    MigrationClient.reset_column_information
    MigrationLead.reset_column_information
    MigrationTag.reset_column_information
  end

  def workspace_name_for(user)
    full_name = [
      user.first_name,
      user.last_name
    ].compact.join(" ").strip

    return "Workspace #{user.id}" if full_name.blank?

    "#{full_name}'s Workspace"
  end
end