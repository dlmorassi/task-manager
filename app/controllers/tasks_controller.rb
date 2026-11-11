class TasksController < ApplicationController
  before_action :authenticate_user!
  before_action :set_project
  before_action :set_task, only: [ :show, :update ]

  def create
    @task = @project.tasks.new(task_params.except(:assigned_user_ids, :attachments))
    @task.organization = current_organization
    @task.status ||= @project.statuses.active.order(:position).first
    set_assignees

    unless valid_attachment_uploads?
      return redirect_to project_path(@project), alert: @task.errors.full_messages.to_sentence
    end

    if @task.save
      attach_files
      redirect_to project_path(@project), notice: "Task created."
    else
      redirect_to project_path(@project), alert: @task.errors.full_messages.to_sentence
    end
  end

  def show
    @comment = @task.comments.new
    @comments = @task.comments.includes(:user).order(:created_at)
    @members = @project.users.order(:first_name, :last_name)
  end

  def update
    @task.assign_attributes(task_params.except(:assigned_user_ids, :attachments))
    set_assignees

    unless valid_attachment_uploads?
      @comment = @task.comments.new
      @comments = @task.comments.includes(:user).order(:created_at)
      @members = @project.users.order(:first_name, :last_name)
      return render :show, status: :unprocessable_entity
    end

    if @task.save
      attach_files
      redirect_to project_task_path(@project, @task), notice: "Task updated."
    else
      @comment = @task.comments.new
      @comments = @task.comments.includes(:user).order(:created_at)
      @members = @project.users.order(:first_name, :last_name)
      render :show, status: :unprocessable_entity
    end
  end

  private

  def set_project
    projects = current_organization.projects
    projects = projects.joins(:project_memberships).where(project_memberships: { user_id: current_user.id }) unless current_user.admin?
    @project = projects.find(params[:project_id])
  end

  def set_task
    @task = @project.tasks.includes(:status, :assigned_users, attachments_attachments: :blob).find(params[:id])
  end

  def task_params
    params.require(:task).permit(:title, :description, :story_points, :due_date, :status_id, assigned_user_ids: [], attachments: [])
  end

  def set_assignees
    ids = Array(task_params[:assigned_user_ids]).reject(&:blank?)
    @task.assigned_users = @project.users.where(id: ids)
  end

  def attach_files
    files = Array(task_params[:attachments]).reject(&:blank?)
    @task.attachments.attach(files) if files.any?
  end

  def valid_attachment_uploads?
    files = Array(task_params[:attachments]).reject(&:blank?)
    return true if files.empty?

    invalid_file = files.any? do |file|
      file.size > 25.megabytes || !%w[application/pdf image/jpeg image/png image/webp text/plain].include?(file.content_type)
    end
    @task.errors.add(:attachments, "must be PDFs, images, or plain text files smaller than 25 MB") if invalid_file
    !invalid_file
  end
end
