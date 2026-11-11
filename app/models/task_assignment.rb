class TaskAssignment < ApplicationRecord
  belongs_to :task
  belongs_to :user

  validates :user_id, uniqueness: { scope: :task_id }
  validate :user_belongs_to_task_organization

  private

  def user_belongs_to_task_organization
    return if task.blank? || user.blank? || user.organization_id == task.organization_id

    errors.add(:user, "must belong to the task's organization")
  end
end
