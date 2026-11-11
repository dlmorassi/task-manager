class RegistrationsController < ApplicationController
  def new
    redirect_to projects_path if current_user
    @organization = Organization.new
    @user = User.new
  end

  def create
    @organization = Organization.new(organization_params)
    @organization.plan = Plan.find_by!(name: "Free")
    @user = @organization.users.build(user_params)
    @user.role = :admin

    if @organization.save
      reset_session
      session[:user_id] = @user.id
      redirect_to projects_path, notice: "Your organization is ready."
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def organization_params
    params.require(:organization).permit(:name, :segment, :description)
  end

  def user_params
    params.require(:user).permit(:first_name, :last_name, :email, :username, :password, :password_confirmation)
  end
end
