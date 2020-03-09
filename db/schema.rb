# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2020_02_22_115823) do

  create_table "comments", force: :cascade do |t|
    t.integer "user_id"
    t.integer "post_id", null: false
    t.integer "parent_id"
    t.text "text"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "karma", default: 0, null: false
    t.index ["post_id", "created_at"], name: "index_comments_on_post_id_and_created_at", order: { created_at: :desc }, where: "parent_id IS NULL"
    t.index ["post_id", "parent_id", "created_at"], name: "index_comments_on_post_id_and_parent_id_and_created_at", where: "parent_id IS NOT NULL"
  end

  create_table "posts", force: :cascade do |t|
    t.string "title"
    t.string "link"
    t.text "body"
    t.integer "user_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "karma", default: 0, null: false
    t.index ["created_at"], name: "by_recent"
    t.index ["title"], name: "index_posts_on_title"
    t.index ["user_id", "created_at"], name: "by_user_recent"
    t.index ["user_id"], name: "index_posts_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "username"
    t.string "email"
    t.string "password_digest"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "remember_digest"
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  create_table "votes", force: :cascade do |t|
    t.boolean "up"
    t.integer "user_id"
    t.string "votable_type", null: false
    t.integer "votable_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["votable_type", "votable_id", "up"], name: "index_votes_on_votable_type_and_votable_id_and_up_vs_down"
  end

  add_foreign_key "comments", "posts"
  add_foreign_key "comments", "users"
  add_foreign_key "posts", "users"
  add_foreign_key "votes", "users"
end
