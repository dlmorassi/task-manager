class ProjectsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_admin!, only: [ :new, :create ]

  def index
    @projects = visible_projects.includes(:users).order(updated_at: :desc)
  end

  def new
    @project = current_organization.projects.new
  end

  def create
    @project = current_organization.projects.new(project_params)
    created = current_organization.with_lock do
      if current_organization.project_limit_reached?
        @project.errors.add(:base, "Your plan's project limit has been reached.")
        false
      else
        Project.transaction do
          next false unless @project.save

          @project.project_memberships.create!(user: current_user)
        [ "To do", "In progress", "Done" ].each_with_index do |name, position|
          @project.statuses.create!(name: name, position: position)
        end
          true
        end
      end
    end

    if created
      redirect_to @project, notice: "Project created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @project = visible_projects.includes(statuses: { tasks: :assigned_users }).find(params[:id])
    @task = @project.tasks.new(status: @project.statuses.active.first)
    @members = @project.users.order(:first_name, :last_name)
  end

  private

  def visible_projects
    projects = current_organization.projects
    current_user.admin? ? projects : projects.joins(:project_memberships).where(project_memberships: { user_id: current_user.id })
  end

  def project_params
    params.require(:project).permit(:name, :description)
  end
end
