class Player
  def initialize(color)
    @color = color
    @game = nil
    @board = nil
  end

  def get_move
    raise NotImplementedError
  end

  def pass_game(the_game)
    @game = the_game
    @board = the_game.board
  end

  def to_s
    @color.to_s.capitalize
  end
end

class HumanPlayer < Player

  def get_move

    until @game.turn_over
      @game.render
      puts "#{to_s} Human Player: Make your move..."
      instr = STDIN.getch
      case instr
        when "f" then @game.click_position(@color)
        when "q" then @game.quit
          #when "." then save
        when "g" then emergency_quit
        when "w" then move_cursor([-1, 0])
        when "a" then move_cursor([0, -1])
        when "s" then move_cursor([1, 0])
        when "d" then move_cursor([0, 1])
      end
    end
  end

  def move_cursor(direction)
    new_move = @board.add_positions(@game.cursor, direction)
    @game.move_cursor(new_move) if @board.in_bounds(new_move)
  end
end

class ComputerPlayer < Player
  def get_move
    @game.render
    sleep(0.1)
    my_moves = @game.get_all_team_moves(@color)
    decision = think(my_moves)
    chosen_start, chosen_end = decision[0], decision[1]
    make_move(chosen_start, chosen_end)
    @game.render
  end

  def make_move(start_pos, end_pos)
    @game.move_cursor(start_pos)
    @game.click_position(@color)
    @game.move_cursor(end_pos)
    @game.click_position(@color)
  end


  def think(all_moves)
    raise NotImplementedError
  end
end

class Marvin < ComputerPlayer
  def think(all_moves)
    chosen_piece = all_moves.keys.sample()
    chosen_piece_loc = chosen_piece.position
    chosen_move = all_moves[chosen_piece].sample()
    p "#{chosen_piece.to_s} -> #{chosen_move}"
    [chosen_piece_loc, chosen_move]
  end
end