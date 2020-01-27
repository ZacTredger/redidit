require 'test_helper'

# Check that the links embedded in the header and footer are being rendered
class SiteLayoutTest < ActionDispatch::IntegrationTest
  test 'All links appear in layout when logged-out' do
    get root_path
    assert_logged_out_header
  end

  test 'All links appear in layout when logged-in' do
    log_in_as
    get root_path
    assert_logged_in_header
  end

  private

  def assert_static_links_in_header
    assert_select 'a[href=?]', root_path
    assert_select 'a[href=?]', about_path
    assert_select 'a[href=?]', about_path
    assert_select 'a[href=?]', help_path
    assert_select 'a[href=?]', contact_path
  end
end
