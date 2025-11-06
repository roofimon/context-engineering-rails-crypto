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
  get "market_trend", to: "market_data#market_trend", as: :market_trend
  
  # Wallet routes
  get "wallet", to: "wallet#index", as: :wallet

  # Buy crypto routes
  get "cryptos/:symbol/buy", to: "cryptos#buy", as: :buy_crypto
  
  # Order routes
  post "orders/:symbol/confirm", to: "orders#confirm", as: :confirm_order
  get "orders/:symbol/verify_pin", to: "orders#verify_pin", as: :verify_order_pin
  post "orders/:symbol/verify_pin", to: "orders#verify_pin"
  post "orders/:symbol", to: "orders#create", as: :create_order

  # PIN authentication routes
  resources :pins, only: [:new, :create, :destroy]
  # Reset PIN (no ID) routes
  get "pins/reset", to: "pins#edit", as: :edit_pin
  patch "pins/reset", to: "pins#update", as: :update_pin
  delete "logout", to: "pins#destroy", as: :logout
end
