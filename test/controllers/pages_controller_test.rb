require "test_helper"

class PagesControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test "get started links signed-out visitors to sign in" do
    get root_url

    assert_response :success
    assert_select "a[href=?]", new_user_session_path, text: "Get started"
  end

  test "get started links signed-in users to their plants" do
    user = User.create!(email: "home-page@example.com", password: "password")
    sign_in user

    get root_url

    assert_response :success
    assert_select "a[href=?]", plants_path, text: "Explore my garden"
  end

  test "home displays the garden status and feature links" do
    get root_url

    assert_response :success
    assert_select ".garden-pulse", text: /Today in your garden/
    assert_select ".home-feature", count: 2
    assert_select "img[alt*='Pothos']", count: 1
  end

  test "navbar uses the Leafy sprout logo" do
    get root_url

    assert_response :success
    assert_select ".navbar-brand img.navbar-mark[src*='leafy-logo']", count: 1
    assert_select ".navbar-mark", text: /🌿/, count: 0
  end
end
