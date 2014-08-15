# encoding: utf-8
require 'io/console'
require "./Board.rb"
require "./Piece.rb"
require "./Player.rb"
require "./Colorize.rb"

class Game
  attr_reader :board, :turn_over, :cursor

  def initialize(player1, player2)
    @board = Board.new
    @cursor = [3,3]

    @players = {
      0 => player1,
      1 => player2
    }

    @turn_over = false
    @force_mode = false
    @forced_moves = []
    @piece_selected = []
    @current_player
  end

  def render
    system('clear')
    @board.board.each do |row|
      render_str = ""
      row.each do |a_tile|
        render_str += a_tile.render
      end
      puts render_str
    end
  end

  def move_cursor(position)
    if @force_mode && !@forced_moves.empty?
      if @cursor != @forced_moves[0]
        @board[@cursor].hovered = false
        @cursor = @forced_moves[0]
        @board[@cursor].hovered = true
      else
        @board[@cursor].hovered = false
        @cursor = @forced_moves[-1]
        @board[@cursor].hovered = true
      end
    elsif @board.in_bounds(position)
      @board[@cursor].hovered = false
      @board[position].hovered = true
      @cursor = position
    end
    p cursor
  end

  def click_position(color)
    if @board.in_bounds(@cursor)
      if @piece_selected.empty? && !@force_mode
        if !@board[@cursor].empty?
          if @board[@cursor].occupant.color == color
            @board[@cursor].selected = true
            @piece_selected = @cursor
            highlight_possible(@piece_selected)
          end
        end
      elsif !@piece_selected.nil?
        unhighlight(@piece_selected)
        move_piece(@piece_selected, @cursor)
        the_tile = @board[@piece_selected]
        the_tile.selected = false
        @piece_selected = [] unless @force_mode
      end
    end
  end

  def cancel_selection
    @board[piece_selected].selected = false
    @piece_selected = []
  end

  def move_piece(from, to)
    from_tile = @board[from]
    to_tile = @board[to]
    from_piece = from_tile.occupant
    from_moves = from_piece.check_moves

    if from_moves[:slides].include?(to)
      from_tile.remove_piece
      to_tile.add_piece(from_piece)
    elsif from_moves[:jumps].keys.include?(to)
      enemy = from_moves[:jumps][to][0]
      chain_jumps = from_moves[:jumps][to][1]
      enemy_tile = @board[enemy]
      from_tile.remove_piece
      to_tile.add_piece(from_piece)
      enemy_tile.remove_piece
      unless chain_jumps.empty?
        force_chain_jump(to, chain_jumps)
      end
    end
    check_crowning(from_piece)
    @turn_over = true
  end

  def check_crowning(a_piece)
    p "checking crowning - "
    a_piece.king = true if [0, 7].include?(a_piece.position[0])
  end

  def force_chain_jump(pos, chains)
    puts "Entering force chain jump mode"
    @force_mode = true
    @forced_moves = chains.keys
    p chains.keys

    switch_selection(pos)
    highlight_possible(pos)

    @board[@cursor].hovered = false
    @cursor = @forced_moves.first
    @board[@cursor].hovered = true

    @current_player.get_move
    puts "Exiting force chain jump mode"
    @force_mode = false
    @forced_moves = []
  end

  def switch_selection(new_pos)
    old_pos = @piece_selected
    @board[new_pos].selected = true
    @board[old_pos].selected = false
    @piece_selected = new_pos
  end

  def highlight_possible(position)
    if @force_mode
      @forced_moves.each do |forced_pos|
        @board[forced_pos].highlight = true
      end
    else
      possible_moves = @board[position].occupant.check_moves
      possible_moves[:slides].each do |possible|
        @board[possible].highlight = true
      end
      possible_moves[:jumps].keys.each do |possible|
        @board[possible].highlight = true
      end
    end
  end

  def unhighlight(position)
    p position
    possible_moves = @board[position].occupant.check_moves
    possible_moves[:slides].each do |possible|
      @board[possible].highlight = false
    end
    possible_moves[:jumps].keys.each do |possible|
      @board[possible].highlight = false
    end
  end

  def get_all_team_moves(color)
    all_moves = Hash.new([])
    team = @board.get_team_pieces(color)
    team.each do |piece|
      possible_moves = piece.check_moves
      viable_moves = possible_moves[:slides] + possible_moves[:jumps].keys
      all_moves[piece] = viable_moves unless viable_moves.empty?
    end
    all_moves
  end

  def check_game_over
    white_team = @board.get_team_pieces(:white)
    unless white_team.length <= 0
      black_team = @board.get_team_pieces(:black)
      unless black_team.length <= 0
        return false
      end
    end
    return true
  end

  def run
    @players.each_value do |player|
      player.pass_game(self)
      puts "Welcome #{player}"
    end
    turn = 0
    until check_game_over
      @current_player = @players[turn % 2]
      @current_player.get_move
      @turn_over = false
      turn += 1
    end
  end

  def quit
    puts "Quitting..."
    exit(0)
  end
end

def test
  a = HumanPlayer.new(:white)
  b = HumanPlayer.new(:black)
  agame = Game.new(a,b)
  agame.run
  #p agame.get_all_team_moves(:white)
end

test