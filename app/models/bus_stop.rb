class BusStop < ApplicationRecord
  has_many :bus_routes, primary_key: "code", foreign_key: "bus_stop_code"

  def distance latitude, longitude
    Math.sqrt((lat - latitude) ** 2 + (lng - longitude) ** 2)
  end

  class << self
    def find_or_create_from_api params
      code = params["BusStopCode"].to_i
      self.find_or_create_by(code: code) do |b|
        b.code = code
        b.road_name = params["RoadName"].to_s
        b.name = params["Description"].to_s
        b.lat =  params["Latitude"].to_f
        b.lng =  params["Longitude"].to_f
      end
    end

    def find_nearest latitude, longitude
      Rails.cache.fetch("#{latitude}:#{longitude}", expires_in: 12.hour) do
        all.sort_by{|bs| bs.distance(latitude, longitude)}.first
      end
    end
  end
end
