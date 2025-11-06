import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="home"
export default class extends Controller {
  static targets = ["assetName"]

  connect() {
    console.log("🏠 HOME CONTROLLER CONNECTED")
    console.log("✅ Stimulus is working on market_data/home.html.erb")
    console.log("Current page:", window.location.pathname)
    
    // Replace Bitcoin with "Hello World"
    this.replaceBitcoin()
  }

  replaceBitcoin() {
    this.assetNameTargets.forEach(element => {
      if (element.textContent.trim() === "Bitcoin") {
        console.log("🔄 Replacing 'Bitcoin' with 'Hello World'")
        element.textContent = "Hello World"
      }
    })
  }

  disconnect() {
    console.log("👋 HOME CONTROLLER DISCONNECTED")
  }
}

