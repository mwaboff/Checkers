
class Board
  attr_accessor :board
  def initialize
    @board = generate_board
    @board = populate_board(@board, self)
  end

  def generate_board
    board_array = Array.new(8){Array.new(8){nil}}
    generate_tiles(board_array)
  end

  def generate_tiles(aboard)
    aboard.each_with_index do |row, row_idx|
      row.each_with_index do |col, col_idx|
        aboard[row_idx][col_idx] = Tile.new([row_idx, col_idx])
      end
    end
  end

  def get_team_pieces(color)
    tiles = @board.flatten.select do |tile|
      unless tile.empty?
        tile.occupant.color == color
      else
        false
      end
    end
    result = tiles.map{|tile| tile.occupant}
    result
  end

  def populate_board(a_board, a_self)
    a_board[1..2].each do |black_row|
      black_row.each do |tile|
        if tile.color == :black
          tile.add_piece(Piece.new(:black, tile.position, a_self))
        end
      end
    end

    a_board[5..6].each do |white_row|
      white_row.each do |tile|
        if tile.color == :black
          tile.add_piece(Piece.new(:white, tile.position, a_self))
        end
      end
    end

    a_board
  end

  def dup
    new_board = Board.new
    new_board.board = generate_board
    all_self_pieces = get_team_pieces(:black) + get_team_pieces(:white)
    all_self_pieces.each do |p|
      new_board[p.position].occupant = p.dup(new_board)
    end
    new_board
  end

  def []=(pos, newdata)
    @board[pos[0]][pos[1]] = newdata
  end

  def [](pos)
    @board[pos[0]][pos[1]]
  end

  def in_bounds(pos)
    (0...8).include?(pos[0]) && (0...8).include?(pos[1])
  end

  def add_positions(pos1, pos2)
    [pos1[0] + pos2[0], pos1[1] + pos2[1]]
  end
end

class Tile
  attr_accessor :occupant, :position, :hovered, :selected, :highlight, :color

  def initialize(position)
    @position = position
    @occupant = nil
    @color = (position[0] + position[1]) % 2 == 0 ? :white : :black
    @selected = false
    @hovered = false
    @highlight = false
  end

  def add_piece(a_piece)
    old_piece = @occupant
    @occupant = a_piece
    @occupant.position = @position
    old_piece
  end

  def remove_piece
    @occupant = nil
  end

  def render
    occ_str = " "
    occ_str = @occupant.render unless @occupant.nil?

    contents = (" "+occ_str+" ")
    if @hovered
      contents.on_light_red
    elsif @selected
      contents.on_light_green
    elsif @highlight
      contents.on_light_magenta
    elsif @color == :black
      contents.on_blue
    else
      contents
    end

  end

  def empty?
    @occupant == nil
  end
end