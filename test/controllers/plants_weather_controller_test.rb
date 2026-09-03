require "test_helper"

class PlantsWeatherControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    user = User.create!(email: "weather@example.com", password: "password")
    @plant = user.plants.create!(nickname: "Fern", species: "Boston fern")
    sign_in user
  end

  test "plant form includes an outside switch" do
    get new_plant_url

    assert_response :success
    assert_select "input[type=checkbox][name='plant[outside]'][role=switch]", count: 1
  end

  test "show displays today's weather" do
    with_weather(dangerous_weather) { get plant_url(@plant) }

    assert_response :success
    assert_select ".weather-summary", text: /London NW1 6ER/
    assert_select ".weather-summary", text: /13°C/
  end

  test "outside plants display dangerous weather warnings" do
    @plant.update!(outside: true)

    with_weather(dangerous_weather) { get plants_url }

    assert_response :success
    assert_select ".weather-warning", text: /Bring inside - frost expected/
  end

  test "inside plants do not display dangerous weather warnings" do
    with_weather(dangerous_weather) { get plants_url }

    assert_response :success
    assert_select ".weather-warning", count: 0
  end

  private

  def with_weather(weather)
    WeatherForecast.provider = -> { weather }
    yield
  ensure
    WeatherForecast.provider = -> {}
  end

  def dangerous_weather
    day = WeatherForecast::Day.new(
      date: Date.current,
      weather_code: 2,
      minimum_temperature: -1.0,
      maximum_temperature: 16.0,
      rainfall: 2.0,
      wind_gusts: 25.0
    )
    WeatherForecast::Result.new(temperature: 12.6, weather_code: 2, days: [day])
  end
end
