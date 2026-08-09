# frozen_string_literal: true

class ScopeTagNameUniquenessToWorkspace < ActiveRecord::Migration[7.0]
  OLD_INDEX_NAME = "index_tags_on_user_id_and_lower_name"
  NEW_INDEX_NAME = "index_tags_on_workspace_id_and_lower_name"

  def up
    remove_index :tags, name: OLD_INDEX_NAME

    add_index :tags,
              "workspace_id, lower(name)",
              unique: true,
              name: NEW_INDEX_NAME
  end

  def down
    remove_index :tags, name: NEW_INDEX_NAME

    add_index :tags,
              "user_id, lower(name)",
              unique: true,
              name: OLD_INDEX_NAME
  end
end