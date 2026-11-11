class User < ApplicationRecord
  has_secure_password

  belongs_to :organization
  has_many :project_memberships, dependent: :destroy
  has_many :projects, through: :project_memberships
  has_many :task_assignments, dependent: :destroy
  has_many :assigned_tasks, through: :task_assignments, source: :task
  has_many :comments, dependent: :restrict_with_error

  enum :role, { standard: "standard", admin: "admin" }

  normalizes :email, with: ->(email) { email.strip.downcase }
  normalizes :username, with: ->(username) { username&.strip&.presence }

  validates :first_name, :last_name, presence: true
  validates :email, presence: true, uniqueness: { case_sensitive: false }, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :username, uniqueness: { case_sensitive: false }, allow_nil: true
  validate :organization_has_user_capacity, on: :create

  private

  def organization_has_user_capacity
    return if organization.blank? || !organization.user_limit_reached?

    errors.add(:base, "Organization has reached its user limit")
  end
end
