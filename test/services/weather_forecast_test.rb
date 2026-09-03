require "test_helper"

class WeatherForecastTest < ActiveSupport::TestCase
  test "parses today's weather from Open-Meteo" do
    forecast = build_forecast

    assert_equal 12.6, forecast.temperature
    assert_equal "Partly cloudy", forecast.description
    assert_equal 15.2, forecast.today.maximum_temperature
    assert_equal 2.4, forecast.today.rainfall
  end

  test "warns about dangerous weather in the upcoming forecast" do
    forecast = build_forecast(minimum_temperatures: [8.0, -1.0, 7.0])

    assert_equal "Bring inside - frost expected Friday", forecast.danger_warning
  end

  test "does not warn when conditions are not dangerous" do
    assert_nil build_forecast.danger_warning
  end

  private

  def build_forecast(minimum_temperatures: [8.0, 7.0, 6.0])
    payload = {
      "current" => { "temperature_2m" => 12.6, "weather_code" => 2 },
      "daily" => daily_payload(minimum_temperatures)
    }

    WeatherForecast.new(http_get: ->(_) { payload.to_json }).fetch
  end

  def daily_payload(minimum_temperatures)
    {
      "time" => %w[2026-09-03 2026-09-04 2026-09-05],
      "weather_code" => [2, 3, 61],
      "temperature_2m_max" => [15.2, 14.0, 13.0],
      "temperature_2m_min" => minimum_temperatures,
      "precipitation_sum" => [2.4, 1.0, 4.0],
      "wind_gusts_10m_max" => [25.0, 30.0, 35.0]
    }
  end
end
