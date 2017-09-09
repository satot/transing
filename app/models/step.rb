class Step < ApplicationRecord
  belongs_to :route
  TRAVEL_MODE_TRANSIT = "TRANSIT"
  TRAVEL_MODE_WALKING = "WALKING"

  def body
    JSON.parse(content || "{}")
  end

  def distance
    body["distance"]["text"]
  end

  def duration
    body["duration"]["text"]
  end

  def vehicle
    transit_details["line"]["vehicle"]["name"]
  end

  def by_bus?
    vehicle.capitalize == "Bus"
  end

  %w(start_location end_location travel_mode transit_details
     html_instructions).each do |name|
    define_method(name){body[name]}
  end
end
