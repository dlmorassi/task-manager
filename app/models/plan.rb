class Plan < ApplicationRecord
  has_many :organizations, dependent: :restrict_with_error

  validates :name, presence: true, uniqueness: true
  validates :price, numericality: { greater_than_or_equal_to: 0 }
  validates :user_limit, :project_limit, numericality: { only_integer: true, greater_than: 0 }
  validates :discount_percentage, numericality: { in: 0..100 }
end
