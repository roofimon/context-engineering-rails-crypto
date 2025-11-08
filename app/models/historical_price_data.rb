class HistoricalPriceData < ApplicationRecord
  # Validations
  validates :symbol, presence: true
  validates :date, presence: true
  validates :open, :high, :low, :close, presence: true, numericality: true
  validates :date, uniqueness: { scope: :symbol, message: "already exists for this symbol" }

  # Scopes
  scope :for_symbol, ->(symbol) { where(symbol: symbol.to_s.upcase) }
  scope :ordered_by_date, -> { order(:date) }
  scope :recent, ->(days = 30) { ordered_by_date.limit(days) }

  # Class methods
  def self.fetch_for_symbol(symbol, days: 30)
    for_symbol(symbol).ordered_by_date.limit(days)
  end

  def self.upsert_data(symbol, date, open, high, low, close)
    find_or_initialize_by(symbol: symbol.to_s.upcase, date: date).tap do |record|
      record.open = open
      record.high = high
      record.low = low
      record.close = close
      record.save!
    end
  end

  def self.clear_symbol(symbol)
    for_symbol(symbol).delete_all
  end
end

