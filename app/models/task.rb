class Task < ApplicationRecord
  belongs_to :organization
  belongs_to :project
  belongs_to :status
  has_many :task_assignments, dependent: :destroy
  has_many :assigned_users, through: :task_assignments, source: :user
  has_many :comments, dependent: :destroy
  has_many_attached :attachments

  validates :title, presence: true
  validates :story_points, numericality: { greater_than_or_equal_to: 0.1, less_than_or_equal_to: 999_999.9 }, allow_nil: true
  validate :attachments_are_safe
  validate :status_belongs_to_project
  validate :project_belongs_to_organization

  private

  def status_belongs_to_project
    return if status.blank? || project.blank? || status.project_id == project_id

    errors.add(:status, "must belong to the task's project")
  end

  def project_belongs_to_organization
    return if project.blank? || organization_id == project.organization_id

    errors.add(:project, "must belong to the task's organization")
  end

  def attachments_are_safe
    attachments.each do |attachment|
      if attachment.byte_size > 25.megabytes
        errors.add(:attachments, "must be smaller than 25 MB")
      end

      unless %w[application/pdf image/jpeg image/png image/webp text/plain].include?(attachment.content_type)
        errors.add(:attachments, "must be a PDF, image, or plain text file")
      end
    end
  end
end
