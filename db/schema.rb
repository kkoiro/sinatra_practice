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

ActiveRecord::Schema.define(version: 20171018125057) do

  create_table "attendees", force: :cascade do |t|
    t.string "email", null: false
    t.string "name", null: false
    t.string "password_digest", null: false
    t.integer "organization_id", null: false
    t.string "login_secret", null: false
    t.index ["email"], name: "index_attendees_on_email", unique: true
    t.index ["login_secret"], name: "index_attendees_on_login_secret", unique: true
  end

  create_table "organizations", force: :cascade do |t|
    t.string "name", null: false
  end

  create_table "photos", force: :cascade do |t|
    t.string "file_name", null: false
  end

  create_table "presentation_votes", force: :cascade do |t|
    t.integer "voter_id", null: false
    t.integer "presentation_id", null: false
  end

  create_table "presentations", force: :cascade do |t|
    t.integer "presenter_id", null: false
    t.string "title", null: false
    t.string "slide_title", default: "Not Uploaded"
    t.boolean "slide", default: false, null: false
    t.integer "session_id", null: false
    t.datetime "start_time", null: false
    t.datetime "finish_time", null: false
  end

  create_table "questioner_votes", force: :cascade do |t|
    t.integer "voter_id", null: false
    t.integer "questioner_id", null: false
  end

  create_table "rooms", force: :cascade do |t|
    t.string "name", null: false
  end

  create_table "sessions", force: :cascade do |t|
    t.string "title", null: false
    t.integer "chairperson_id", null: false
    t.integer "room_id", null: false
  end

end
