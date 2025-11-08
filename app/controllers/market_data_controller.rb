class MarketDataController < ApplicationController
  include AssetHelper

  # ============================================================================
  # MENU PAGES (aligned with bottom navigation menu)
  # ============================================================================
  
  # Home - Main market prices page
  def home
    @assets = index_assets
    @assets.each do |asset|
      symbol = asset[:symbol].to_s.upcase
      
      # Get last 7 days of close prices from SQLite
      records = HistoricalPriceData.for_symbol(symbol)
                                    .order(date: :desc)
                                    .limit(7)
                                    .to_a
                                    .reverse # Reverse to get oldest first (for chart)
      
      # Print data that matches the query
      puts "=" * 60
      puts "📊 Querying #{symbol} from SQLite:"
      puts "-" * 60
      puts "Found #{records.length} records:"
      records.each_with_index do |record, index|
        puts "  Day #{index + 1}: #{record.date} - Close: $#{record.close.to_f.round(4)}"
      end
      puts "-" * 60
      
      # Extract close prices for price history
      price_history = records.map { |r| r.close.to_f }
      asset[:price_history] = price_history
      
      puts "Price history array: #{price_history.inspect}"
      puts "=" * 60
      puts ""
    end
  end

  # Activities - Transaction history page
  def activities
    @orders = session[:orders] || []
    # Sort orders by timestamp, most recent first
    @orders = @orders.sort_by { |order| order["timestamp"] }.reverse
  end

  # Market Trend - Area charts page
  def market_trend
    @assets = index_assets
    
    # Try to load Binance historical data
    binance_data = load_binance_historical_data
    
    @assets = @assets.map do |asset|
      symbol = asset[:symbol].to_sym
      
      # Use Binance data if available, otherwise generate
      if binance_data[symbol] && binance_data[symbol][:candlestick_data]
        asset.merge(
          candlestick_data: binance_data[symbol][:candlestick_data],
          dates: binance_data[symbol][:dates]
        )
      else
        # Fallback to generated data
        generate_candlestick_data(asset, days: 30)
      end
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

