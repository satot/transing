require 'open-uri'
require 'net/http'

class BusStopApi
  LIMIT = 50

  class << self
    BUS_ARRIVALS = "bus_arrivals"
    PATH_BUSSTOPS = "/ltaodataservice/BusStops"
    PATH_BUSROUTES = "/ltaodataservice/BusRoutes"
    PATH_ARRIVAL = "/ltaodataservice/BusArrivalv2"

    def get_bus_stops offset = 0
      res = fetch build_url(PATH_BUSSTOPS, query_skip(offset))
      res["value"] || []
    end

    def get_bus_routes offset = 0
      res = fetch build_url(PATH_BUSROUTES, query_skip(offset))
      res["value"] || []
    end

    def get_arrival_times code
      res = Rails.cache.fetch("#{BUS_ARRIVALS}:#{code}",
                              expires_in: 1.minutes) do
        fetch build_url(PATH_ARRIVAL, query_code(code))
      end
      res["Services"] || []
    end

    private
    def build_url path, query = ""
      URI::HTTP.build(
        host: "datamall2.mytransport.sg",
        path: path,
        query: query
      ).to_s
    end

    def query_code code
      {"BusStopCode": code}.to_query
    end

    def query_skip num
      {"$skip": num}.to_query
    end

    def fetch url
      puts url
      uri = URI.parse url
      response = Net::HTTP.start(uri.host, uri.port) do |http|
        request = Net::HTTP::Get.new(uri.request_uri)
        request["AccountKey"] = ENV["LTA_API_KEY"]
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
  end
end
