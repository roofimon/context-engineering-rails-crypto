import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["currentPinInput", "newPinInput", "newPinConfirmationInput", "pinDots", "errorMessage", "form", "header", "subheader"]

  connect() {
    console.log("Reset PIN controller connected")
    this.currentStep = 1 // 1: current, 2: new, 3: confirm
    this.currentPin = ""
    this.newPin = ""
    this.newPinConfirmation = ""
    this.updateUI()
  }

  handleKeyPress(event) {
    const key = event.target.dataset.key
    
    if (key === "backspace") {
      this.handleBackspace()
    } else if (key === "clear") {
      this.handleClear()
    } else if (/^\d$/.test(key)) {
      this.handleDigit(key)
    }
  }

  handleDigit(digit) {
    const currentValue = this.getCurrentValue()
    
    if (currentValue.length < 4) {
      this.setCurrentValue(currentValue + digit)
      this.updateDots(currentValue.length + 1)
      
      // Auto advance when 4 digits are entered
      if (currentValue.length + 1 === 4) {
        setTimeout(() => {
          this.advanceStep()
        }, 200)
      }
    }
  }

  handleBackspace() {
    const currentValue = this.getCurrentValue()
    if (currentValue.length > 0) {
      this.setCurrentValue(currentValue.slice(0, -1))
      this.updateDots(currentValue.length - 1)
    }
  }

  handleClear() {
    this.setCurrentValue("")
    this.updateDots(0)
  }

  getCurrentValue() {
    if (this.currentStep === 1) return this.currentPin
    if (this.currentStep === 2) return this.newPin
    if (this.currentStep === 3) return this.newPinConfirmation
  }

  setCurrentValue(value) {
    if (this.currentStep === 1) this.currentPin = value
    if (this.currentStep === 2) this.newPin = value
    if (this.currentStep === 3) this.newPinConfirmation = value
  }

  updateDots(count) {
    const dotElements = this.pinDotsTarget.querySelectorAll(".pin-dot")
    dotElements.forEach((dot, index) => {
      if (index < count) {
        dot.classList.add("bg-gray-900")
        dot.classList.remove("bg-gray-200")
      } else {
        dot.classList.remove("bg-gray-900")
        dot.classList.add("bg-gray-200")
      }
    })
  }

  updateUI() {
    // Update header and subheader text
    if (this.currentStep === 1) {
      this.headerTarget.textContent = "Enter Current PIN"
      this.subheaderTarget.textContent = "Enter your current 4-digit PIN"
    } else if (this.currentStep === 2) {
      this.headerTarget.textContent = "Enter New PIN"
      this.subheaderTarget.textContent = "Enter your new 4-digit PIN"
    } else if (this.currentStep === 3) {
      this.headerTarget.textContent = "Confirm New PIN"
      this.subheaderTarget.textContent = "Re-enter your new 4-digit PIN"
    }
    
    // Reset dots
    this.updateDots(0)
  }

  advanceStep() {
    if (this.currentStep === 1) {
      if (this.currentPin.length !== 4) {
        this.showError("Please enter complete PIN")
        return
      }
      this.currentStep = 2
      this.updateUI()
    } else if (this.currentStep === 2) {
      if (this.newPin.length !== 4) {
        this.showError("Please enter complete PIN")
        return
      }
      this.currentStep = 3
      this.updateUI()
    } else if (this.currentStep === 3) {
      if (this.newPinConfirmation.length !== 4) {
        this.showError("Please enter complete PIN")
        return
      }
      this.submitForm()
    }
  }

  submitForm() {
    // Set hidden input values
    this.currentPinInputTarget.value = this.currentPin
    this.newPinInputTarget.value = this.newPin
    this.newPinConfirmationInputTarget.value = this.newPinConfirmation

    // Submit the form
    this.formTarget.submit()
  }

  showError(message) {
    if (this.hasErrorMessageTarget) {
      const errorDiv = this.errorMessageTarget.querySelector("p")
      if (errorDiv) {
        errorDiv.textContent = message
      }
      this.errorMessageTarget.classList.remove("hidden")
      setTimeout(() => {
        this.errorMessageTarget.classList.add("hidden")
      }, 3000)
    }
  }
}

