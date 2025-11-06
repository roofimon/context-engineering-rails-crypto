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
    @assets.each do |asset|
      base_price = asset[:overall_price]
      volatility = asset[:volatility] || 0.02
      
      # Generate realistic 30-day candlestick data with trend
      # Use deterministic seed based on asset symbol for consistency
      Random.srand(asset[:symbol].hash)
      
      # Start price 30 days ago (can be higher or lower than current)
      start_price = base_price * (0.90 + rand * 0.20)
      trend_per_day = (base_price - start_price) / 29.0
      
      previous_close = nil
      asset[:candlestick_data] = 30.times.map do |i|
        # Base price with trend
        trend_price = start_price + (trend_per_day * i)
        
        # Open price: previous close with gap (-5% to +5%), or start price for first day
        if i == 0
          open_price = trend_price
        else
          # Gap between sessions (5% range)
          gap = (rand - 0.5) * 0.10 # -5% to +5%
          open_price = previous_close * (1.0 + gap)
        end
        
        # Daily price change: realistic volatility
        daily_change = (rand - 0.5) * volatility * 2
        close_price = open_price * (1.0 + daily_change)
        
        # High and low: realistic wicks (0.5% - 2% of body)
        body_high = [open_price, close_price].max
        body_low = [open_price, close_price].min
        body_size = body_high - body_low
        
        # High wick: 0.5% - 2% of body
        high_wick = body_size * (0.005 + rand * 0.015)
        high_price = body_high + high_wick
        
        # Low wick: 0.5% - 2% of body  
        low_wick = body_size * (0.005 + rand * 0.015)
        low_price = body_low - low_wick
        
        # Ensure high >= max(open, close) and low <= min(open, close)
        high_price = [high_price, open_price, close_price].max
        low_price = [low_price, open_price, close_price].min
        
        previous_close = close_price
        
        [open_price.round(4), high_price.round(4), low_price.round(4), close_price.round(4)]
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

