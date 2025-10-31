class AssetsController < ApplicationController
  def index
    @assets = [
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

