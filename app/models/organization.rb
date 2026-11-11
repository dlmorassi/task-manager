class Organization < ApplicationRecord
  belongs_to :plan
  has_many :users, dependent: :restrict_with_error
  has_many :projects, dependent: :destroy
  has_many :tasks, dependent: :destroy

  validates :name, presence: true

  def project_limit_reached?
    projects.count >= plan.project_limit
  end

  def user_limit_reached?
    users.count >= plan.user_limit
  end
end
