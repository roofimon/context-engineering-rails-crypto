import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["units", "marketPrice", "estimatedCost", "unitsError"]

  connect() {
    console.log("Buy form controller connected")
    console.log("Buy form targets:", this.targets)
    
    // Ensure calculation runs after DOM is ready
    this.calculate()
    
    // Also listen for Turbo Frame loads
    this.element.addEventListener("turbo:frame-load", () => {
      console.log("Turbo frame loaded in buy form")
      this.calculate()
    })
  }

  preventExtraDecimals(event) {
    if (event.target !== this.unitsTarget) {
      return
    }

    const input = event.target
    const value = input.value
    const key = event.key
    const selectionStart = input.selectionStart
    const selectionEnd = input.selectionEnd
    const decimalIndex = value.indexOf('.')

    // Allow special keys: backspace, delete, tab, escape, enter, arrow keys
    const allowedKeys = ['Backspace', 'Delete', 'Tab', 'Escape', 'Enter', 'ArrowLeft', 'ArrowRight', 'ArrowUp', 'ArrowDown', 'Home', 'End']
    if (allowedKeys.includes(key)) {
      return
    }

    // Allow Ctrl+A, Ctrl+C, Ctrl+V, Ctrl+X
    if (event.ctrlKey || event.metaKey) {
      return
    }

    // If there's a decimal point and user is typing after it
    if (decimalIndex !== -1) {
      // Check if cursor is after the decimal point
      if (selectionStart > decimalIndex) {
        const decimalPart = value.substring(decimalIndex + 1, selectionEnd)
        
        // If we already have 2 decimal places and user is trying to type a digit, prevent it
        if (decimalPart.length >= 2 && /^\d$/.test(key)) {
          event.preventDefault()
          return
        }
      }

      // Prevent adding another decimal point
      if (key === '.' || key === ',') {
        event.preventDefault()
        return
      }
    }
  }

  handlePaste(event) {
    if (event.target !== this.unitsTarget) {
      return
    }

    // Get pasted data
    const pastedData = (event.clipboardData || window.clipboardData).getData('text')
    
    // If pasted data contains a decimal point, restrict to 2 decimal places
    if (pastedData.includes('.')) {
      const parts = pastedData.split('.')
      if (parts[1] && parts[1].length > 2) {
        event.preventDefault()
        const integerPart = parts[0]
        const decimalPart = parts[1].substring(0, 2)
        const restrictedValue = `${integerPart}.${decimalPart}`
        
        // Get current selection
        const input = event.target
        const start = input.selectionStart
        const end = input.selectionEnd
        const currentValue = input.value
        
        // Replace selection with restricted value
        const newValue = currentValue.substring(0, start) + restrictedValue + currentValue.substring(end)
        input.value = newValue
        
        // Set cursor position
        const newPosition = start + restrictedValue.length
        setTimeout(() => {
          input.setSelectionRange(newPosition, newPosition)
          this.validate()
          this.calculate()
        }, 0)
        
        return
      }
    }
  }

  restrictInput(event) {
    if (event.target !== this.unitsTarget) {
      return
    }

    const value = event.target.value
    
    // If there's a decimal point, check decimal places
    if (value.includes('.')) {
      const parts = value.split('.')
      if (parts[1] && parts[1].length > 2) {
        // Trim to 2 decimal places
        const integerPart = parts[0]
        const decimalPart = parts[1].substring(0, 2)
        event.target.value = `${integerPart}.${decimalPart}`
        
        // Trigger validation and calculation after restriction
        setTimeout(() => {
          this.validate()
          this.calculate()
        }, 0)
      }
    }
  }

  validate() {
    if (!this.hasUnitsTarget || !this.hasUnitsErrorTarget) {
      return
    }

    const unitsValue = this.unitsTarget.value.trim()
    
    if (!unitsValue) {
      this.clearError()
      return
    }

    const units = parseFloat(unitsValue)
    
    // Check if valid number
    if (isNaN(units)) {
      this.showError("Please enter a valid number")
      return
    }

    // Check if at least 1
    if (units < 1) {
      this.showError("Number of units must be at least 1.00")
      return
    }

    // Check decimal places (should be max 2)
    const decimalPlaces = this.getDecimalPlaces(unitsValue)
    if (decimalPlaces > 2) {
      this.showError("Number of units can have maximum 2 decimal places")
      return
    }

    this.clearError()
  }

  getDecimalPlaces(value) {
    if (!value.includes('.')) return 0
    return value.split('.')[1].length
  }

  showError(message) {
    this.unitsErrorTarget.textContent = message
    this.unitsErrorTarget.classList.remove("hidden")
    this.unitsTarget.classList.add("border-red-500")
    this.unitsTarget.classList.remove("border-gray-300")
  }

  clearError() {
    this.unitsErrorTarget.classList.add("hidden")
    this.unitsErrorTarget.textContent = ""
    this.unitsTarget.classList.remove("border-red-500")
    this.unitsTarget.classList.add("border-gray-300")
  }

  validateSubmit(event) {
    if (!this.hasUnitsTarget || !this.hasUnitsErrorTarget) {
      return
    }

    const unitsValue = this.unitsTarget.value.trim()
    
    if (!unitsValue) {
      event.preventDefault()
      this.showError("Number of units is required")
      return
    }

    const units = parseFloat(unitsValue)
    
    // Check if valid number
    if (isNaN(units)) {
      event.preventDefault()
      this.showError("Please enter a valid number")
      return
    }

    // Check if at least 1
    if (units < 1) {
      event.preventDefault()
      this.showError("Number of units must be at least 1.00")
      return
    }

    // Check decimal places (should be max 2)
    const decimalPlaces = this.getDecimalPlaces(unitsValue)
    if (decimalPlaces > 2) {
      event.preventDefault()
      this.showError("Number of units can have maximum 2 decimal places")
      return
    }
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
    
    // Only calculate if validation passes
    if (units >= 1 && price > 0 && estimatedCost > 0) {
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

