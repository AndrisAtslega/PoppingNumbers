class AddBoardSizeAndNumberRangeToGames < ActiveRecord::Migration[7.1]
  def change
    add_column :games, :board_size, :integer
    add_column :games, :number_range, :integer
  end
end
