import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="market-api"
// Example using free CoinGecko API
export default class extends Controller {
  static targets = ["price", "change", "assetName", "exchangePrice", "exchangeIndicator"]
  
  // Map your asset symbols to CoinGecko IDs
  static cryptoMapping = {
    'BTC': 'bitcoin',
    'ETH': 'ethereum',
    'SOL': 'solana',
    'USDT': 'tether',
    'BNB': 'binancecoin'
  }
  
  // Reverse mapping for looking up by CoinGecko ID
  static reverseMapping = {
    'bitcoin': 'BTC',
    'ethereum': 'ETH',
    'solana': 'SOL',
    'tether': 'USDT',
    'binancecoin': 'BNB'
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
      
      // Print raw API data to console
      console.log("=".repeat(60))
      console.log("📡 RAW API DATA FROM COINGECKO:")
      console.log("=".repeat(60))
      console.log(JSON.stringify(data, null, 2))
      console.log("=".repeat(60))
      
      // Print formatted price data
      console.log("\n💰 FORMATTED PRICE DATA:")
      console.log("-".repeat(60))
      Object.keys(data).forEach(coinGeckoId => {
        const symbol = this.constructor.reverseMapping[coinGeckoId] || coinGeckoId.toUpperCase()
        const priceData = data[coinGeckoId]
        console.log(`${symbol} (${coinGeckoId}):`)
        console.log(`  Price: $${this.formatPrice(priceData.usd)}`)
        console.log(`  24h Change: ${priceData.usd_24h_change >= 0 ? '+' : ''}${priceData.usd_24h_change?.toFixed(2)}%`)
        console.log("")
      })
      console.log("-".repeat(60))
      
      // Update the UI with real data
      this.updatePricesFromAPI(data)
      
    } catch (error) {
      console.error("❌ Error fetching prices:", error)
      console.log("💡 Tip: Check your internet connection or API rate limits")
    }
  }

  updatePricesFromAPI(apiData) {
    console.log("\n🔄 PROCESSING API DATA FOR UI UPDATE:")
    console.log("-".repeat(60))
    
    // Iterate through CoinGecko data
    Object.keys(apiData).forEach(coinGeckoId => {
      const priceData = apiData[coinGeckoId]
      const symbol = this.constructor.reverseMapping[coinGeckoId]
      
      if (!symbol || !priceData) return
      
      const price = priceData.usd
      const change24h = priceData.usd_24h_change
      
      console.log(`📊 Processing ${symbol} (${coinGeckoId}):`)
      console.log(`   USD Price: $${this.formatPrice(price)}`)
      console.log(`   24h Change: ${change24h >= 0 ? '+' : ''}${change24h?.toFixed(2)}%`)
      
      // Update main price displays (works for both table and mobile card)
      this.priceTargets.forEach(priceElement => {
        // Look for both tr (desktop table) and div (mobile card) elements with data-crypto
        const assetRow = priceElement.closest('[data-crypto], tr, div[data-crypto]')
        if (!assetRow) return
        
        // Check if this price element is for the current crypto
        const assetName = assetRow.querySelector('[data-market-api-target="assetName"]')?.textContent.trim()
        const matchSymbol = this.findSymbolByName(assetName)
        
        if (matchSymbol === symbol) {
          const oldPrice = parseFloat(priceElement.textContent.replace(/[$,]/g, ''))
          priceElement.textContent = this.formatPrice(price)
          
          if (!isNaN(oldPrice) && oldPrice !== price) {
            this.flashElement(priceElement, price > oldPrice)
          }
        }
      })
      
      // Update exchange-specific prices (Binance & Coinbase columns)
      // Works for both table (td) and mobile card (div) elements
      this.exchangePriceTargets.forEach(exchangePriceElement => {
        // Look for both td (desktop table) and div (mobile card) elements
        const container = exchangePriceElement.closest('td, div[data-exchange]')
        if (!container) return
        
        const cryptoSymbol = container.getAttribute('data-crypto')
        const exchangeName = container.getAttribute('data-exchange')
        
        if (cryptoSymbol === symbol && exchangeName) {
          const oldPrice = parseFloat(exchangePriceElement.textContent.replace(/[$,]/g, ''))
          const newPrice = price
          
          // Add small variation between exchanges (simulate slight differences)
          const variation = (Math.random() - 0.5) * 0.002 // ±0.2%
          const adjustedPrice = newPrice * (1 + variation)
          
          exchangePriceElement.textContent = this.formatPrice(adjustedPrice)
          
          // Update indicator (works for both td and div containers)
          const indicator = container.querySelector('[data-market-api-target="exchangeIndicator"]')
          if (indicator && !isNaN(oldPrice)) {
            const isUp = adjustedPrice > oldPrice
            indicator.className = `w-2 h-2 rounded-full ${isUp ? 'bg-green-500' : 'bg-red-500'}`
          }
          
          if (!isNaN(oldPrice) && oldPrice !== adjustedPrice) {
            this.flashElement(exchangePriceElement, adjustedPrice > oldPrice)
          }
          
          console.log(`💱 Updated ${exchangeName} ${symbol}: $${this.formatPrice(adjustedPrice)}`)
        }
      })
      
      // Update 24h change (works for both table and mobile card)
      this.changeTargets.forEach(changeElement => {
        // Look for both tr (desktop table) and div (mobile card) elements with data-crypto
        const assetRow = changeElement.closest('[data-crypto], tr, div[data-crypto]')
        if (!assetRow) return
        
        const assetName = assetRow.querySelector('[data-market-api-target="assetName"]')?.textContent.trim()
        const matchSymbol = this.findSymbolByName(assetName)

        if (matchSymbol === symbol && change24h) {
          changeElement.textContent = `${change24h >= 0 ? '+' : ''}${change24h.toFixed(2)}%`
          changeElement.className = `text-sm font-medium ${change24h >= 0 ? 'text-green-600' : 'text-red-600'}`
        }
      })
      
      console.log(`   ✅ UI Updated for ${symbol}`)
      console.log("")
    })
    
    console.log("-".repeat(60))
    console.log("✅ All prices updated in UI\n")
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

