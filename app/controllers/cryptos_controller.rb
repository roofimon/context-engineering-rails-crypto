class CryptosController < ApplicationController
  def index
    @assets = index_assets
  end

  def activities
    @orders = session[:orders] || []
    # Sort orders by timestamp, most recent first
    @orders = @orders.sort_by { |order| order["timestamp"] }.reverse
  end

  def buy
    symbol = params[:symbol]
    @asset = find_asset_by_symbol(symbol)
    
    unless @asset
      redirect_to root_path, alert: "Asset not found"
    end
  end

  def create_order
    symbol = params[:symbol]
    asset = find_asset_by_symbol(symbol)
    
    unless asset
      redirect_to root_path, alert: "Asset not found"
      return
    end

    units = params[:units].to_f
    
    # Validate units
    if units < 1
      redirect_to buy_crypto_path(symbol), alert: "Number of units must be at least 1.00"
      return
    end

    # Validate decimal places (max 2)
    units_str = params[:units].to_s
    if units_str.include?('.')
      decimal_places = units_str.split('.')[1]&.length || 0
      if decimal_places > 2
        redirect_to buy_crypto_path(symbol), alert: "Number of units can have maximum 2 decimal places"
        return
      end
    end

    market_price = params[:market_price].to_f
    
    # Store order in session (Rails sessions store with string keys)
    order = {
      "symbol" => symbol.upcase,
      "units" => units,
      "price" => market_price,
      "timestamp" => Time.current.to_s
    }
    
    session[:orders] ||= []
    session[:orders] << order
    
    redirect_to root_path, notice: "Buy order placed for #{asset[:name]} (#{asset[:symbol]})"
  end

  private

  def find_asset_by_symbol(symbol)
    @assets ||= index_assets
    @assets.find { |a| a[:symbol] == symbol.upcase }
  end

  def index_assets
    base_assets = [
      {
        name: "Bitcoin",
        symbol: "BTC",
        icon: "₿",
        initial_quantity: 2.5,
        exchanges: {
          "Binance" => { price: 94245.32, change: nil },
          "Coinbase" => { price: 94312.03, change: nil }
        },
        overall_price: 94245.50,
        change: 1.25
      },
      {
        name: "Ethereum",
        symbol: "ETH",
        icon: "Ξ",
        initial_quantity: 10.25,
        exchanges: {
          "Binance" => { price: 6032.15, change: :up },
          "Coinbase" => { price: 5998.71, change: :down }
        },
        overall_price: 6018.42,
        change: 1.25
      },
      {
        name: "Binance",
        symbol: "BNB",
        icon: "BNB",
        initial_quantity: 5.0,
        exchanges: {
          "Binance" => { price: 2789.01, change: nil },
          "Coinbase" => { price: 2708.75, change: :down }
        },
        overall_price: 2781.28,
        change: 0.75
      },
      {
        name: "Cardano",
        symbol: "ADA",
        icon: "ADA",
        initial_quantity: 500.0,
        exchanges: {
          "Binance" => { price: 4.02, change: nil },
          "Coinbase" => { price: 3.98, change: :down }
        },
        overall_price: 4.08,
        change: 2.28
      },
      {
        name: "Solana",
        symbol: "SOL",
        icon: "SOL",
        initial_quantity: 25.5,
        exchanges: {
          "Binance" => { price: 144.18, change: :down },
          "Coinbase" => { price: 145.28, change: nil }
        },
        overall_price: 145.16,
        change: 7.6
      },
      {
        name: "Polkadot",
        symbol: "DOT",
        icon: "DOT",
        initial_quantity: 100.0,
        exchanges: {
          "Binance" => { price: nil, change: nil },
          "Coinbase" => { price: 69.45, change: nil }
        },
        overall_price: 69.02,
        change: 7.6
      }
    ]

    # Calculate current quantity based on orders
    orders = session[:orders] || []
    
    base_assets.map do |asset|
      # Calculate total purchased units for this asset
      purchased_units = orders
        .select { |order| order["symbol"] == asset[:symbol] }
        .sum { |order| order["units"].to_f }
      
      # Current quantity = initial quantity + purchased units
      current_quantity = asset[:initial_quantity] + purchased_units
      
      asset.merge(quantity: current_quantity)
    end
  end

end

