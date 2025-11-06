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
    console.log("💰 Starting real-time price updates...")
    
    // Update prices every 2 seconds
    this.priceInterval = setInterval(() => {
      this.updatePrices()
    }, 2000)
  }

  updatePrices() {
    console.log("🔄 Updating prices...")
    
    // Update all price elements
    this.priceTargets.forEach(priceElement => {
      const currentPrice = parseFloat(priceElement.textContent.replace(/[$,]/g, ''))
      
      if (!isNaN(currentPrice)) {
        // Random change between -0.5% and +0.5%
        const changePercent = (Math.random() - 0.5) * 0.01
        const newPrice = currentPrice * (1 + changePercent)
        
        // Format price
        const formattedPrice = this.formatPrice(newPrice)
        priceElement.textContent = formattedPrice
        
        // Flash animation
        this.flashElement(priceElement, changePercent > 0)
      }
    })
    
    // Update change percentages
    this.changeTargets.forEach(changeElement => {
      const currentChange = parseFloat(changeElement.textContent.replace(/[+%]/g, ''))
      
      if (!isNaN(currentChange)) {
        // Accumulate small changes
        const changeAmount = (Math.random() - 0.5) * 0.1
        const newChange = currentChange + changeAmount
        
        // Update text and color
        changeElement.textContent = `${newChange >= 0 ? '+' : ''}${newChange.toFixed(2)}%`
        changeElement.className = `text-sm font-medium ${newChange >= 0 ? 'text-green-600' : 'text-red-600'}`
      }
    })
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
    
    // Stop price updates
    if (this.priceInterval) {
      clearInterval(this.priceInterval)
    }
  }
}

