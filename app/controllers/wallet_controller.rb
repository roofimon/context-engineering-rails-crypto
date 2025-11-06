class WalletController < ApplicationController
  include AssetHelper

  # ============================================================================
  # WALLET (User Holdings/Portfolio)
  # 
  # This controller handles cryptocurrency wallet/holdings views:
  # - index: Display user's crypto holdings with real-time price updates
  # ============================================================================
  
  # Index - Display wallet holdings
  def index
    @assets = index_assets
  end

end

