require 'test_helper'

# Methods shared between all comment integration test-types
module CommentsTestHelpers
  def commentless_post
    @commentless_post ||= create(:post)
  end
end
