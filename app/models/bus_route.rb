class BusRoute < ApplicationRecord
  has_many :bus_stop, primary_key: "bus_stop_code", foreign_key: "code"

  class << self
    def find_or_create_from_api params
      query = {
        service_no: params["ServiceNo"].to_i,
        direction: params["Direction"].to_i,
        bus_stop_code: params["BusStopCode"].to_i
      }
      self.find_or_create_by(query) do |b|
        b.service_no = params["ServiceNo"].to_s
        b.operator = params["Operator"].to_s
        b.direction = params["Direction"].to_i
        b.stop_sequence = params["StopSequence"].to_i
        b.bus_stop_code = params["BusStopCode"].to_i
        b.distance = params["Distance"].to_f
      end
    end

    def services_at bus_stop_code
      where(bus_stop_code: bus_stop_code).map(&:service_no).uniq
    end

    def find_bus_stops service_no, origin, destination
      if origin.stop_sequence < destination.stop_sequence
        org = origin.stop_sequence
        dest = destination.stop_sequence
      else
        org = destination.stop_sequence
        dest = origin.stop_sequence
      end
      eager_load(:bus_stop)
        .where(service_no: service_no, direction: origin.direction)
        .select do |route|
          org <= route.stop_sequence && route.stop_sequence <= dest
        end.sort_by(&:stop_sequence).map do |route|
          {
            index: route.stop_sequence,
            service_no: service_no,
            name: route.bus_stop.first.name
          }
      end
    end

    def available_services origin, destination
      services_at(origin.code) & services_at(destination.code)
    end

    def available_routes origin, destination
      available_services(origin, destination).map do |s_no|
        org = where(service_no: s_no, bus_stop_code: origin.code).first
        dest = where(service_no: s_no, bus_stop_code: destination.code,
                     direction: org.direction).first
        find_bus_stops s_no, org, dest
      end
    end
  end
end
