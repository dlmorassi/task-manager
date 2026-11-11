class SessionsController < ApplicationController
  rate_limit to: 10, within: 3.minutes, only: :create

  def new
    redirect_to projects_path if current_user
  end

  def create
    identifier = params[:identifier].to_s.strip
    user = User.find_by(email: identifier.downcase)
    user ||= User.find_by(username: identifier)
    user ||= User.where("LOWER(username) = ?", identifier.downcase).first if identifier.present?

    if user&.authenticate(params[:password])
      reset_session
      session[:user_id] = user.id
      redirect_to projects_path, notice: "Welcome back, #{user.first_name}."
    else
      flash.now[:alert] = "Email or password is incorrect."
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    reset_session
    redirect_to login_path, notice: "You have been logged out."
  end
end
