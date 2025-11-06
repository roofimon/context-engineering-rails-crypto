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

    # Validate PIN against current configured PIN
    if pin != current_pin_value
      flash.now[:alert] = "Incorrect PIN. Please try again."
      render :new, status: :unprocessable_entity
      return
    end

    # Set session when PIN is correct
    session[:is_logged_in] = true

    redirect_to root_path, notice: "PIN verified successfully"
  end

  # Show reset PIN form
  def edit
  end

  # Update PIN after verifying current PIN and confirmation
  def update
    current_pin = params[:current_pin]
    new_pin = params[:new_pin]
    new_pin_confirmation = params[:new_pin_confirmation]

    # Validate current PIN
    if current_pin != current_pin_value
      flash.now[:alert] = "Current PIN is incorrect"
      render :edit, status: :unprocessable_entity
      return
    end

    # Validate new PIN format
    unless new_pin.present? && new_pin.match?(/\A\d{4}\z/)
      flash.now[:alert] = "New PIN must be exactly 4 digits"
      render :edit, status: :unprocessable_entity
      return
    end

    # Validate confirmation
    if new_pin != new_pin_confirmation
      flash.now[:alert] = "New PIN and confirmation do not match"
      render :edit, status: :unprocessable_entity
      return
    end

    # Save new PIN in session and globally (demo persistence via cache)
    session[:pin] = new_pin
    set_global_pin_value(new_pin)

    redirect_to more_path, notice: "PIN updated successfully"
  end

  def destroy
    # Reset entire session (clears all session data including :is_logged_in and :orders)
    reset_session
    
    redirect_to new_pin_path, notice: "Logged out successfully"
  end

  private
  def current_pin_value
    session[:pin].presence || global_pin_value
  end

  def global_pin_value
    Rails.cache.fetch("global_pin") { CORRECT_PIN }
  end

  def set_global_pin_value(new_pin)
    Rails.cache.write("global_pin", new_pin)
  end
end

