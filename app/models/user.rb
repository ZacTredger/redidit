class User < ApplicationRecord
  has_many :posts
  validates :username, presence: true, length: { maximum: 255 }
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@([a-z\d\-]+\.)+[a-z]+\z/i.freeze
  validates :email, presence: true, length: { maximum: 255 },
                    uniqueness: { case_sensitive: false },
                    format: { with: VALID_EMAIL_REGEX }
  has_secure_password
  validates :password, presence: true, length: { minimum: 7 }
  before_save { email.downcase! }
end
