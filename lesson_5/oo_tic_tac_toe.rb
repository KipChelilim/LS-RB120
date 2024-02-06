class Player
  MARKERS = %w(X O)

  attr_accessor :marker, :name

  def to_s
    name
  end
end

class User < Player
  def set_player_name
    print "Please enter your player name: "
    name = gets.chomp
    self.name = name.strip.empty? ? "Player 1" : name.capitalize
    "K"
  end

  def choose_a_square(current_board)
    choice = ""
    print "Please choose a square: "
    loop do
      choice = gets.chomp.upcase.to_sym
      break if valid_choice?(choice, current_board)
      print "Please choose an open square. Enter a letter, then a number: "
    end
    choice
  end

  private

  def valid_choice?(choice, current_board)
    current_board.open_squares.include?(choice)
  end
end

class Computer < Player
  def initialize
    super
    set_player_name
  end

  def choose_a_square(current_board)
    current_board.open_squares.sample
  end

  private

  def set_player_name
    self.name = ["K9", "The TARDIS", "Molly", "BET-C", "Doretta"].sample
  end
end

class Square
  attr_reader :label, :current_mark

  def initialize(label)
    @label = label
    @current_mark = " "
  end

  def to_s
    @current_mark
  end

  def mark_square=(mark)
    @current_mark = mark
  end
end

class Board
  ROW_HEADER  = "    A   B   C  "
  ROW_BOARDER = "  +---+---+---+"
  WIN_CONDITIONS = [
    [:A1, :A2, :A3], [:B1, :B2, :B3], [:C1, :C2, :C3], # verticals
    [:A1, :B1, :C1], [:A2, :B2, :C2], [:A3, :B3, :C3], # horizontals
    [:A1, :B2, :C3], [:A3, :B2, :C1]                   # diagonals
  ]

  attr_reader :squares, :open_squares

  def initialize
    @open_squares = [:A1, :A2, :A3, :B1, :B2, :B3, :C1, :C2, :C3]
    @squares = set_initial_squares
  end

  def display_board
    puts ROW_HEADER
    puts ROW_BOARDER
    display_row(1)
    puts ROW_BOARDER
    display_row(2)
    puts ROW_BOARDER
    display_row(3)
    puts ROW_BOARDER
  end

  def update_board!(choice, player)
    squares[choice].mark_square = player.marker
    open_squares.delete(choice)
  end

  def board_full?
    open_squares.empty?
  end

  def winning_marker
    Player::MARKERS.each do |marker|
      WIN_CONDITIONS.each do |line|
        marks = line.map { |square_label| squares[square_label].current_mark }
        return marker if marks.all?(marker)
      end
    end
    :none_found
  end

  def winner_found?
    !(winning_marker == :none_found)
  end

  private

  def set_initial_squares
    open_squares.each_with_object({}) do |key, hash|
      hash[key.to_sym] = Square.new(key.to_sym)
    end
  end

  def display_row(row_num)
    row = row_num.to_s
    square_a = squares[("A#{row}").to_sym]
    square_b = squares[("B#{row}").to_sym]
    square_c = squares[("C#{row}").to_sym]
    puts "#{row} | #{square_a} | #{square_b} | #{square_c} |"
  end
end

class TTTGame
  def initialize
    @current_board = Board.new
    @user = User.new
    @computer = Computer.new
  end

  def play
    display_welcome_message
    user.set_player_name
    main_game
    display_goodbye_message
  end

  private

  attr_reader :user, :computer
  attr_accessor :current_board, :current_player, :winner

  def display_welcome_message
    puts "Welcome to Tic-Tac-Toe! #{Player::MARKERS.first} goes first."
  end

  def main_game
    loop do
      set_first_player
      players_take_turns
      display_winner
      break unless play_again?
      setup_new_game
    end
  end

  def set_first_player
    self.current_player = case winner
                          when user        then computer
                          when computer    then user
                          else                  pick_who_goes_first
                          end
    markers = current_player == user ? Player::MARKERS : Player::MARKERS.reverse
    user.marker, computer.marker = markers
  end

  def pick_who_goes_first
    answer = nil
    print "Do you want to pick first? (Y or N) "
    loop do
      answer = gets.chomp.downcase
      break if ["y", "n"].include?(answer)
      print "Please enter Y or N: "
    end
    return user if answer == "y"
    computer
  end

  def players_take_turns
    loop do
      current_board.display_board if current_player == user
      player_makes_move(current_player)
      clear if current_player == user
      break if game_over?
      self.current_player = current_player == user ? computer : user
    end
  end

  def game_over?
    current_board.winner_found? || current_board.board_full?
  end

  def player_makes_move(current_player)
    choice = current_player.choose_a_square(current_board)
    current_board.update_board!(choice, current_player)
    puts "#{current_player} chose: #{choice}" if current_player == computer
  end

  def identify_winner
    self.winner = case current_board.winning_marker
                  when :none_found then :none_found
                  when user.marker then user
                  else                  computer
                  end
  end

  def display_winner
    identify_winner
    current_board.display_board
    puts(
      case winner
      when :none_found then "It's a tie!"
      when user        then "Congratulations #{user}, you win!"
      else                  "Sorry, #{computer} won that round..."
      end
    )
  end

  def play_again?
    answer = nil
    print "Would you like to play again? (Y or N) "
    loop do
      answer = gets.chomp.downcase
      break if ["y", "n"].include?(answer)
      print "Please enter Y or N: "
    end
    answer == "y"
  end

  def setup_new_game
    clear
    self.current_board = Board.new
    display_rematch_message
  end

  def display_rematch_message
    puts "Let's play again!"
    puts "Loser goes first." unless winner == :none_found
  end

  def clear
    system "clear"
  end

  def display_goodbye_message
    puts "Thanks for playing! Goodbye!"
  end
end

current_game = TTTGame.new
current_game.play
