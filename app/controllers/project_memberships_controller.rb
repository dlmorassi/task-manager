class ProjectMembershipsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_admin!

  def create
    project = current_organization.projects.find(params[:project_id])
    user = current_organization.users.find(params[:user_id])
    project.project_memberships.create!(user: user)
    redirect_to project, notice: "Member added to the project."
  rescue ActiveRecord::RecordNotUnique, ActiveRecord::RecordInvalid
    redirect_to project, alert: "That member is already on this project."
  end

  def destroy
    project = current_organization.projects.find(params[:project_id])
    project.project_memberships.find_by!(user_id: params[:id]).destroy!
    redirect_to project, notice: "Member removed from the project."
  end
end
