class CreateHistoricalPriceData < ActiveRecord::Migration[8.0]
  def change
    create_table :historical_price_data do |t|
      t.string :symbol, null: false
      t.string :date, null: false
      t.decimal :open, precision: 20, scale: 4
      t.decimal :high, precision: 20, scale: 4
      t.decimal :low, precision: 20, scale: 4
      t.decimal :close, precision: 20, scale: 4

      t.timestamps
    end
    
    add_index :historical_price_data, :symbol
    add_index :historical_price_data, [:symbol, :date], unique: true
  end
end
