import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="market-api"
// Using free Binance Public API
export default class extends Controller {
  static targets = ["price", "change", "assetName"]
  
  // Map your asset symbols to Binance trading pairs
  static cryptoMapping = {
    'BTC': 'BTCUSDT',
    'ETH': 'ETHUSDT',
    'SOL': 'SOLUSDT',
    'USDT': 'USDTUSD',
    'BNB': 'BNBUSDT'
  }

  connect() {
    console.log("=== 📡 MARKET API CONTROLLER CONNECTED ===")
    console.log("✅ Using Binance Public API (Free, No Key Required)")
    
    // Fetch real prices immediately
    this.fetchRealPrices()
    
    // Update prices every 3 seconds (Binance has no strict limits for public data)
    this.priceInterval = setInterval(() => {
      this.fetchRealPrices()
    }, 3000)
  }

  async fetchRealPrices() {
    console.log("🔄 Fetching real-time prices from Binance...")
    
    try {
      // Get all trading pairs
      const symbols = Object.values(this.constructor.cryptoMapping)
      
      // Binance API endpoint (free, no key required)
      // Fetch all tickers at once for better performance
      const url = `https://api.binance.com/api/v3/ticker/24hr?symbols=${JSON.stringify(symbols)}`
      
      const response = await fetch(url)
      
      if (!response.ok) {
        throw new Error(`Binance API responded with status: ${response.status}`)
      }
      
      const data = await response.json()
      console.log("✅ Real prices fetched from Binance:", data.length, "assets")
      
      // Convert array to object for easier lookup
      const priceData = {}
      data.forEach(item => {
        priceData[item.symbol] = item
      })
      
      // Update the UI with real data
      this.updatePricesFromAPI(priceData)
      
    } catch (error) {
      console.error("❌ Error fetching prices from Binance:", error)
      console.log("💡 Tip: Check your internet connection")
    }
  }

  updatePricesFromAPI(apiData) {
    // Update each asset with real data
    this.assetNameTargets.forEach((nameElement) => {
      const assetName = nameElement.textContent.trim()
      
      // Find the symbol for this asset
      const symbol = this.findSymbolByName(assetName)
      if (!symbol) return
      
      const tradingPair = this.constructor.cryptoMapping[symbol]
      const priceData = apiData[tradingPair]
      
      if (priceData) {
        // Find price elements for this asset
        const assetRow = nameElement.closest('tr, .bg-white')
        if (!assetRow) return
        
        // Update price
        const priceElements = assetRow.querySelectorAll('[data-market-api-target="price"]')
        priceElements.forEach(el => {
          const oldPrice = parseFloat(el.textContent.replace(/[$,]/g, ''))
          const newPrice = parseFloat(priceData.lastPrice)
          
          el.textContent = this.formatPrice(newPrice)
          
          // Flash animation
          if (!isNaN(oldPrice) && oldPrice !== newPrice) {
            this.flashElement(el, newPrice > oldPrice)
          }
        })
        
        // Update 24h change
        const changeElement = assetRow.querySelector('[data-market-api-target="change"]')
        if (changeElement && priceData.priceChangePercent) {
          const change = parseFloat(priceData.priceChangePercent)
          changeElement.textContent = `${change >= 0 ? '+' : ''}${change.toFixed(2)}%`
          changeElement.className = `text-sm font-medium ${change >= 0 ? 'text-green-600' : 'text-red-600'}`
        }
        
        console.log(`📊 Updated ${symbol}: $${priceData.lastPrice} (${priceData.priceChangePercent}%)`)
      }
    })
  }

  findSymbolByName(name) {
    // Map display names back to symbols
    const nameMap = {
      'Bitcoin': 'BTC',
      'Hello World': 'BTC', // Your custom name
      'Ethereum': 'ETH',
      'Solana': 'SOL',
      'Tether': 'USDT',
      'Binance Coin': 'BNB'
    }
    return nameMap[name]
  }

  formatPrice(price) {
    if (price >= 1000) {
      return price.toFixed(2).replace(/\B(?=(\d{3})+(?!\d))/g, ",")
    } else if (price >= 1) {
      return price.toFixed(2)
    } else {
      return price.toFixed(4)
    }
  }

  flashElement(element, isIncrease) {
    const color = isIncrease ? 'bg-green-100' : 'bg-red-100'
    element.classList.add(color)
    
    setTimeout(() => {
      element.classList.remove(color)
    }, 800)
  }

  disconnect() {
    console.log("👋 MARKET API CONTROLLER DISCONNECTED")
    
    // Stop fetching
    if (this.priceInterval) {
      clearInterval(this.priceInterval)
    }
  }
}

