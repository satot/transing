require 'open-uri'
require 'net/http'

class Weather
  WEATHER = "weather"
  attr_reader :lat, :lng, :data
  def initialize lat = nil, lng = nil
    @lat = lat
    @lng = lng
    @data = fetch_from_cache || {}
  end

  def get_latest
    return if data.empty?
    nearest = find_nearest_area
    data["items"].first["forecasts"].select{|f| f["area"] == nearest}
      .first["forecast"]
  end

  private
  def build_url
    URI::HTTPS.build(
      host: "api.data.gov.sg",
      path: "/v1/environment/2-hour-weather-forecast"
    ).to_s
  end

  def fetch_weathers
    uri = URI.parse build_url
    response = Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
      request = Net::HTTP::Get.new(uri.request_uri)
      request["api-key"] = ENV["WEATHER_API_KEY"]
      http.request(request)
    end
    case response
    when Net::HTTPSuccess
      json = response.body
      JSON.parse(json)
    else
      puts response.body
    end
  end

  def fetch_from_cache
    Rails.cache.fetch(WEATHER, expires_in: 30.minutes) do
      fetch_weathers
    end
  end

  def distance latitude, longitude
    Math.sqrt((lat - latitude) ** 2 + (lng - longitude) ** 2)
  end

  def find_nearest_area
    data["area_metadata"].map do |area|
      {
        name: area["name"],
        distance: distance(area["label_location"]["latitude"],
                           area["label_location"]["longitude"])
      }
    end.sort_by{|a| a[:distance]}.first[:name]
  end
end
