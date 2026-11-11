class CommentsController < ApplicationController
  before_action :authenticate_user!

  def create
    projects = current_organization.projects
    projects = projects.joins(:project_memberships).where(project_memberships: { user_id: current_user.id }) unless current_user.admin?
    project = projects.find(params[:project_id])
    task = project.tasks.find(params[:task_id])
    comment = task.comments.new(comment_params)
    comment.user = current_user

    if comment.save
      redirect_to project_task_path(project, task), notice: "Comment added."
    else
      redirect_to project_task_path(project, task), alert: comment.errors.full_messages.to_sentence
    end
  end

  private

  def comment_params
    params.require(:comment).permit(:body)
  end
end
