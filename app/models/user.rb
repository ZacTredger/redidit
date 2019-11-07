# Models a site user
class User < ApplicationRecord
  attr_reader :remember_token
  has_many :posts
  has_many :comments
  has_secure_password
  validates :username, presence: true, format: { with: /\A[\w\-]+\z/ },
            length: { maximum: 20 }
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@([a-z\d\-]+\.)+[a-z]+\z/i.freeze
  validates :email, presence: true, length: { maximum: 255 },
                    uniqueness: { case_sensitive: false },
                    format: { with: VALID_EMAIL_REGEX }
  validates :password, presence: true, length: { minimum: 7 }, allow_nil: true
  before_save { email.downcase! }
  self.per_page = 20

  class << self
    # Returns the digest of a given string
    def digest(password)
      BCrypt::Password.create(password, cost: hash_cost)
    end

    # Produces a randomly generated token
    def new_token
      SecureRandom.urlsafe_base64
    end

    def find_by(*args)
      super || GuestUser.new
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

  # Generate random token and add its digest in DB
  def remember
    @remember_token = User.new_token
    update(remember_digest: User.digest(remember_token))
  end

  # Remove remember_digest so user will have to log on
  def forget
    update(remember_digest: nil)
  end

  # Returns self if remember_token is correct, otherwise guest user
  def authenticate_from_memory(token)
    return self if BCrypt::Password.new(remember_digest).is_password?(token)

    GuestUser.new
  end

  def exists?
    true
  end

  # Returns the URL to retrieve the user's Gravatar.
  def edit_gravatar_url
    GRAVATAR_ROOT_URL + "/#{gravatar_id}/edit"
  end

  # Returns the URL to retrieve the user's Gravatar.
  def gravatar_url(size = 80)
    GRAVATAR_ROOT_URL + "/avatar/#{gravatar_id}?s=#{size}"
  end

  private

  GRAVATAR_ROOT_URL = 'https://secure.gravatar.com'.freeze

  # Hash of user's email
  def gravatar_id
    Digest::MD5.hexdigest(email.downcase)
  end
end

# Active nothing for User object
class GuestUser
  ASSOCIATIONS = %i[posts comments].freeze
  FALSE_METHODS = %i[exists? authenticate].freeze

  def method_missing(method_name, *_args, &_block)
    if ASSOCIATIONS.include?(method_name)
      method_name.to_s.classify.constantize.none
    elsif FALSE_METHODS.include?(method_name)
      false
    else
      self || super
    end
  end

  def respond_to_missing?(*_args)
    true
  end
end
