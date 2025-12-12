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

ActiveRecord::Schema[8.0].define(version: 2025_12_12_143125) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

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

  create_table "books", force: :cascade do |t|
    t.string "title"
    t.string "author"
    t.datetime "uploaded_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_books_on_user_id"
  end

  create_table "chapters", force: :cascade do |t|
    t.bigint "book_id", null: false
    t.string "title"
    t.integer "position"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["book_id", "position"], name: "index_chapters_on_book_id_and_position"
    t.index ["book_id"], name: "index_chapters_on_book_id"
  end

  create_table "passages", force: :cascade do |t|
    t.bigint "chapter_id", null: false
    t.text "content"
    t.integer "position"
    t.integer "word_count"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "previous_passage_id"
    t.bigint "next_passage_id"
    t.index ["chapter_id", "position"], name: "index_passages_on_chapter_id_and_position"
    t.index ["chapter_id"], name: "index_passages_on_chapter_id"
    t.index ["next_passage_id"], name: "index_passages_on_next_passage_id"
    t.index ["previous_passage_id"], name: "index_passages_on_previous_passage_id"
  end

  create_table "staged_books", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "title"
    t.string "author"
    t.jsonb "chapters_data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_staged_books_on_user_id"
  end

  create_table "typing_sessions", force: :cascade do |t|
    t.bigint "passage_id", null: false
    t.integer "wpm"
    t.decimal "accuracy"
    t.integer "duration_seconds"
    t.datetime "completed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["passage_id"], name: "index_typing_sessions_on_passage_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "username", null: false
    t.string "password_digest", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["username"], name: "index_users_on_username", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "books", "users"
  add_foreign_key "chapters", "books"
  add_foreign_key "passages", "chapters"
  add_foreign_key "passages", "passages", column: "next_passage_id", name: "fk_passages_next_passage", on_delete: :nullify
  add_foreign_key "passages", "passages", column: "previous_passage_id", name: "fk_passages_previous_passage", on_delete: :nullify
  add_foreign_key "staged_books", "users"
  add_foreign_key "typing_sessions", "passages"
end
