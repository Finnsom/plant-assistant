require "json"
require "net/http"
require "uri"

class WeatherForecast
  class_attribute :provider, default: nil

  CACHE_KEY = "weather_forecast/nw1-6er/v1"
  API_URL = "https://api.open-meteo.com/v1/forecast"
  LATITUDE = 51.5238
  LONGITUDE = -0.1586
  LOCATION = "London NW1 6ER"

  Day = Data.define(:date, :weather_code, :minimum_temperature, :maximum_temperature, :rainfall, :wind_gusts)

  Result = Data.define(:temperature, :weather_code, :days) do
    def today = days.first

    def danger_warning
      days.each do |day|
        timing = day.date == Date.current ? "today" : day.date.strftime("%A")
        return "Bring inside - frost expected #{timing}" if day.minimum_temperature <= 2
        return "Bring inside - extreme heat expected #{timing}" if day.maximum_temperature >= 35
        return "Bring inside - damaging winds expected #{timing}" if day.wind_gusts >= 75
        return "Bring inside - heavy rain expected #{timing}" if day.rainfall >= 40
      end

      nil
    end

    def description
      WeatherForecast.description_for(weather_code)
    end
  end

  class << self
    def current
      return provider.call if provider

      Rails.cache.fetch(CACHE_KEY, expires_in: 30.minutes) { new.fetch }
    rescue JSON::ParserError, KeyError, Net::HTTPError, SocketError, SystemCallError, Timeout::Error => e
      Rails.logger.warn("Weather forecast unavailable: #{e.class}: #{e.message}")
      nil
    end

    def description_for(code)
      case code
      when 0 then "Clear"
      when 1..3 then "Partly cloudy"
      when 45, 48 then "Foggy"
      when 51..57 then "Drizzle"
      when 61..67, 80..82 then "Rain"
      when 71..77, 85, 86 then "Snow"
      when 95..99 then "Thunderstorms"
      else "Mixed conditions"
      end
    end
  end

  def initialize(http_get: nil)
    @http_get = http_get || method(:get)
  end

  def fetch
    payload = JSON.parse(@http_get.call(forecast_uri))
    Result.new(
      temperature: payload.fetch("current").fetch("temperature_2m"),
      weather_code: payload.fetch("current").fetch("weather_code"),
      days: build_days(payload.fetch("daily"))
    )
  end

  private

  def forecast_uri
    uri = URI(API_URL)
    uri.query = URI.encode_www_form(
      latitude: LATITUDE,
      longitude: LONGITUDE,
      current: "temperature_2m,weather_code",
      daily: "weather_code,temperature_2m_max,temperature_2m_min,precipitation_sum,wind_gusts_10m_max",
      timezone: "Europe/London",
      forecast_days: 3
    )
    uri
  end

  def get(uri)
    Net::HTTP.start(uri.host, uri.port, use_ssl: true, open_timeout: 3, read_timeout: 5) do |http|
      response = http.get(uri.request_uri)
      response.value
      response.body
    end
  end

  def build_days(daily)
    daily.fetch("time").each_index.map do |index|
      Day.new(
        date: Date.iso8601(daily.fetch("time").fetch(index)),
        weather_code: daily.fetch("weather_code").fetch(index),
        minimum_temperature: daily.fetch("temperature_2m_min").fetch(index),
        maximum_temperature: daily.fetch("temperature_2m_max").fetch(index),
        rainfall: daily.fetch("precipitation_sum").fetch(index),
        wind_gusts: daily.fetch("wind_gusts_10m_max").fetch(index)
      )
    end
  end
end
