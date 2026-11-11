class StatusesController < ApplicationController
  before_action :authenticate_user!
  before_action :require_admin!

  def create
    project = current_organization.projects.find(params[:project_id])
    status = project.statuses.new(status_params)
    status.position = project.statuses.maximum(:position).to_i + 1

    if status.save
      redirect_to project, notice: "Status added to the board."
    else
      redirect_to project, alert: status.errors.full_messages.to_sentence
    end
  end

  def move
    project = current_organization.projects.find(params[:project_id])
    status = project.statuses.find(params[:id])
    moved = false

    if status.active? && %w[left right].include?(params[:direction])
      project.with_lock do
        statuses = project.statuses.active.order(:position, :id).to_a
        status_index = statuses.index { |item| item.id == status.id }
        target_index = status_index + (params[:direction] == "left" ? -1 : 1)

        if target_index.between?(0, statuses.length - 1)
          statuses[status_index], statuses[target_index] = statuses[target_index], statuses[status_index]
          statuses.each_with_index do |item, position|
            item.update_columns(position: position, updated_at: Time.current)
          end
          moved = true
        end
      end
    end

    if moved
      redirect_to project, notice: "Board status order updated."
    else
      redirect_to project, alert: "That status cannot be moved in that direction."
    end
  end

  private

  def status_params
    params.require(:status).permit(:name, :active)
  end
end
