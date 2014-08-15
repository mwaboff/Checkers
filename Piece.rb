# encoding: utf-8
class Piece
  attr_accessor :position, :king
  attr_reader :color

  UP_DIRECTION = [[-1, -1], [-1, 1]]
  DOWN_DIRECTION = [[1, -1], [1, 1]]

  def initialize(color, position, board, king=false)
    @color = color
    @other_color = @color == :white ? :black : :white
    @position = position
    @board = board
    @king = king
  end

  def dup(new_board)
    self.class.new(@color, @position, new_board, @king)
  end

  def render
    if @king
      result = @color == :white ? "⛁" : "⛃"
    else
      result = @color == :white ? "⛀" : "⛂"
    end

    result
  end

  def directional_moves
    unless @king
      if @color == :white
        UP_DIRECTION
      else
        DOWN_DIRECTION
      end
    else
      UP_DIRECTION + DOWN_DIRECTION
    end
  end

  def check_moves
    valid = {
      :slides => [],
      :jumps => {}
    }
    blocked_moves = []
    directional_moves.each do |direction|
      new_move = @board.add_positions(direction, @position)

      next unless @board.in_bounds(new_move)

      if @board[new_move].empty?
        valid[:slides] << new_move
      elsif @board[new_move].occupant.color == @other_color
        blocked_moves << [new_move, direction]
      end
    end

    valid[:jumps] = check_jumps(blocked_moves)

    valid
  end

  def check_jumps(blocked_moves)
    valid_jumps = {}
    blocked_moves.each do |move_direction_pair|
      enemy_position = move_direction_pair[0]
      direction = move_direction_pair[1]

      new_jump = @board.add_positions(enemy_position, direction)
      p direction

      next unless @board.in_bounds(new_jump)
      if @board[new_jump].empty?
        chain_jumps = get_chain_jumps(enemy_position, new_jump)
        valid_jumps[new_jump] = [enemy_position, chain_jumps]
      end
    end
    valid_jumps
  end

  def get_chain_jumps(enemy, a_pos)
    dupboard = @board.dup

    duped_self = dupboard.board[@position[0]][@position[1]].occupant
    dupboard[enemy].remove_piece
    dupboard[@position].remove_piece
    dupboard[a_pos].add_piece(duped_self)

    duped_possible_moves = duped_self.check_moves
    pieces = dupboard.get_team_pieces(:black)
    pieces.each do |test|
      puts "#{test} - #{test.position}"
    end

    duped_possible_moves[:jumps]
  end
end