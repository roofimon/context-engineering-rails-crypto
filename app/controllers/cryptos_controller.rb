class CryptosController < ApplicationController
  include AssetHelper

  # ============================================================================
  # BUY FLOW (crypto purchase workflow)
  # ============================================================================

  # Step 1: Buy form - Enter units
  def buy
    symbol = params[:symbol]
    @asset = find_asset_by_symbol(symbol)

    unless @asset
      redirect_to root_path, alert: "Asset not found"
      return
    end
  end

  # Step 2: Confirm order - Review summary
  def confirm
    symbol = params[:symbol]
    @asset = find_asset_by_symbol(symbol)

    unless @asset
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
    if units_str.include?(".")
      decimal_places = units_str.split(".")[1]&.length || 0
      if decimal_places > 2
        redirect_to buy_crypto_path(symbol), alert: "Number of units can have maximum 2 decimal places"
        return
      end
    end

    @units = units
    @market_price = params[:market_price].to_f
    @total_cost = @units * @market_price
  end

  # Step 3: Verify PIN - Authorize order
  def verify_order_pin
    # Handle POST requests - store order and redirect to GET
    if request.post?
      symbol = params[:symbol]
      @asset = find_asset_by_symbol(symbol)

      unless @asset
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
      if units_str.include?(".")
        decimal_places = units_str.split(".")[1]&.length || 0
        if decimal_places > 2
          redirect_to buy_crypto_path(symbol), alert: "Number of units can have maximum 2 decimal places"
          return
        end
      end

      market_price = params[:market_price].to_f

      # Store pending order in session for PIN verification
      session[:pending_order] = {
        "symbol" => symbol.upcase,
        "units" => units,
        "market_price" => market_price,
        "total_cost" => units * market_price
      }

      # Redirect to GET version to show the PIN page
      redirect_to verify_order_pin_path(symbol: symbol)
      return
    end

    # Handle GET requests - show PIN verification page
    pending_order = session[:pending_order]

    unless pending_order
      redirect_to root_path, alert: "No pending order found"
      return
    end

    @asset = find_asset_by_symbol(pending_order["symbol"])
    unless @asset
      redirect_to root_path, alert: "Asset not found"
      return
    end

    @units = pending_order["units"]
    @market_price = pending_order["market_price"]
    @total_cost = pending_order["total_cost"]
  end

  # Step 4: Create order - Store in session
  def create_order
    # Get pending order from session
    pending_order = session[:pending_order]

    unless pending_order
      redirect_to root_path, alert: "No pending order found"
      return
    end

    # Verify PIN
    pin = params[:pin]
    if pin.blank? || pin.length != 4 || !pin.match?(/\A\d{4}\z/)
      flash[:alert] = "PIN must be exactly 4 digits"
      redirect_to verify_order_pin_path(symbol: pending_order["symbol"])
      return
    end

    if pin != PinsController::CORRECT_PIN
      flash[:alert] = "Incorrect PIN. Please try again."
      redirect_to verify_order_pin_path(symbol: pending_order["symbol"])
      return
    end

    # PIN is correct, create the order
    symbol = pending_order["symbol"]
    asset = find_asset_by_symbol(symbol)

    unless asset
      redirect_to root_path, alert: "Asset not found"
      return
    end

    # Store order in session (Rails sessions store with string keys)
    order = {
      "symbol" => symbol.upcase,
      "units" => pending_order["units"],
      "price" => pending_order["market_price"],
      "timestamp" => Time.current.to_s
    }

    session[:orders] ||= []
    session[:orders] << order

    # Clear pending order
    session.delete(:pending_order)

    redirect_to root_path, notice: "Buy order placed for #{asset[:name]} (#{asset[:symbol]})"
  end

end