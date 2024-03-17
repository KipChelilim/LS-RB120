class Player
  MARKERS = %w(X O)

  attr_accessor :marker, :name, :score

  def initialize
    @score = 0
  end

  def to_s
    name
  end
end

class User < Player
  def set_player_name
    print "Please enter your player name: "
    name = gets.chomp
    self.name = name.strip.empty? ? "Player 1" : name.capitalize
  end

  def choose_a_square(current_board, _)
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

  def choose_a_square(board, other_player)
    choose_winning_square(board) ||
      choose_defending_square(board, other_player) ||
      choose_middle_square(board) ||
      choose_random_square(board)
  end

  private

  def set_player_name
    self.name = ["K9", "The TARDIS", "Molly", "BET-C", "Doretta"].sample
  end

  def choose_winning_square(board)
    board.find_square_to_win(self)
  end

  def choose_defending_square(board, other_player)
    board.find_square_to_defend(other_player)
  end

  def choose_middle_square(board)
    middle_square_open = board.squares[:B2].current_mark == " "
    :B2 if middle_square_open
  end

  def choose_random_square(board)
    board.open_squares.sample
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

  def mark_square(mark)
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
    squares[choice].mark_square(player.marker)
    open_squares.delete(choice)
  end

  def board_full?
    open_squares.empty?
  end

  def find_square_to_win(current_player)
    winning_square = nil
    WIN_CONDITIONS.each do |winning_line|
      marks = squares.values_at(*winning_line).map(&:current_mark)
      next if marks.count(current_player.marker) != 2 || marks.count(" ") == 0
      winning_square = winning_line.select do |square|
        squares[square].current_mark == " "
      end
      return winning_square.first
    end

    nil
  end

  def find_square_to_defend(other_player)
    defending_square = nil
    WIN_CONDITIONS.each do |winning_line|
      marks = squares.values_at(*winning_line).map(&:current_mark)
      next if marks.count(other_player.marker) != 2 || marks.count(" ") == 0
      defending_square = winning_line.select do |square|
        squares[square].current_mark == " "
      end
      return defending_square.first
    end

    nil
  end

  def winning_marker
    Player::MARKERS.each do |marker|
      WIN_CONDITIONS.each do |line|
        marker_found = squares.values_at(*line).map(&:current_mark).all?(marker)
        return marker if marker_found
      end
    end
    :none_found
  end

  def winner_found?
    Player::MARKERS.include?(winning_marker)
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
  SCORE_LIMIT = 5

  def initialize
    @current_board = Board.new
    @user = User.new
    @computer = Computer.new
    @round = 1
  end

  def play
    display_welcome_message
    user.set_player_name
    loop do
      main_game
      break unless play_again?
      rematch
    end
    display_goodbye_message
  end

  private

  attr_reader :user, :computer
  attr_accessor :current_board, :current_player, :winner, :round_winner, :round

  def display_welcome_message
    puts "Welcome to Tic-Tac-Toe! House rules:"
    puts "- First to #{SCORE_LIMIT} wins"
    puts "- #{Player::MARKERS.first} goes first"
    puts "- Loser goes first in the next round (user's choice after a tie)."
    puts ""
  end

  def main_game
    loop do
      set_first_player
      display_round
      players_take_turns
      update_round_winner
      display_round_winner
      break if user.score >= SCORE_LIMIT || computer.score >= SCORE_LIMIT
      next_round
    end
    display_match_winner
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
    print "Pick your marker (X or O): "
    loop do
      answer = gets.chomp.upcase
      break if Player::MARKERS.include?(answer)
      print "Please enter X or O: "
    end
    return user if answer == "X"
    computer
  end

  def display_round
    clear
    puts "Round #{round}. #{current_player} goes first."
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
    choice = current_player.choose_a_square(current_board, user)
    current_board.update_board!(choice, current_player)
    puts "#{current_player} chose: #{choice}" if current_player == computer
  end

  def update_round_winner
    self.winner = case current_board.winning_marker
                  when computer.marker then computer
                  when user.marker     then user
                  end
    winner.score += 1 if winner.is_a?(Player)
  end

  def display_round_winner
    current_board.display_board
    puts(
      case winner
      when Computer then "Looks like #{computer} won this round..."
      when User     then "Congratulations #{user}, you won that round!"
      else               "It's a tie!"
      end
    )
    puts "#{user}: #{user.score}, #{computer}: #{computer.score}"
  end

  def display_match_winner
    puts ""
    print(
      case winner
      when user     then "You won the match! "
      when computer then "Sorry, #{computer} won the match. "
      end
    )
  end

  def next_round
    puts ""
    puts "Ready for the next round? (press ENTER when ready)"
    gets
    setup_new_board
    self.round += 1
  end

  def setup_new_board
    clear
    self.current_board = Board.new
  end

  def clear
    system "clear"
  end

  def reset_winner_and_score
    user.score = 0
    computer.score = 0
    self.round = 1
    self.winner = nil
  end

  def rematch
    setup_new_board
    reset_winner_and_score
    puts "Let's play again!"
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

  def display_goodbye_message
    puts "Thanks for playing! Goodbye!"
  end
end

current_game = TTTGame.new
current_game.play
