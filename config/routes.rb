Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  root "market_data#home"

  # Market Data routes (menu pages)
  get "activities", to: "market_data#activities", as: :activities
  get "more", to: "market_data#more", as: :more
  get "wallet", to: "market_data#wallet", as: :wallet
  get "market_trend", to: "market_data#market_trend", as: :market_trend

  # Buy crypto routes
  get "cryptos/:symbol/buy", to: "cryptos#buy", as: :buy_crypto
  post "cryptos/:symbol/confirm", to: "cryptos#confirm", as: :confirm_order
  get "cryptos/:symbol/verify_pin", to: "cryptos#verify_order_pin", as: :verify_order_pin
  post "cryptos/:symbol/verify_pin", to: "cryptos#verify_order_pin"
  post "cryptos/:symbol/buy", to: "cryptos#create_order", as: :create_order

  # PIN authentication routes
  resources :pins, only: [:new, :create, :destroy]
  delete "logout", to: "pins#destroy", as: :logout
end
