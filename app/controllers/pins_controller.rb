class PinsController < ApplicationController
  skip_before_action :check_login_status, only: [:new, :create]

  CORRECT_PIN = "1111"

  def new
    # Redirect to home if already logged in
    if session[:is_logged_in]
      redirect_to root_path
      return
    end
  end

  def create
    pin = params[:pin]

    # Validation
    if pin.blank? || pin.length != 4 || !pin.match?(/\A\d{4}\z/)
      flash.now[:alert] = "PIN must be exactly 4 digits"
      render :new, status: :unprocessable_entity
      return
    end

    # Validate PIN against correct PIN
    if pin != CORRECT_PIN
      flash.now[:alert] = "Incorrect PIN. Please try again."
      render :new, status: :unprocessable_entity
      return
    end

    # Set session when PIN is correct
    session[:is_logged_in] = true

    redirect_to root_path, notice: "PIN verified successfully"
  end

  def destroy
    # Reset entire session (clears all session data including :is_logged_in and :orders)
    reset_session
    
    redirect_to new_pin_path, notice: "Logged out successfully"
  end

  private
end

