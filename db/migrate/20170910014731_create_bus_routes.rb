class CreateBusRoutes < ActiveRecord::Migration[5.1]
  def change
    create_table :bus_routes do |t|
      t.string :service_no
      t.string :operator
      t.integer :direction
      t.integer :stop_sequence
      t.integer :bus_stop_code
      t.float :distance

      t.timestamps
    end
  end
end
