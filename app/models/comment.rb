class Comment < ApplicationRecord
  belongs_to :user
  belongs_to :post
  has_many :children, class_name: 'Comment', foreign_key: :parent_id
  belongs_to :parent, class_name: 'Comment', optional: true
  validates :user, :post, :text, presence: true
  validates :parent, presence: true, unless: proc { |c| c.parent_id.blank? }
  default_scope -> { includes(:user) }
  scope :recent, -> { order(created_at: :desc) }
  before_destroy :cancel_if_parent
  after_destroy :destroy_parent_if_redacted

  def redacted?
    user_id.blank?
  end

  # By counting the children of the comment's parent
  def only_child?
    Comment.where(parent_id: parent_id).count == 1
  end

  # Retains the fact of the comment's existence to show its children in context
  def redact
    update_columns(user_id: nil, text: nil)
  end

  private

  # Deletes comment only if it has no children, otherwise it must be redacted
  def cancel_if_parent
    throw :abort unless children.empty?
  end

  # If this comment was the only reason not to delete its parent, the parent
  # can now be deleted
  def destroy_parent_if_redacted
    parent.destroy if parent&.redacted? && parent.children.empty?
  end
end
