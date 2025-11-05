class MarketDataController < ApplicationController
  include AssetHelper

  # ============================================================================
  # MENU PAGES (aligned with bottom navigation menu)
  # ============================================================================
  
  # Home - Main market prices page
  def home
    @assets = index_assets
    @assets.each do |asset|
      base_price = asset[:overall_price]
      # Generate fake 7-day price history
      asset[:price_history] = 7.times.map { |i| base_price * (0.9 + rand * 0.2) }.sort_by { |p| rand }
    end
  end

  # Activities - Transaction history page
  def activities
    @orders = session[:orders] || []
    # Sort orders by timestamp, most recent first
    @orders = @orders.sort_by { |order| order["timestamp"] }.reverse
  end

  # Market Trend - Candlestick charts page
  def market_trend
    @assets = index_assets
    @assets.each do |asset|
      base_price = asset[:overall_price]
      # Generate fake 30-day candlestick data (OHLC format)
      asset[:candlestick_data] = 30.times.map do |i|
        open_price = base_price * (0.85 + rand * 0.3)
        close_price = open_price * (0.95 + rand * 0.1)
        high_price = [open_price, close_price].max * (1.0 + rand * 0.05)
        low_price = [open_price, close_price].min * (0.95 - rand * 0.05)
        [open_price, high_price, low_price, close_price]
      end
      # Generate dates for the last 30 days
      asset[:dates] = 30.times.map { |i| (Date.today - (29 - i)).strftime("%m/%d") }
    end
  end

  # Wallet - Holdings page
  def wallet
    @assets = index_assets
  end

  # More - Additional options menu
  def more
    # Menu page with additional options
  end

end

