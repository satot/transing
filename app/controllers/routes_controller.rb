class RoutesController < ApplicationController
  before_action :set_route_history, only: [:index]
  before_action :set_steps, :set_weather, only: [:show]

  def index
  end

  def show
    @header = "Live Directions"
  end

  def start
    cached_route = Rails.cache.read(params["route"]["id"])
    @route = Route.new(route_params cached_route)
    if @route.save
      redirect_to @route
    else
      redirect_to action: "index"
    end
  end

  private
  def route_params route
    {
      origin_name: "Current Location",
      origin_address: route["legs"].first["start_address"],
      destination_name: route["destination"],
      destination_address: route["legs"].first["end_address"],
      type: Route.types[:recent],
      steps_attributes: route["legs"].first["steps"].map do |s|
        {content: s.to_json}
      end
    }
  end

  def set_steps
    route = Route.find params[:id]
    @steps = []
    route.steps.each_with_index do |s, i|
      if s.travel_mode == Step::TRAVEL_MODE_TRANSIT
        content = {
          travel_mode: Step::TRAVEL_MODE_WALKING,
          start_location: s.start_location,
          end_location: s.start_location, #same as start
          vehicle: s.vehicle,
          departure: s.transit_details["departure_stop"]["name"]
        }
        if s.by_bus?
          bus_stop_code = BusStop.find_nearest(
            s.start_location["lat"], s.start_location["lng"]).code
          content[:bus_stop_code] = bus_stop_code
          content[:bus_stop_services] =
            BusStopApi.get_arrival_times(bus_stop_code)
        end
        @steps << Step.new(route: s.route, content: content.to_json)
      end
      @steps << s
    end
  end

  def set_route_history
    @route_history = Route.time_desc.recent.first(5)
  end

  def set_weather
    sl = @steps.first.start_location
    @weather = Weather.new(sl["lat"], sl["lng"]).get_latest
  end
end
