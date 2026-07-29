# frozen_string_literal: true

class AddConstraintsToTagsAndClientTags < ActiveRecord::Migration[7.0]
  def change
    change_column_null :tags, :name, false
    change_column_null :tags, :color, false
    change_column_default :tags, :color, from: nil, to: "indigo"

    add_index :tags,
              "user_id, LOWER(name)",
              unique: true,
              name: "index_tags_on_user_id_and_lower_name"

    add_index :client_tags,
              %i[client_id tag_id],
              unique: true
  end
end