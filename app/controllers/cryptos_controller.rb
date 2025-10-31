class CryptosController < ApplicationController
  def index
    @assets = index_assets
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
    
    if asset
      market_price = params[:market_price].to_f
      units = params[:units].to_f
      
      # Here you would process the buy order
      # For now, we'll just redirect back with a success message
      redirect_to root_path, notice: "Buy order placed for #{asset[:name]} (#{asset[:symbol]})"
    else
      redirect_to root_path, alert: "Asset not found"
    end
  end

  private

  def find_asset_by_symbol(symbol)
    @assets ||= index_assets
    @assets.find { |a| a[:symbol] == symbol.upcase }
  end

  def index_assets
    [
      {
        name: "Bitcoin",
        symbol: "BTC",
        icon: "₿",
        quantity: 2.5,
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
        quantity: 10.25,
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
        quantity: 5.0,
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
        quantity: 500.0,
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
        quantity: 25.5,
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
        quantity: 100.0,
        exchanges: {
          "Binance" => { price: nil, change: nil },
          "Coinbase" => { price: 69.45, change: nil }
        },
        overall_price: 69.02,
        change: 7.6
      }
    ]
  end
end

