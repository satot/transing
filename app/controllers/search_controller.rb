require 'open-uri'
class SearchController < ApplicationController
  NUM_OF_ROUTES = 3
  before_action :validate_params, :set_destination, :set_routes, :set_headers,
    :set_addresses, only: [:index]

  def index
  end

  private
  def validate_params
    params.require([:lat, :lng, :destination])
  end

  def set_destination
    @destination = params[:destination]
  end

  def set_headers
    @header = "Directions"
  end

  def set_routes
    polylines = []
    @routes = fetch_routes.sort_by do |route|
        route["legs"].first["duration"]["value"]
      end.select do |route|
        # filter out duplicate routes which have the same polyline
        route["id"] = gen_key route["overview_polyline"]["points"]
        if polylines.include? route["id"]
          false
        else
          polylines << route["id"]
          true
        end
      end.first(NUM_OF_ROUTES).each do |route|
        route["destination"] = @destination
        Rails.cache.write(route["id"], route, expires_in: 3.hour)
      end
  end

  def set_addresses
    if @routes.empty?
      @start_address = "Unknown"
      @end_address = "Unknown"
    else
      leg = @routes.first["legs"].first
      @start_address = leg["start_address"]
      @end_address = leg["end_address"]
    end
  end

  def query
    {
      alternatives: "true",
      destination: params[:destination],
      key: ENV["GOOGLE_API_KEY"],
      mode: "transit",
      origin: [params[:lat], params[:lng]].join(","),
      region: "sg"
    }
  end

  def build_url
    URI::HTTPS.build(
      host: "maps.googleapis.com",
      path: "/maps/api/directions/json",
      query: query.to_query
    ).to_s
  end

  def fetch_routes
    response = Rails.cache.fetch(gen_key(query.to_s), expires_in: 3.minutes) do
      URI.parse(build_url).read
    end
    JSON.parse(response)["routes"]
  end

  def gen_key str
    Digest::MD5.hexdigest(str)
  end
end
