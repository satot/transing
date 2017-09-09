class RoutesController < ApplicationController
  before_action :set_route_history, only: [:index]
  before_action :set_route, :set_weather, only: [:show]

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

  def set_route
    @route = Route.find(params[:id])
  end

  def set_route_history
    @route_history = Route.time_desc.recent.first(5)
  end

  def set_weather
    sl = @route.steps.first.start_location
    @weather = Weather.new(sl["lat"], sl["lng"]).get_latest
  end
end
