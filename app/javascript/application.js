// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"
import PinController from "controllers/pin_controller"
import { application } from "controllers/application"
application.register("pin", PinController)

