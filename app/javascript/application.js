// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"
import PinController from "controllers/pin_controller"
import { application } from "controllers/application"
import ApexCharts from "apexcharts"

// Make ApexCharts available globally
// The ESM CDN module exports the constructor directly as default
// So ApexCharts itself IS the constructor function
console.log('ApexCharts import type:', typeof ApexCharts)
console.log('ApexCharts is function:', typeof ApexCharts === 'function')

// If ApexCharts is a function, use it directly
// If it's an object, try to get the constructor from it
if (typeof ApexCharts === 'function') {
  // Perfect! It's the constructor directly
  window.ApexCharts = ApexCharts
  console.log('✅ ApexCharts assigned directly (it is a function)')
} else if (typeof ApexCharts === 'object') {
  // It's an object, try to find the constructor
  console.log('ApexCharts is an object, checking properties...')
  console.log('ApexCharts.default:', ApexCharts?.default)
  console.log('ApexCharts.ApexCharts:', ApexCharts?.ApexCharts)
  console.log('ApexCharts keys:', Object.keys(ApexCharts || {}))
  
  window.ApexCharts = ApexCharts.default || ApexCharts.ApexCharts || ApexCharts
  console.log('✅ ApexCharts assigned from object')
} else {
  console.error('❌ ApexCharts is neither a function nor an object:', typeof ApexCharts)
}

console.log('Final window.ApexCharts type:', typeof window.ApexCharts)
console.log('window.ApexCharts is function:', typeof window.ApexCharts === 'function')

console.log("JavaScript application initialized")
console.log("Turbo Rails loaded")
console.log("Stimulus controllers loading...")

application.register("pin", PinController)

console.log("All JavaScript components connected successfully!")

