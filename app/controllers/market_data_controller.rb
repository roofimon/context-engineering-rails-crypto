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
      volatility = asset[:volatility] || 0.02
      
      # Generate realistic 7-day price history with trend
      # Start from slightly lower price and trend towards current
      start_price = base_price * (0.95 + rand * 0.05)
      trend = (base_price - start_price) / 6.0 # Daily trend
      
      asset[:price_history] = 7.times.map do |i|
        # Base price with trend
        trend_price = start_price + (trend * i)
        # Add realistic daily volatility
        daily_change = (rand - 0.5) * 2 * volatility
        trend_price * (1.0 + daily_change)
      end
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
    @assets = @assets.map { |asset| generate_candlestick_data(asset, days: 30) }
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

