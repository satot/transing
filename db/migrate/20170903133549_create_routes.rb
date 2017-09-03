class CreateRoutes < ActiveRecord::Migration[5.1]
  def change
    create_table :routes do |t|
      t.string :origin_name
      t.string :origin_address
      t.string :destination_name
      t.string :destination_address
      t.integer :type

      t.timestamps
    end
  end
end
