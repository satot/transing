namespace :initialize_bus_stops do
  desc "Fetch data from LTA API and insert into database"
  task :insert, %w(offset) => :environment do |_, args|
    offset = args.offset.to_i || 0
    count = 0
    while true do
      BusStopApi.get_bus_stops(offset).each do |bs|
        BusStop.find_or_create_from_api bs
      end
      # Stop if no more new bus stops
      break if BusStop.all.count == count
      count = BusStop.all.count
      offset += BusStopApi::LIMIT
      sleep 2
    end
    puts "total count: #{BusStop.all.count}"
  end

  task :insert_route, %w(offset) => :environment do |_, args|
    offset = args.offset.to_i || 0
    count = 0
    while true do
      BusStopApi.get_bus_routes(offset).each do |br|
        BusRoute.find_or_create_from_api br
      end
      # Stop if no more new bus stops
      break if BusRoute.all.count == count
      count = BusRoute.all.count
      offset += BusStopApi::LIMIT
      sleep 2
    end
    puts "total count: #{BusRoute.all.count}"
  end
end
