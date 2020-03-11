class Vote < ApplicationRecord
  belongs_to :user
  belongs_to :votable, polymorphic: true
  validates :user, presence: true
  validates :votable, presence: true
  validates :up, inclusion: { in: [true, false] }
  after_create :adjust_votables_karma
  after_update -> { adjust_votables_karma(2) }
  after_destroy -> { adjust_votables_karma(-1) }

  def post
    @post ||= votable.is_a?(Post) ? votable : votable.post
  end

  private

  def adjust_votables_karma(factor = 1)
    delta = up ? 1 * factor : -1 * factor
    votable.karma += delta
    votable.save
    user = votable.user
    votable.is_a?(Post) ? user.post_karma += delta : user.comment_karma += delta
    user.save
  end
end
