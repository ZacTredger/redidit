# Models a site user
class User < ApplicationRecord
  has_many :posts
  validates :username, presence: true, length: { maximum: 255 }
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@([a-z\d\-]+\.)+[a-z]+\z/i.freeze
  validates :email, presence: true, length: { maximum: 255 },
                    uniqueness: { case_sensitive: false },
                    format: { with: VALID_EMAIL_REGEX }
  has_secure_password
  validates :password, presence: true, length: { minimum: 7 }, allow_nil: true
  before_save { email.downcase! }
  self.per_page = 20

  class << self
    # Returns the digest of a given string
    def digest(password)
      BCrypt::Password.create(password, cost: hash_cost)
    end

    private

    # Retrieves computational cost of hashing: 4 in test, else 10
    def hash_cost
      if ActiveModel::SecurePassword.min_cost
        BCrypt::Engine::MIN_COST
      else
        BCrypt::Engine.cost
      end
    end
  end
end
