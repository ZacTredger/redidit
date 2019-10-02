# Helper methods with access to view helpers
module UsersHelper
  def gravatar_for(user, size = 50)
    image_tag(user.gravatar_url(size), alt: user.username, class: 'gravatar')
  end
end
