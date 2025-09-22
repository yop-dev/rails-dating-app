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

ActiveRecord::Schema[7.1].define(version: 202509211504006) do
  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "conversations", force: :cascade do |t|
    t.integer "user_a_id", null: false
    t.integer "user_b_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_a_id", "user_b_id"], name: "index_conversations_on_user_a_id_and_user_b_id", unique: true
    t.index ["user_a_id"], name: "index_conversations_on_user_a_id"
    t.index ["user_b_id"], name: "index_conversations_on_user_b_id"
  end

  create_table "likes", force: :cascade do |t|
    t.integer "liker_id", null: false
    t.integer "liked_id", null: false
    t.boolean "is_like", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["liked_id"], name: "index_likes_on_liked_id"
    t.index ["liker_id", "liked_id"], name: "index_likes_on_liker_id_and_liked_id", unique: true
    t.index ["liker_id"], name: "index_likes_on_liker_id"
  end

  create_table "matches", force: :cascade do |t|
    t.integer "user_one_id", null: false
    t.integer "user_two_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_one_id", "user_two_id"], name: "index_matches_on_user_one_id_and_user_two_id", unique: true
    t.index ["user_one_id"], name: "index_matches_on_user_one_id"
    t.index ["user_two_id"], name: "index_matches_on_user_two_id"
  end

  create_table "messages", force: :cascade do |t|
    t.integer "conversation_id", null: false
    t.integer "sender_id", null: false
    t.text "content", null: false
    t.boolean "read", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["conversation_id"], name: "index_messages_on_conversation_id"
    t.index ["sender_id"], name: "index_messages_on_sender_id"
  end

  create_table "photos", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "position", default: 0
    t.boolean "is_primary", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "url"
    t.index ["user_id"], name: "index_photos_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "first_name", null: false
    t.string "last_name", null: false
    t.string "mobile_number", null: false
    t.string "email", null: false
    t.date "birthdate", null: false
    t.string "gender", null: false
    t.string "sexual_orientation", null: false
    t.string "gender_interest", null: false
    t.string "country"
    t.string "state"
    t.string "city"
    t.string "school"
    t.text "bio", null: false
    t.string "password_digest", null: false
    t.string "role", default: "user", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "location"
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "conversations", "users", column: "user_a_id"
  add_foreign_key "conversations", "users", column: "user_b_id"
  add_foreign_key "likes", "users", column: "liked_id"
  add_foreign_key "likes", "users", column: "liker_id"
  add_foreign_key "matches", "users", column: "user_one_id"
  add_foreign_key "matches", "users", column: "user_two_id"
  add_foreign_key "messages", "conversations"
  add_foreign_key "messages", "users", column: "sender_id"
  add_foreign_key "photos", "users"
end
