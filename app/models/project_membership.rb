class ProjectMembership < ApplicationRecord
  belongs_to :project
  belongs_to :user

  validates :user_id, uniqueness: { scope: :project_id }
  validate :user_belongs_to_project_organization

  private

  def user_belongs_to_project_organization
    return if project.blank? || user.blank? || user.organization_id == project.organization_id

    errors.add(:user, "must belong to the project's organization")
  end
end
