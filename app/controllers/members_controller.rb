class MembersController < ApplicationController
  before_action :authenticate_user!
  before_action :require_admin!

  def index
    @members = current_organization.users.order(:first_name, :last_name)
    @user = current_organization.users.new
  end

  def create
    @user = current_organization.users.new(user_params)
    @user.role = :standard

    created = current_organization.with_lock { @user.save }

    if created
      redirect_to members_path, notice: "Member added to your organization."
    else
      @members = current_organization.users.order(:first_name, :last_name)
      render :index, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(:first_name, :last_name, :email, :username, :password, :password_confirmation)
  end
end
