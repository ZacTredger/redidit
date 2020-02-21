class Post < ApplicationRecord
  belongs_to :user
  has_many :comments
  has_many :votes, as: :votable, dependent: :destroy
  validates :user, presence: true
  validates :title, presence: true, length: { maximum: 255 }
  validates :body, presence: { message: "and link can't both be blank" },
                   if: proc { |p| p.link.blank? }
  scope :recent, -> { order(created_at: :desc) }
  self.per_page = 20
end
