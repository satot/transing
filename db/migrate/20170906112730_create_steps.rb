class CreateSteps < ActiveRecord::Migration[5.1]
  def change
    create_table :steps do |t|
      t.references :route, foreign_key: true
      t.text :content

      t.timestamps
    end
  end
end
