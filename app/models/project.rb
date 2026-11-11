class Project < ApplicationRecord
  belongs_to :organization
  has_many :project_memberships, dependent: :destroy
  has_many :users, through: :project_memberships
  has_many :statuses, -> { order(:position) }, dependent: :destroy
  has_many :tasks, dependent: :destroy

  validates :name, presence: true
  validate :organization_has_project_capacity, on: :create

  private

  def organization_has_project_capacity
    return if organization.blank? || !organization.project_limit_reached?

    errors.add(:base, "Organization has reached its project limit")
  end
end
