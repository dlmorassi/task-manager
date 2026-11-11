class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  helper_method :current_user

  private

  def current_user
    @current_user ||= User.includes(:organization).find_by(id: session[:user_id])
  end

  def authenticate_user!
    return if current_user

    redirect_to login_path, alert: "Please log in to continue."
  end

  def current_organization
    current_user.organization
  end

  def require_admin!
    return if current_user&.admin?

    redirect_to projects_path, alert: "Administrator access is required."
  end
end
