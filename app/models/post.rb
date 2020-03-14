class Post < ApplicationRecord
  extend VotablePreloading
  include Votable
  belongs_to :user
  has_many(:comments) { include VotablePreloading }
  has_many :votes, as: :votable, dependent: :delete_all do
    include VoteCollectionMethods
  end
  validates :user, presence: true
  validates :title, presence: true, length: { maximum: 255 }
  validates :body, presence: { message: "and link can't both be blank" },
                   if: proc { |p| p.link.blank? }
  scope :recent, -> { order(created_at: :desc) }
  after_create :add_creators_upvote
  after_destroy :remove_karma_from_creator
  self.per_page = 20
  attr_accessor :viewer_id

  def redacted?
    false
  end

  private

  def remove_karma_from_creator
    user.post_karma -= karma
    user.save
  end
end
