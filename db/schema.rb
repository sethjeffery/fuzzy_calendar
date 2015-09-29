# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20150925223210) do

  create_table "authentications", force: :cascade do |t|
    t.integer  "user_id",    null: false
    t.string   "provider",   null: false
    t.string   "uid",        null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "comments", force: :cascade do |t|
    t.integer  "author_id"
    t.string   "content"
    t.integer  "commentable_id"
    t.string   "commentable_type"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
  end

  create_table "event_user_times", force: :cascade do |t|
    t.integer  "event_user_id",                 null: false
    t.datetime "time",                          null: false
    t.boolean  "favorite",      default: false, null: false
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
  end

  add_index "event_user_times", ["event_user_id"], name: "index_event_user_times_on_event_user_id"

  create_table "event_users", force: :cascade do |t|
    t.integer  "event_id",   null: false
    t.integer  "user_id",    null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "event_users", ["event_id", "user_id"], name: "index_event_users_on_event_id_and_user_id", unique: true
  add_index "event_users", ["user_id"], name: "index_event_users_on_user_id"

  create_table "events", force: :cascade do |t|
    t.integer  "creator_id",                          null: false
    t.datetime "starts_at",                           null: false
    t.datetime "ends_at",                             null: false
    t.datetime "agreed_time"
    t.string   "name",                                null: false
    t.string   "description"
    t.string   "specificity",        default: "day",  null: false
    t.string   "state",              default: "open", null: false
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.string   "cover_file_name"
    t.string   "cover_content_type"
    t.integer  "cover_file_size"
    t.datetime "cover_updated_at"
  end

  add_index "events", ["creator_id"], name: "index_events_on_creator_id"

  create_table "users", force: :cascade do |t|
    t.string   "email"
    t.string   "crypted_password"
    t.string   "salt"
    t.string   "name",                null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "avatar_file_name"
    t.string   "avatar_content_type"
    t.integer  "avatar_file_size"
    t.datetime "avatar_updated_at"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true

end
