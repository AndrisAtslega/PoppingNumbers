class CreateGames < ActiveRecord::Migration[7.1]
  def change
    create_table :games do |t|
      t.json :board
      t.integer :score

      t.timestamps
    end
  end
end
