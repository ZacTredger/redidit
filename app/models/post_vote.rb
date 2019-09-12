class PostVote < ApplicationRecord
  belongs_to :user
  belongs_to :post
  validates :user, presence: true
  validates :post, presence: true
  validates :up, inclusion: [true, false]
end
