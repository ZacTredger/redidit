class Comment < ApplicationRecord
  extend VotablePreloading
  include Votable
  belongs_to :user
  belongs_to :post
  has_many :children, class_name: 'Comment', foreign_key: :parent_id
  belongs_to :parent, class_name: 'Comment', optional: true
  has_many :votes, as: :votable, dependent: :destroy do
    include VoteCollectionMethods
  end
  validates :user, :post, :text, presence: true
  validates :parent, presence: true, unless: proc { |c| c.parent_id.blank? }
  after_create :add_creators_upvote
  before_destroy :cancel_if_parent
  after_destroy :destroy_parent_if_redacted
  attr_accessor :viewer_id
  attr_writer :level

  class << self
    def recent
      Comments.recent(where(parent_id: nil).order(created_at: :desc) +
        where('parent_id NOT null').order(:parent_id, :created_at))
    end
  end

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

  def level
    @level ||= 0
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

# Arranges comments so that each comment's parent is the next comment at a
# higher level.
class Comments
  class << self
    def recent(relation_comments)
      new(relation_comments).arrange.remove_orphans
    end
  end

  def initialize(relation_comments)
    @comments = relation_comments.to_a
    @orphans = []
  end

  def arrange
    comments.each do |comment|
      next unless (pid = comment.parent_id)

      parent_index = comments.index { |c| c.id == pid }
      next orphan_warning(comment, orphans) unless parent_index

      comment.level = comments[parent_index].level + 1
      move_comment_after(comment, parent_index)
    end
    self
  end

  def remove_orphans
    orphans.each { |orphaned_comment| comments.delete orphaned_comment }
    comments
  end

  private

  attr_reader :comments, :orphans

  def orphan_warning(comment, orphan_list)
    logger.warn "The comment with ID #{comment.id} is orphaned; it refers to "\
                "a parent with ID #{comment.parent_id}, which does not exist."
    orphan_list << comment
  end

  def move_comment_after(comment, index)
    comments.insert(index + 1, comments.delete(comment))
  end
end
