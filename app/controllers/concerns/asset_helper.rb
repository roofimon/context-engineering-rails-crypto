module AssetHelper
  extend ActiveSupport::Concern

  private

  def index_assets
    # Use time-based seed for consistency within a request
    seed = Time.now.to_i / 3600 # Changes every hour
    
    base_assets = [
      {
        name: "Bitcoin",
        symbol: "BTC",
        icon: "₿",
        initial_quantity: 2.5,
        base_price: 94250.0,
        volatility: 0.02 # 2% volatility
      },
      {
        name: "Ethereum",
        symbol: "ETH",
        icon: "Ξ",
        initial_quantity: 10.25,
        base_price: 6015.0,
        volatility: 0.025 # 2.5% volatility
      },
      {
        name: "Binance Coin",
        symbol: "BNB",
        icon: "BNB",
        initial_quantity: 5.0,
        base_price: 2780.0,
        volatility: 0.03 # 3% volatility
      },
      {
        name: "Cardano",
        symbol: "ADA",
        icon: "ADA",
        initial_quantity: 500.0,
        base_price: 4.00,
        volatility: 0.04 # 4% volatility
      },
      {
        name: "Solana",
        symbol: "SOL",
        icon: "SOL",
        initial_quantity: 25.5,
        base_price: 145.0,
        volatility: 0.035 # 3.5% volatility
      },
      {
        name: "Polkadot",
        symbol: "DOT",
        icon: "DOT",
        initial_quantity: 100.0,
        base_price: 69.0,
        volatility: 0.04 # 4% volatility
      }
    ]

    # Calculate current quantity based on orders
    orders = session[:orders] || []

    base_assets.map do |asset|
      # Generate realistic prices with hour-based variation
      Random.srand(seed + asset[:symbol].hash)
      
      # Base price with small random variation (±0.5%)
      current_base = asset[:base_price] * (0.995 + rand * 0.01)
      
      # 24h change: realistic range -8% to +12%
      change_percent = (rand - 0.3) * 20 # Bias slightly positive
      change_percent = [[change_percent, -8.0].max, 12.0].min
      
      # Exchange prices with realistic spreads (0.1% - 0.5%)
      spread = 0.001 + rand * 0.004
      binance_price = current_base * (1.0 - spread / 2)
      coinbase_price = current_base * (1.0 + spread / 2)
      
      # Determine exchange price changes (small variations)
      binance_change = rand < 0.5 ? :up : :down
      coinbase_change = rand < 0.5 ? :up : :down
      
      # Calculate average price
      avg_price = (binance_price + coinbase_price) / 2.0
      
      # Calculate current quantity
      purchased_units = orders
                        .select { |order| order["symbol"] == asset[:symbol] }
                        .sum { |order| order["units"].to_f }
      current_quantity = asset[:initial_quantity] + purchased_units
      
      {
        name: asset[:name],
        symbol: asset[:symbol],
        icon: asset[:icon],
        initial_quantity: asset[:initial_quantity],
        quantity: current_quantity,
        exchanges: {
          "Binance" => { price: binance_price.round(2), change: binance_change },
          "Coinbase" => { price: coinbase_price.round(2), change: coinbase_change }
        },
        overall_price: avg_price.round(2),
        change: change_percent.round(2),
        base_price: asset[:base_price],
        volatility: asset[:volatility]
      }
    end
  end

  def find_asset_by_symbol(symbol)
    @assets ||= index_assets
    @assets.find { |a| a[:symbol] == symbol.upcase }
  end
end

