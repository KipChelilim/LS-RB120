class Player
  attr_accessor :move, :name, :score

  def initialize
    set_name
  end

  def ask_for_player_choice
    loop do
      choice = gets.chomp.downcase
      return choice if Move::CHOICES.include?(choice)
      puts "Invalid choice. Please choose either rock, paper, or scissors:"
    end
  end
end

class Human < Player
  def set_name
    temp_name = "Player 1"
    loop do
      puts "Enter your player name:"
      temp_name = gets.chomp.capitalize
      break unless temp_name.empty?
    end

    self.name = temp_name
  end

  def choose
    puts "Please choose rock, paper, or scissors:"
    self.move = Move.new(ask_for_player_choice)
  end
end

class Computer < Player
  def set_name
    self.name = ['R2D2', 'C3PO', 'Chappie', "HAL"].sample
  end

  def choose
    self.move = Move.new(Move::CHOICES.sample)
  end
end

class Move
  CHOICES = ["rock", "paper", "scissors"]
  WIN_CONDITIONS = { "rock" => "scissors", "scissors" => "paper", "paper" => "rock" }

  include Comparable
  attr_writer :choice

  def initialize(choice)
    self.choice = choice
  end

  def <=>(other_choice)
    case other_choice.to_s
    when WIN_CONDITIONS[choice] then 1
    when choice                 then 0
    else                             -1
    end
  end

  def to_s
    choice
  end

  protected

  attr_reader :choice
end

class RPSGame
  SCORE_LIMIT = 10
  attr_accessor :human, :computer, :round

  def initialize
    @human = Human.new
    @computer = Computer.new
    reset_game
  end

  def display_welcome_message
    puts "Welcome to Rock, Paper, Scissors, #{human.name}!"
  end

  def display_goodbye_message
    puts "Thanks for playing Rock, Paper, Scissors, #{human.name}! Goodbye."
  end

  def display_moves
    puts "=> You chose #{human.move}."
    puts "=> #{computer.name} chose #{computer.move}."
    print "=> "
  end

  def display_round_winner
    if human.move > computer.move
      puts "You won that round!"
    elsif human.move < computer.move
      puts "You lost that round..."
    else
      puts "It's a tie!"
    end
  end

  def display_scores
    puts "Round #{round}. Human: #{human.score}, Computer: #{computer.score}"
  end

  def display_winner
    if human.score > computer.score
      puts "Congratulations, you win!"
    else
      puts "Sorry, #{computer.name} won the game..."
    end
  end

  def update_player_scores!
    if human.move > computer.move
      human.score += 1
    elsif human.move < computer.move
      computer.score += 1
    end
  end

  def reset_game
    computer.score = 0
    human.score = 0
    self.round = 1
  end

  def play
    display_welcome_message
    loop do
      play_rps_round
      display_winner
      puts "Would you like to play again? (Y or N)"
      break unless play_again?
      reset_game
    end
    display_goodbye_message
  end

  def play_rps_round
    loop do
      break if [human.score, computer.score].any?(SCORE_LIMIT)
      display_scores
      human.choose
      computer.choose
      display_moves
      display_round_winner
      update_player_scores!
      self.round += 1
    end
  end

  def play_again?
    answer = nil
    loop do
      answer = gets.chomp.downcase
      break if ['y', 'n'].include?(answer)
      puts "Invalid answer. Please chose Y to play again or N to end the game."
    end

    return true if answer == 'y'
    false
  end
end

RPSGame.new.play
