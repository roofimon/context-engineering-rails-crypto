module AssetHelper
  extend ActiveSupport::Concern

  private

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

  def find_asset_by_symbol(symbol)
    @assets ||= index_assets
    @assets.find { |a| a[:symbol] == symbol.upcase }
  end
end

