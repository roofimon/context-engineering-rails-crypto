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

    # Generate candlestick data for chart
    base_price = @asset[:overall_price]
    volatility = @asset[:volatility] || 0.02

    # Generate realistic 30-day candlestick data with trend
    # Use deterministic seed based on asset symbol for consistency
    Random.srand(@asset[:symbol].hash)

    # Start price 30 days ago (can be higher or lower than current)
    start_price = base_price * (0.90 + rand * 0.20)
    trend_per_day = (base_price - start_price) / 29.0

    previous_close = nil
    @asset[:candlestick_data] = 30.times.map do |i|
      # Base price with trend
      trend_price = start_price + (trend_per_day * i)

      # Open price: previous close with gap (-5% to +5%), or start price for first day
      if i == 0
        open_price = trend_price
      else
        # Gap between sessions (5% range)
        gap = (rand - 0.5) * 0.10 # -5% to +5%
        open_price = previous_close * (1.0 + gap)
      end

      # Daily price change: realistic volatility
      daily_change = (rand - 0.5) * volatility * 2
      close_price = open_price * (1.0 + daily_change)

      # High and low: realistic wicks (0.5% - 2% of body)
      body_high = [open_price, close_price].max
      body_low = [open_price, close_price].min
      body_size = body_high - body_low

      # High wick: 0.5% - 2% of body
      high_wick = body_size * (0.005 + rand * 0.015)
      high_price = body_high + high_wick

      # Low wick: 0.5% - 2% of body
      low_wick = body_size * (0.005 + rand * 0.015)
      low_price = body_low - low_wick

      # Ensure high >= max(open, close) and low <= min(open, close)
      high_price = [high_price, open_price, close_price].max
      low_price = [low_price, open_price, close_price].min

      previous_close = close_price

      [open_price.round(4), high_price.round(4), low_price.round(4), close_price.round(4)]
    end

    # Generate dates for the last 30 days
    @asset[:dates] = 30.times.map { |i| (Date.today - (29 - i)).strftime("%m/%d") }
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