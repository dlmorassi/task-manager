class Status < ApplicationRecord
  scope :active, -> { where(active: true) }

  belongs_to :project
  has_many :tasks, dependent: :restrict_with_error

  validates :name, presence: true, uniqueness: { scope: :project_id }
  validates :position, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, uniqueness: { scope: :project_id }
end
