require 'test_helper'

# Check that the links embedded in the header and footer are being rendered
class SiteLayoutTest < ActionDispatch::IntegrationTest
  test 'All static page links appear in layout' do
    get root_path
    assert_select 'a[href=?]', root_path
    assert_select 'a[href=?]', about_path
    assert_select 'a[href=?]', about_path
    assert_select 'a[href=?]', help_path
    assert_select 'a[href=?]', contact_path
    assert_select 'a[href=?]', signup_path
    assert_select 'a[href=?]', login_path
  end
end
