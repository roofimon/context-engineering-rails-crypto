import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["units", "marketPrice", "estimatedCost"]

  connect() {
    // Ensure calculation runs after DOM is ready
    this.calculate()
    
    // Also listen for Turbo Frame loads
    this.element.addEventListener("turbo:frame-load", () => {
      this.calculate()
    })
  }

  calculate() {
    if (!this.hasUnitsTarget || !this.hasMarketPriceTarget || !this.hasEstimatedCostTarget) {
      return
    }

    const unitsValue = this.unitsTarget.value
    const priceValue = this.marketPriceTarget.value
    
    const units = parseFloat(unitsValue) || 0
    const price = parseFloat(priceValue) || 0
    const estimatedCost = units * price
    
    if (units > 0 && price > 0 && estimatedCost > 0) {
      this.estimatedCostTarget.value = estimatedCost.toFixed(2)
      this.estimatedCostTarget.classList.remove("text-gray-400")
      this.estimatedCostTarget.classList.add("text-gray-900")
    } else {
      this.estimatedCostTarget.value = ""
      this.estimatedCostTarget.classList.remove("text-gray-900")
      this.estimatedCostTarget.classList.add("text-gray-400")
    }
  }
}

