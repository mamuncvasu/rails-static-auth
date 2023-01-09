require "test_helper"

class StaticPageControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get static_page_index_url
    assert_response :success
  end

  test "should get admin" do
    get static_page_admin_url
    assert_response :success
  end
end
