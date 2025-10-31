class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  before_action :check_login_status

  private

  def check_login_status
    # Skip login check for pin routes and health check
    return if controller_name == "pins" || controller_path == "rails/health"

    # Redirect to pin page if not logged in
    unless session[:is_logged_in]
      redirect_to new_pin_path
    end
  end
end
