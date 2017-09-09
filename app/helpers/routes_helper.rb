module RoutesHelper
  class << self
    MINUTE = 60

    def to_weather_icon weather
      case weather.to_s
      when ""                 then ""
      when "Fair"             then "A"
      when "Partly Cloudy"    then "C"
      when "Cloudy"           then "D"
      when "Mist"             then "N"
      when "Showers"          then "R"
      when "Heavy Showers"    then "S"
      when "Thundery Showers" then "U"
      when "Heavy Thundery Showers" then "V"
      when "Light Rain"       then "X"
      when "Windy"            then "a"
      else "A"
      end
    end

    def min_to_arrival arrival_time
      return 0 if arrival_time.empty?
      [((Time.parse(arrival_time) - Time.now) / MINUTE).round(0), 0].max
    end
  end
end
