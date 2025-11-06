import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="market-api"
// Example using free CoinGecko API
export default class extends Controller {
  static targets = ["price", "change", "assetName"]
  
  // Map your asset symbols to CoinGecko IDs
  static cryptoMapping = {
    'BTC': 'bitcoin',
    'ETH': 'ethereum',
    'SOL': 'solana',
    'USDT': 'tether',
    'BNB': 'binancecoin'
  }

  connect() {
    console.log("=== 📡 MARKET API CONTROLLER CONNECTED ===")
    console.log("✅ Using CoinGecko free API")
    
    // Fetch real prices immediately
    this.fetchRealPrices()
    
    // Update prices every 30 seconds (CoinGecko rate limit friendly)
    this.priceInterval = setInterval(() => {
      this.fetchRealPrices()
    }, 30000)
  }

  async fetchRealPrices() {
    console.log("🔄 Fetching real-time prices from CoinGecko...")
    
    try {
      // Get all crypto IDs we want to fetch
      const cryptoIds = Object.values(this.constructor.cryptoMapping).join(',')
      
      // CoinGecko API endpoint (free, no key required)
      const url = `https://api.coingecko.com/api/v3/simple/price?ids=${cryptoIds}&vs_currencies=usd&include_24hr_change=true`
      
      const response = await fetch(url)
      
      if (!response.ok) {
        throw new Error(`API responded with status: ${response.status}`)
      }
      
      const data = await response.json()
      console.log("✅ Real prices fetched:", data)
      
      // Update the UI with real data
      this.updatePricesFromAPI(data)
      
    } catch (error) {
      console.error("❌ Error fetching prices:", error)
      console.log("💡 Tip: Check your internet connection or API rate limits")
    }
  }

  updatePricesFromAPI(apiData) {
    // Update each asset with real data
    this.assetNameTargets.forEach((nameElement) => {
      const assetName = nameElement.textContent.trim()
      
      // Find the symbol for this asset
      const symbol = this.findSymbolByName(assetName)
      if (!symbol) return
      
      const cryptoId = this.constructor.cryptoMapping[symbol]
      const priceData = apiData[cryptoId]
      
      if (priceData) {
        // Find price elements for this asset
        const assetRow = nameElement.closest('tr, .bg-white')
        if (!assetRow) return
        
        // Update price
        const priceElements = assetRow.querySelectorAll('[data-market-api-target="price"]')
        priceElements.forEach(el => {
          const oldPrice = parseFloat(el.textContent.replace(/[$,]/g, ''))
          const newPrice = priceData.usd
          
          el.textContent = this.formatPrice(newPrice)
          
          // Flash animation
          if (!isNaN(oldPrice) && oldPrice !== newPrice) {
            this.flashElement(el, newPrice > oldPrice)
          }
        })
        
        // Update 24h change
        const changeElement = assetRow.querySelector('[data-market-api-target="change"]')
        if (changeElement && priceData.usd_24h_change) {
          const change = priceData.usd_24h_change
          changeElement.textContent = `${change >= 0 ? '+' : ''}${change.toFixed(2)}%`
          changeElement.className = `text-sm font-medium ${change >= 0 ? 'text-green-600' : 'text-red-600'}`
        }
        
        console.log(`📊 Updated ${symbol}: $${priceData.usd} (${priceData.usd_24h_change?.toFixed(2)}%)`)
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

