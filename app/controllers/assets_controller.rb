class AssetsController < ApplicationController
  def index
    @assets = [
      {
        name: "Bitcoin",
        symbol: "BTC",
        icon: "₿",
        exchanges: {
          "Binance" => { price: 94245.32, change: nil },
          "Coinbase" => { price: 94312.03, change: nil },
          "Huobi" => { price: 93199.45, change: nil },
          "FTX" => { price: 94212.21, change: nil }
        },
        overall_price: 94245.50,
        change: 1.25
      },
      {
        name: "Ethereum",
        symbol: "ETH",
        icon: "Ξ",
        exchanges: {
          "Binance" => { price: 6032.15, change: :up },
          "Coinbase" => { price: 5998.71, change: :down },
          "Huobi" => { price: 6010.00, change: nil },
          "FTX" => { price: 6024.02, change: nil }
        },
        overall_price: 6018.42,
        change: 1.25
      },
      {
        name: "Binance",
        symbol: "BNB",
        icon: "BNB",
        exchanges: {
          "Binance" => { price: 2789.01, change: nil },
          "Coinbase" => { price: 2708.75, change: :down },
          "Huobi" => { price: 2748.32, change: nil },
          "FTX" => { price: 2804.81, change: :up }
        },
        overall_price: 2781.28,
        change: 0.75
      },
      {
        name: "Cardano",
        symbol: "ADA",
        icon: "ADA",
        exchanges: {
          "Binance" => { price: 4.02, change: nil },
          "Coinbase" => { price: 3.98, change: :down },
          "Huobi" => { price: 4.15, change: :up },
          "FTX" => { price: 4.05, change: nil }
        },
        overall_price: 4.08,
        change: 2.28
      },
      {
        name: "Solana",
        symbol: "SOL",
        icon: "SOL",
        exchanges: {
          "Binance" => { price: 144.18, change: :down },
          "Coinbase" => { price: 145.28, change: nil },
          "Huobi" => { price: 144.57, change: nil },
          "FTX" => { price: 147.91, change: :up }
        },
        overall_price: 145.16,
        change: 7.6
      },
      {
        name: "Polkadot",
        symbol: "DOT",
        icon: "DOT",
        exchanges: {
          "Binance" => { price: nil, change: nil },
          "Coinbase" => { price: 69.45, change: nil },
          "Huobi" => { price: 68.87, change: :down },
          "FTX" => { price: 69.65, change: nil }
        },
        overall_price: 69.02,
        change: 7.6
      }
    ]
  end
end

