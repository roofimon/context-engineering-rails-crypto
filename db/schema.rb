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

ActiveRecord::Schema[8.0].define(version: 2025_11_08_023936) do
  create_table "historical_price_data", force: :cascade do |t|
    t.string "symbol", null: false
    t.string "date", null: false
    t.decimal "open", precision: 20, scale: 4
    t.decimal "high", precision: 20, scale: 4
    t.decimal "low", precision: 20, scale: 4
    t.decimal "close", precision: 20, scale: 4
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["symbol", "date"], name: "index_historical_price_data_on_symbol_and_date", unique: true
    t.index ["symbol"], name: "index_historical_price_data_on_symbol"
  end
end
