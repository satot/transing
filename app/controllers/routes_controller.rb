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
    route.steps.each do |s|
      if s.travel_mode == Step::TRAVEL_MODE_TRANSIT
        @steps << setup_waiting_step(s)
        if s.by_bus?
          org = BusStop.find_nearest(
            s.start_location["lat"], s.start_location["lng"])
          dest = BusStop.find_nearest(
            s.end_location["lat"], s.end_location["lng"])
          content = JSON.parse(s.content)
          content["bus_stops"] = BusRoute.available_routes(org, dest)
          s.content = content.to_json
        end
      end
      @steps << s
    end
  end

  def setup_waiting_step step
    content = {
      travel_mode: Step::TRAVEL_MODE_WALKING,
      start_location: step.start_location,
      end_location: step.start_location, #same as start
      vehicle: step.vehicle,
      departure: step.transit_details["departure_stop"]["name"]
    }
    if step.by_bus?
      origin = BusStop.find_nearest(
        step.start_location["lat"], step.start_location["lng"])
      dest = BusStop.find_nearest(
        step.end_location["lat"], step.end_location["lng"])
      services = BusRoute.available_services(origin, dest)
      content[:bus_stop_code] = origin.code
      content[:bus_stop_services] =
        BusStopApi.get_arrival_times(origin.code).select do |service|
          services.include? service["ServiceNo"]
        end
    end
    Step.new(route: step.route, content: content.to_json)
  end

  def set_route_history
    @route_history = Route.time_desc.recent.first(5)
  end

  def set_weather
    sl = @steps.first.start_location
    @weather = Weather.new(sl["lat"], sl["lng"]).get_latest
  end
end
