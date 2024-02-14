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

ActiveRecord::Schema[7.1].define(version: 2024_02_14_072813) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "sites", force: :cascade do |t|
    t.string "name", null: false
    t.integer "concurrent_refresh_limit", default: 50, null: false
    t.integer "refresh_interval_in_minutes", default: 1440, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "sites_bulk_refreshes", force: :cascade do |t|
    t.bigint "site_id", null: false
    t.jsonb "page_data", null: false
    t.string "status", default: "pending", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["site_id"], name: "index_sites_bulk_refreshes_on_site_id"
  end

  create_table "sites_pages", force: :cascade do |t|
    t.bigint "site_id", null: false
    t.string "url", null: false
    t.text "content"
    t.string "refresh_status", default: "pending", null: false
    t.datetime "refresh_queued_at"
    t.datetime "refreshed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["site_id"], name: "index_sites_pages_on_site_id"
  end

  add_foreign_key "sites_bulk_refreshes", "sites"
  add_foreign_key "sites_pages", "sites"
end
