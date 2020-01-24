class Comment < ApplicationRecord
  belongs_to :user
  belongs_to :post
  has_many :children, class_name: 'Comment', foreign_key: :parent_id
  belongs_to :parent, class_name: 'Comment', optional: true
  validates :user, :post, :text, presence: true
  validates :parent, presence: true, unless: proc { |c| c.parent_id.blank? }
  default_scope -> { includes(:user) }
  scope :recent, -> { order(created_at: :desc) }
end
