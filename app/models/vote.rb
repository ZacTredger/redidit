class Vote < ApplicationRecord
  belongs_to :user
  belongs_to :votable, polymorphic: true
  validates :user, presence: true
  validates :votable, presence: true
  validates :up, inclusion: { in: [true, false] }
end
