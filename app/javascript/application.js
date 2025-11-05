// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"
import PinController from "controllers/pin_controller"
import { application } from "controllers/application"
import ApexCharts from "apexcharts"

// Make ApexCharts available globally
window.ApexCharts = ApexCharts

console.log("JavaScript application initialized")
console.log("Turbo Rails loaded")
console.log("Stimulus controllers loading...")

application.register("pin", PinController)

console.log("All JavaScript components connected successfully!")

