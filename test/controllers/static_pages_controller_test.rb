require 'test_helper'

# Tests static pages at the level of the controller only
class StaticPagesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @title_base = ' | Redidit'
  end

  test 'gets homepage' do
    get root_path
    assert_response :success
    assert_select 'title', @title_base[3..]
  end

  test 'gets About' do
    get about_url
    assert_response :success
    assert_select 'title', 'About' + @title_base
  end

  test 'gets Help' do
    get help_url
    assert_response :success
    assert_select 'title', 'Help' + @title_base
  end

  test 'gets contact' do
    get contact_url
    assert_response :success
    assert_select 'title', 'Contact' + @title_base
  end
end
