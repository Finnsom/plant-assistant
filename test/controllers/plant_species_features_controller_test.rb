require "test_helper"

class PlantSpeciesFeaturesControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = User.create!(email: "catalogue-owner@example.com", password: "password")
    @plant = @user.plants.create!(nickname: "Fern", species: "Boston fern")
    sign_in @user
  end

  test "new plant form offers the common plant catalogue and custom species" do
    get new_plant_url

    assert_response :success
    assert_select "select[data-plant-species-target='select'] option", count: 17
    assert_select "option[value='Monstera deliciosa']", text: "Monstera deliciosa - Swiss cheese plant"
    assert_select "option[value='__other__']", text: /Other/
    assert_select "input[name='plant[species]'][data-plant-species-target='species']", count: 1
    assert_select "button", text: /Identify via photo/
  end

  test "show displays care instructions for a catalogue plant" do
    get plant_url(@plant)

    assert_response :success
    assert_select ".care-guide" do
      assert_select "h2", text: "Care guide"
      assert_select "strong", text: "Water"
      assert_select "span", text: /consistently lightly moist/
    end
  end

  test "identify returns the species supplied by the vision service" do
    PlantIdentifier.provider = ->(_upload) { "Monstera deliciosa - Swiss cheese plant" }
    photo = fixture_file_upload(Rails.root.join("app/assets/images/logo.png"), "image/png")

    post identify_plants_url, params: { photo: photo }

    assert_response :success
    assert_equal "Monstera deliciosa - Swiss cheese plant", response.parsed_body.fetch("species")
  ensure
    PlantIdentifier.provider = nil
  end

  test "identify requires an image" do
    post identify_plants_url

    assert_response :unprocessable_entity
    assert_equal "Choose a plant photo first.", response.parsed_body.fetch("error")
  end
end
