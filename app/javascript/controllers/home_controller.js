import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="home"
export default class extends Controller {
  connect() {
    console.log("🏠 HOME CONTROLLER CONNECTED")
    console.log("✅ Stimulus is working on market_data/home.html.erb")
    console.log("Current page:", window.location.pathname)
  }

  disconnect() {
    console.log("👋 HOME CONTROLLER DISCONNECTED")
  }
}

