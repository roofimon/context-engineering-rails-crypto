import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["pinInput", "pinDots", "errorMessage", "form"]

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
    this.addDigit(this.pinInputTarget, this.pinDotsTarget, digit)
    
    // Auto submit when 4 digits are entered
    if (this.pinInputTarget.value.length === 4) {
      setTimeout(() => {
        this.submitForm()
      }, 200)
    }
  }

  handleBackspace() {
    this.removeDigit(this.pinInputTarget, this.pinDotsTarget)
  }

  handleClear() {
    this.clearInput(this.pinInputTarget, this.pinDotsTarget)
  }

  addDigit(input, dots, digit) {
    if (input.value.length < 4) {
      input.value += digit
      this.updateDots(dots, input.value.length)
    }
  }

  removeDigit(input, dots) {
    if (input.value.length > 0) {
      input.value = input.value.slice(0, -1)
      this.updateDots(dots, input.value.length)
    }
  }

  clearInput(input, dots) {
    input.value = ""
    this.updateDots(dots, 0)
  }

  updateDots(dots, count) {
    const dotElements = dots.querySelectorAll(".pin-dot")
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

  submitForm() {
    const pin = this.pinInputTarget.value

    if (pin.length !== 4) {
      this.showError("Please enter complete PIN")
      return
    }

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

