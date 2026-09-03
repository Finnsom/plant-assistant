require "test_helper"

class PlantsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = User.create!(email: "plant-owner@example.com", password: "password")
    @plant = @user.plants.create!(nickname: "Fern", species: "Boston fern", last_watered_on: Date.new(2026, 8, 30))
    sign_in @user
  end

  test "show displays a watered today button" do
    get plant_url(@plant)

    assert_response :success
    assert_select ".plant-show__meta-row" do
      assert_select "form[action=?]", watered_today_plant_path(@plant) do
        assert_select "button", text: /Watered today/
      end
    end
  end

  test "index displays a watered today button for each plant" do
    get plants_url

    assert_response :success
    assert_select "form[action=?]", watered_today_plant_path(@plant) do
      assert_select "button", text: /Watered today/
    end
  end

  test "edit does not display the watered today button" do
    get edit_plant_url(@plant)

    assert_response :success
    assert_select "form[action=?]", watered_today_plant_path(@plant), count: 0
  end

  test "edit displays one calendar date field instead of separate date selects" do
    get edit_plant_url(@plant)

    assert_response :success
    assert_select "input[type=date][name='plant[last_watered_on]']", count: 1
    assert_select "select[name^='plant[last_watered_on']", count: 0
  end

  test "new plant form accepts a plant photo" do
    get new_plant_url

    assert_response :success
    assert_select "input[type=file][name='plant[photo]'][accept*='image/jpeg']", count: 1
  end

  test "plant photo is displayed on the index and show pages" do
    @plant.photo.attach(
      io: File.open(Rails.root.join("app/assets/images/logo.png")),
      filename: "fern.png",
      content_type: "image/png"
    )

    get plants_url
    assert_select "img[alt='Photo of Fern']", count: 1

    get plant_url(@plant)
    assert_select "img[alt='Photo of Fern']", count: 1
  end

  test "watered today sets the last watered date to today" do
    travel_to Time.zone.local(2026, 9, 3, 10) do
      patch watered_today_plant_url(@plant)

      assert_redirected_to plant_path(@plant)
      assert_equal Date.new(2026, 9, 3), @plant.reload.last_watered_on
      assert_equal "Fern was watered today.", flash[:notice]
    end
  end

  test "watered today returns to the page where it was clicked" do
    patch watered_today_plant_url(@plant), headers: { "HTTP_REFERER" => plants_url }

    assert_redirected_to plants_path
  end

  test "watered today cannot update another user's plant" do
    other_user = User.create!(email: "other-owner@example.com", password: "password")
    other_plant = other_user.plants.create!(nickname: "Palm", species: "Parlor palm")

    patch watered_today_plant_url(other_plant)

    assert_response :not_found
    assert_nil other_plant.reload.last_watered_on
  end
end
