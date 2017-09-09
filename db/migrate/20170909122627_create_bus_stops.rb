class CreateBusStops < ActiveRecord::Migration[5.1]
  def change
    create_table :bus_stops do |t|
      t.integer :code
      t.string :name
      t.string :road_name
      t.float :lat
      t.float :lng

      t.timestamps
    end
  end
end
