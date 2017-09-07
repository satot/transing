module RoutesHelper
  class << self
    def to_weather_icon weather
      case weather
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
  end
end
