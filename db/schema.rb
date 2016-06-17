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

ActiveRecord::Schema.define(version: 20160617031043) do

  create_table "bets", force: :cascade do |t|
    t.integer  "points"
    t.integer  "user_id"
    t.integer  "game_team_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "archived",     default: false
  end

  create_table "followings", force: :cascade do |t|
    t.integer  "follower"
    t.integer  "followee"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "game_teams", force: :cascade do |t|
    t.integer  "score"
    t.integer  "result"
    t.integer  "team_id"
    t.integer  "game_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "games", force: :cascade do |t|
    t.string   "status"
    t.datetime "datetime"
    t.string   "league"
    t.integer  "stadium_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "stadia", force: :cascade do |t|
    t.string   "name"
    t.string   "city"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "teams", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: :cascade do |t|
    t.string   "username"
    t.string   "password_hash"
    t.string   "email"
    t.integer  "points",        default: 1000
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
