class Game < ApplicationRecord
    validates :board, presence: true
    validates :score, presence: true, numericality: { greater_than_or_equal_to: 0 }
    validates :number_range, presence: true, numericality: { greater_than: 0, less_than_or_equal_to: 10 }
  
    after_initialize :initialize_board
  
    def initialize_board
      if self.board.blank?
        board_size = self.board_size || 5
        self.board = Array.new(board_size) { Array.new(board_size, nil) }.to_json
      end
      add_random_numbers if JSON.parse(self.board).flatten.compact.empty?
      self.score ||= 0
     
    end
  
    def board_array
      JSON.parse(board)
    end
  
    def place_number(row, col, number)
        board_data = board_array
        board_data[row][col] = number
        self.board = board_data.to_json
        save
        add_random_numbers
        check_for_matches
        true
    end
  
      def add_random_numbers
        board_data = board_array
        number_range = self.number_range || 10
        empty_cells = []

        # Replace '*' with random numbers
        board_data.each_with_index do |row, i|
          row.each_with_index do |cell, j|
            if cell == '*'
              board_data[i][j] = rand(0...number_range)
            end
          end
        end

        # Find empty cells
        board_data.each_with_index do |row, i|
          row.each_with_index do |cell, j|
            empty_cells << [i, j] if cell.nil?
          end
        end

        # Shuffle the empty cells to randomize selection
        empty_cells.shuffle!

       

        # Add '*' to three empty cells (if available)
        empty_cells.take(3).each do |row, col|
          board_data[row][col] = '*'
        end
    
        self.board = board_data.to_json
        save
      end
  
      def check_for_matches
        board_data = board_array
        score_increment = 0

        # Define the range of lengths to check for matches
        match_lengths = (3..5).to_a.reverse

    
        # Check horizontal matches
        board_data.each_with_index do |row, i|
          row.each_with_index do |cell, j|
            next if cell.nil?

            match_lengths.each do |length|
              if j <= row.size - length && row[j, length].uniq.length == 1
                score_increment += points_for_length(length)
                length.times { |k| row[j + k] = nil }
                break  # Break out of the loop once a match is found
              end
            end
          end
        end
    
        # Check vertical matches
        board_data.size.times do |i|
          board_data.size.times do |j|
            next if board_data[j][i].nil?

            match_lengths.each do |length|
              if j <= board_data.size - length && board_data[j, length].all? { |r| r[i] == board_data[j][i] }
              score_increment += points_for_length(length)
                length.times { |k| board_data[j + k][i] = nil }
                break  # Break out of the loop once a match is found
              end
            end
          end
        end
    
        # Check diagonal matches (top-left to bottom-right)
        (0..board_data.size - 3).each do |i|
          (0..board_data.size - 3).each do |j|
            next if board_data[i][j].nil?

            match_lengths.each do |length|
              if i <= board_data.size - length && j <= board_data.size - length && (0...length).all? { |k| board_data[i + k][j + k] == board_data[i][j] }
              score_increment += points_for_length(length)
                length.times { |k| board_data[i + k][j + k] = nil }
                break  # Break out of the loop once a match is found
              end
            end
          end
        end
    
        # Check diagonal matches (top-right to bottom-left)
        (0..board_data.size - 3).each do |i|
          (board_data.size - 1).downto(2).each do |j|
            next if board_data[i][j].nil?

            match_lengths.each do |length|
              if i <= board_data.size - length && j >= length - 1 && (0...length).all? { |k| board_data[i + k][j - k] == board_data[i][j] }
              score_increment += points_for_length(length)
                length.times { |k| board_data[i + k][j - k] = nil }
                break  # Break out of the loop once a match is found
              end
            end
          end
        end

    
        # Update score based on matched numbers
        self.score += score_increment
        self.board = board_data.to_json
        save
      end

      def gameover
        board_array.flatten.include?('*')
      end

      private

      

      def points_for_length(length)
        case length
        when 3
          100
        when 4
          200
        when 5
          500
        end
      end

    end
  