class Post < ApplicationRecord
  belongs_to :user
  has_many :comments
  validates :user, presence: true
  validates :title, presence: true, length: { maximum: 255 }
  validates :body, presence: { message: "and link can't both be blank" },
                   if: proc { |p| p.link.blank? }
end
