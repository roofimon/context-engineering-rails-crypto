import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="home"
export default class extends Controller {
  static targets = ["assetName", "price", "change"]

  connect() {
    console.log("=== 🏠 HOME CONTROLLER CONNECTED ===")
    console.log("✅ Stimulus is working on market_data/home.html.erb")
    console.log("Current page:", window.location.pathname)
    
    // Replace Bitcoin with "Hello World"
    this.replaceBitcoin()
    
    // Start real-time price updates
    this.startPriceUpdates()
  }

  replaceBitcoin() {
    this.assetNameTargets.forEach(element => {
      if (element.textContent.trim() === "Bitcoin") {
        console.log("🔄 Replacing 'Bitcoin' with 'Hello World'")
        element.textContent = "Hello World"
      }
    })
  }

  startPriceUpdates() {
    console.log("💰 Starting real-time price updates with different rhythms...")
    
    // Group price elements by asset (each asset has multiple price displays)
    this.assetGroups = this.groupPricesByAsset()
    
    // Create different update intervals for each asset
    this.intervals = []
    
    this.assetGroups.forEach((group, index) => {
      // Each asset gets a unique interval between 1.5 to 4 seconds
      const interval = 1500 + (index * 500) + Math.random() * 1000
      
      console.log(`⏱️ Asset ${index + 1} updating every ${(interval / 1000).toFixed(2)}s`)
      
      const intervalId = setInterval(() => {
        this.updateAssetGroup(group)
      }, interval)
      
      this.intervals.push(intervalId)
    })
  }

  groupPricesByAsset() {
    // Group price and change elements by their position (same asset)
    const groups = []
    const priceCount = this.priceTargets.length
    const changeCount = this.changeTargets.length
    
    // Assuming prices and changes are in order per asset
    // Each asset might have multiple price elements (main + exchanges)
    const pricesPerChange = Math.floor(priceCount / changeCount)
    
    for (let i = 0; i < changeCount; i++) {
      const startIdx = i * pricesPerChange
      const endIdx = (i === changeCount - 1) ? priceCount : (i + 1) * pricesPerChange
      
      groups.push({
        prices: this.priceTargets.slice(startIdx, endIdx),
        change: this.changeTargets[i],
        volatility: 0.3 + Math.random() * 0.7 // Random volatility between 0.3 and 1.0
      })
    }
    
    return groups
  }

  updateAssetGroup(group) {
    // Update all prices in this asset group
    group.prices.forEach(priceElement => {
      const currentPrice = parseFloat(priceElement.textContent.replace(/[$,]/g, ''))
      
      if (!isNaN(currentPrice)) {
        // Random change based on asset's volatility
        const changePercent = (Math.random() - 0.5) * 0.01 * group.volatility
        const newPrice = currentPrice * (1 + changePercent)
        
        // Format price
        const formattedPrice = this.formatPrice(newPrice)
        priceElement.textContent = formattedPrice
        
        // Flash animation
        this.flashElement(priceElement, changePercent > 0)
      }
    })
    
    // Update the change percentage for this asset
    const changeElement = group.change
    const currentChange = parseFloat(changeElement.textContent.replace(/[+%]/g, ''))
    
    if (!isNaN(currentChange)) {
      // Accumulate small changes based on volatility
      const changeAmount = (Math.random() - 0.5) * 0.1 * group.volatility
      const newChange = currentChange + changeAmount
      
      // Update text and color
      changeElement.textContent = `${newChange >= 0 ? '+' : ''}${newChange.toFixed(2)}%`
      changeElement.className = `text-sm font-medium ${newChange >= 0 ? 'text-green-600' : 'text-red-600'}`
    }
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
    }, 500)
  }

  disconnect() {
    console.log("👋 HOME CONTROLLER DISCONNECTED")
    
    // Stop all price update intervals
    if (this.intervals) {
      this.intervals.forEach(interval => clearInterval(interval))
      console.log(`🛑 Stopped ${this.intervals.length} update intervals`)
    }
  }
}

