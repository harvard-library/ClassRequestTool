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

ActiveRecord::Schema.define(version: 2020_11_16_213206) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "additional_patrons", id: :serial, force: :cascade do |t|
    t.string "first_name"
    t.string "last_name"
    t.string "email"
    t.integer "course_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "role"
  end

  create_table "affiliates", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "url"
    t.text "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "position"
    t.index ["position"], name: "index_affiliates_on_position"
  end

  create_table "assessments", id: :serial, force: :cascade do |t|
    t.text "using_materials"
    t.text "involvement"
    t.integer "staff_experience"
    t.integer "staff_availability"
    t.integer "space"
    t.integer "request_course"
    t.integer "request_materials"
    t.integer "catalogs"
    t.integer "digital_collections"
    t.string "involve_again", limit: 255
    t.text "not_involve_again"
    t.text "better_future"
    t.text "comments"
    t.integer "course_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["better_future"], name: "index_assessments_on_better_future"
    t.index ["catalogs"], name: "index_assessments_on_catalogs"
    t.index ["digital_collections"], name: "index_assessments_on_digital_collections"
    t.index ["involve_again"], name: "index_assessments_on_involve_again"
    t.index ["involvement"], name: "index_assessments_on_involvement"
    t.index ["not_involve_again"], name: "index_assessments_on_not_involve_again"
    t.index ["request_course"], name: "index_assessments_on_request_course"
    t.index ["request_materials"], name: "index_assessments_on_request_materials"
    t.index ["space"], name: "index_assessments_on_space"
    t.index ["staff_availability"], name: "index_assessments_on_staff_availability"
    t.index ["staff_experience"], name: "index_assessments_on_staff_experience"
    t.index ["using_materials"], name: "index_assessments_on_using_materials"
  end

  create_table "attached_images", id: :serial, force: :cascade do |t|
    t.string "image"
    t.string "caption"
    t.integer "picture_id"
    t.string "picture_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "featured"
    t.index ["featured"], name: "index_attached_images_on_featured"
    t.index ["picture_id", "picture_type"], name: "index_attached_images_on_picture_id_and_picture_type"
  end

  create_table "ckeditor_assets", id: :serial, force: :cascade do |t|
    t.string "data_file_name", null: false
    t.string "data_content_type"
    t.integer "data_file_size"
    t.integer "assetable_id"
    t.string "assetable_type", limit: 30
    t.string "type", limit: 30
    t.integer "width"
    t.integer "height"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["assetable_type", "assetable_id"], name: "idx_ckeditor_assetable"
    t.index ["assetable_type", "type", "assetable_id"], name: "idx_ckeditor_assetable_type"
  end

  create_table "collections", id: :serial, force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.string "url"
    t.integer "repository_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["repository_id"], name: "index_collections_on_repository_id"
  end

  create_table "courses", id: :serial, force: :cascade do |t|
    t.string "title", limit: 255
    t.string "subject", limit: 255
    t.string "course_number", limit: 255
    t.string "affiliation", limit: 255
    t.string "contact_email", limit: 150, null: false
    t.string "contact_phone", limit: 25
    t.datetime "pre_class_appt"
    t.datetime "pre_class_appt_choice_1"
    t.datetime "pre_class_appt_choice_2"
    t.datetime "pre_class_appt_choice_3"
    t.integer "repository_id"
    t.text "staff_involvement"
    t.integer "number_of_students"
    t.string "status", limit: 255
    t.string "syllabus", limit: 255
    t.string "external_syllabus", limit: 255
    t.string "duration", limit: 255
    t.text "comments"
    t.integer "session_count"
    t.text "goal"
    t.string "instruction_session", limit: 255
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "contact_first_name", limit: 100
    t.string "contact_last_name", limit: 100
    t.string "contact_username", limit: 100
    t.integer "primary_contact_id"
    t.integer "section_count"
    t.integer "total_attendance"
    t.datetime "first_date"
    t.datetime "last_date"
    t.boolean "scheduled"
    t.integer "assisting_repository_id"
    t.text "collaboration_options", default: [], array: true
    t.index ["affiliation"], name: "index_courses_on_affiliation"
    t.index ["contact_email"], name: "index_courses_on_contact_email"
    t.index ["contact_phone"], name: "index_courses_on_contact_phone"
    t.index ["course_number"], name: "index_courses_on_course_number"
    t.index ["duration"], name: "index_courses_on_duration"
    t.index ["first_date", "last_date"], name: "index_courses_on_first_date_and_last_date"
    t.index ["instruction_session"], name: "index_courses_on_instruction_session"
    t.index ["pre_class_appt"], name: "index_courses_on_pre_class_appt"
    t.index ["scheduled"], name: "index_courses_on_scheduled"
    t.index ["session_count", "section_count", "total_attendance"], name: "courses_index_sessions_sections_attendance"
    t.index ["session_count"], name: "index_courses_on_session_count"
    t.index ["staff_involvement"], name: "index_courses_on_staff_involvement"
    t.index ["status"], name: "index_courses_on_status"
    t.index ["subject"], name: "index_courses_on_subject"
    t.index ["title"], name: "index_courses_on_title"
  end

  create_table "courses_item_attributes", id: false, force: :cascade do |t|
    t.integer "item_attribute_id"
    t.integer "course_id"
  end

  create_table "courses_staff_services", id: false, force: :cascade do |t|
    t.integer "course_id"
    t.integer "staff_service_id"
  end

  create_table "courses_users", id: false, force: :cascade do |t|
    t.integer "course_id"
    t.integer "user_id"
  end

  create_table "custom_texts", id: :serial, force: :cascade do |t|
    t.string "key"
    t.text "text"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["key"], name: "index_custom_texts_on_key"
  end

  create_table "customizations", id: :serial, force: :cascade do |t|
    t.string "institution"
    t.string "institution_long"
    t.string "tool_name"
    t.string "tool_tech_admin_name"
    t.string "tool_tech_admin_email"
    t.string "tool_content_admin_name"
    t.string "tool_content_admin_email"
    t.string "default_email_sender"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "slogan"
    t.boolean "notifications_on"
    t.integer "homeless_staff_services", default: [], array: true
    t.integer "homeless_technologies", default: [], array: true
    t.text "collaboration_options", default: [], array: true
    t.text "feedback_link"
    t.text "welcome"
  end

  create_table "delayed_jobs", id: :serial, force: :cascade do |t|
    t.integer "priority", default: 0, null: false
    t.integer "attempts", default: 0, null: false
    t.text "handler", null: false
    t.text "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string "locked_by"
    t.string "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["priority", "run_at"], name: "delayed_jobs_priority"
  end

  create_table "emails", id: :serial, force: :cascade do |t|
    t.text "to"
    t.string "bcc", limit: 255
    t.string "from", limit: 255
    t.string "reply_to", limit: 255
    t.string "subject", limit: 255
    t.text "body"
    t.date "date_sent"
    t.boolean "message_sent", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "item_attributes", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255, null: false
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["description"], name: "index_item_attributes_on_description"
    t.index ["name"], name: "index_item_attributes_on_name"
  end

  create_table "item_attributes_repositories", id: false, force: :cascade do |t|
    t.integer "item_attribute_id"
    t.integer "repository_id"
    t.index ["item_attribute_id", "repository_id"], name: "index_item_attributes_repositories_on_join", unique: true
  end

  create_table "item_attributes_rooms", id: false, force: :cascade do |t|
    t.integer "item_attribute_id"
    t.integer "room_id"
    t.index ["item_attribute_id", "room_id"], name: "index_item_attributes_rooms_on_join", unique: true
  end

  create_table "notes", id: :serial, force: :cascade do |t|
    t.text "note_text", null: false
    t.integer "user_id", null: false
    t.integer "course_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "staff_comment", default: false, null: false
    t.boolean "auto", default: false
    t.index ["note_text"], name: "index_notes_on_note_text"
  end

  create_table "repositories", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255
    t.text "description"
    t.integer "class_limit", default: 0
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "calendar"
    t.string "landing_page", limit: 255
    t.string "class_policies"
    t.text "email_details"
    t.index ["class_limit"], name: "index_repositories_on_class_limit"
    t.index ["description"], name: "index_repositories_on_description"
    t.index ["name"], name: "index_repositories_on_name"
  end

  create_table "repositories_rooms", id: false, force: :cascade do |t|
    t.integer "repository_id"
    t.integer "room_id"
  end

  create_table "repositories_staff_services", id: false, force: :cascade do |t|
    t.integer "repository_id"
    t.integer "staff_service_id"
  end

  create_table "repositories_users", id: false, force: :cascade do |t|
    t.integer "repository_id"
    t.integer "user_id"
    t.index ["repository_id", "user_id"], name: "index_repositories_users_on_repository_id_and_user_id", unique: true
  end

  create_table "rooms", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "class_limit", default: 0
    t.index ["name"], name: "index_rooms_on_name"
  end

  create_table "sections", id: :serial, force: :cascade do |t|
    t.datetime "requested_dates", array: true
    t.datetime "actual_date"
    t.integer "session", default: 1, null: false
    t.integer "course_id"
    t.integer "room_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "headcount"
    t.integer "session_duration"
    t.text "meeting_link"
    t.index ["actual_date"], name: "index_sections_on_actual_date"
    t.index ["course_id"], name: "index_sections_on_course_id"
    t.index ["session_duration"], name: "index_sections_on_session_duration"
  end

  create_table "staff_services", id: :serial, force: :cascade do |t|
    t.string "description", limit: 255
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "required"
    t.index ["description"], name: "index_staff_services_on_description"
  end

  create_table "users", id: :serial, force: :cascade do |t|
    t.string "email", limit: 255, default: "", null: false
    t.string "encrypted_password", limit: 255, default: "", null: false
    t.string "reset_password_token", limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip", limit: 255
    t.string "last_sign_in_ip", limit: 255
    t.boolean "admin", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "first_name", limit: 100
    t.string "last_name", limit: 100
    t.boolean "staff", default: false, null: false
    t.boolean "patron", default: true, null: false
    t.string "username", limit: 255, default: "", null: false
    t.boolean "superadmin", default: false, null: false
    t.boolean "pinuser", default: false, null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

end
