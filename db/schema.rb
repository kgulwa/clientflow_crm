# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.0].define(version: 2026_08_09_164405) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "client_tags", force: :cascade do |t|
    t.bigint "client_id", null: false
    t.bigint "tag_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["client_id", "tag_id"], name: "index_client_tags_on_client_id_and_tag_id", unique: true
    t.index ["client_id"], name: "index_client_tags_on_client_id"
    t.index ["tag_id"], name: "index_client_tags_on_tag_id"
  end

  create_table "clients", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "first_name", null: false
    t.string "last_name", null: false
    t.string "company_name"
    t.string "email", null: false
    t.string "phone"
    t.integer "status", default: 0, null: false
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "workspace_id", null: false
    t.index ["status"], name: "index_clients_on_status"
    t.index ["user_id", "email"], name: "index_clients_on_user_id_and_email", unique: true
    t.index ["user_id"], name: "index_clients_on_user_id"
    t.index ["workspace_id"], name: "index_clients_on_workspace_id"
  end

  create_table "contacts", force: :cascade do |t|
    t.bigint "client_id", null: false
    t.string "first_name"
    t.string "last_name"
    t.string "job_title"
    t.string "department"
    t.string "email"
    t.string "phone"
    t.boolean "primary_contact", default: false, null: false
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["client_id"], name: "index_contacts_on_client_id"
  end

  create_table "deals", force: :cascade do |t|
    t.bigint "client_id", null: false
    t.string "title", null: false
    t.integer "stage", default: 0, null: false
    t.decimal "value", precision: 12, scale: 2, default: "0.0", null: false
    t.date "expected_close_date"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["client_id"], name: "index_deals_on_client_id"
    t.index ["expected_close_date"], name: "index_deals_on_expected_close_date"
    t.index ["stage"], name: "index_deals_on_stage"
  end

  create_table "leads", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "first_name", null: false
    t.string "last_name", null: false
    t.string "company_name"
    t.string "email", null: false
    t.string "phone"
    t.integer "source", default: 0, null: false
    t.integer "status", default: 0, null: false
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "workspace_id", null: false
    t.index ["source"], name: "index_leads_on_source"
    t.index ["status"], name: "index_leads_on_status"
    t.index ["user_id", "status"], name: "index_leads_on_user_id_and_status"
    t.index ["user_id"], name: "index_leads_on_user_id"
    t.index ["workspace_id"], name: "index_leads_on_workspace_id"
  end

  create_table "notes", force: :cascade do |t|
    t.bigint "client_id", null: false
    t.string "title", null: false
    t.text "content", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["client_id", "created_at"], name: "index_notes_on_client_id_and_created_at"
    t.index ["client_id"], name: "index_notes_on_client_id"
  end

  create_table "tags", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "name", null: false
    t.string "color", default: "indigo", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "workspace_id", null: false
    t.index "workspace_id, lower((name)::text)", name: "index_tags_on_workspace_id_and_lower_name", unique: true
    t.index ["user_id"], name: "index_tags_on_user_id"
    t.index ["workspace_id"], name: "index_tags_on_workspace_id"
  end

  create_table "tasks", force: :cascade do |t|
    t.bigint "client_id", null: false
    t.string "title", null: false
    t.text "description"
    t.date "due_date", null: false
    t.integer "status", default: 0, null: false
    t.integer "priority", default: 1, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "started_at"
    t.datetime "completed_at"
    t.index ["client_id", "due_date"], name: "index_tasks_on_client_id_and_due_date"
    t.index ["client_id", "status"], name: "index_tasks_on_client_id_and_status"
    t.index ["client_id"], name: "index_tasks_on_client_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "first_name", null: false
    t.string "last_name", null: false
    t.integer "role", default: 0, null: false
    t.bigint "workspace_id", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["role"], name: "index_users_on_role"
    t.index ["workspace_id"], name: "index_users_on_workspace_id"
  end

  create_table "workspace_invitations", force: :cascade do |t|
    t.bigint "workspace_id", null: false
    t.bigint "invited_by_id", null: false
    t.string "email", null: false
    t.string "token", null: false
    t.integer "status", default: 0, null: false
    t.datetime "accepted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["invited_by_id"], name: "index_workspace_invitations_on_invited_by_id"
    t.index ["token"], name: "index_workspace_invitations_on_token", unique: true
    t.index ["workspace_id", "email"], name: "index_pending_workspace_invitations_on_workspace_and_email", unique: true, where: "(status = 0)"
    t.index ["workspace_id"], name: "index_workspace_invitations_on_workspace_id"
  end

  create_table "workspaces", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "client_tags", "clients"
  add_foreign_key "client_tags", "tags"
  add_foreign_key "clients", "users"
  add_foreign_key "clients", "workspaces"
  add_foreign_key "contacts", "clients"
  add_foreign_key "deals", "clients"
  add_foreign_key "leads", "users"
  add_foreign_key "leads", "workspaces"
  add_foreign_key "notes", "clients"
  add_foreign_key "tags", "users"
  add_foreign_key "tags", "workspaces"
  add_foreign_key "tasks", "clients"
  add_foreign_key "users", "workspaces"
  add_foreign_key "workspace_invitations", "users", column: "invited_by_id"
  add_foreign_key "workspace_invitations", "workspaces"
end
