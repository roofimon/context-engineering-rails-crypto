class CryptosController < ApplicationController
  include AssetHelper

  # ============================================================================
  # BUY FLOW (crypto selection)
  # ============================================================================

  # Buy form - Enter units
  def buy
    symbol = params[:symbol]
    @asset = find_asset_by_symbol(symbol)

    unless @asset
      redirect_to root_path, alert: "Asset not found"
      return
    end

    # Generate candlestick data for chart
    @asset = generate_candlestick_data(@asset, days: 30)
  end

end