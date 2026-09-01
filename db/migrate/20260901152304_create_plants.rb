class CreatePlants < ActiveRecord::Migration[8.1]
  def change
    create_table :plants do |t|
      t.string :nickname
      t.string :species
      t.string :location
      t.date :last_watered_on
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
