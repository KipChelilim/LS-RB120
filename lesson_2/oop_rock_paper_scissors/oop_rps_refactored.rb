class Player
  attr_accessor :move, :player_name

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
    name = "Player 1"
    loop do
      puts "What's your name?"
      name = gets.chomp.capitalize
      break unless name.empty?
    end

    self.player_name = name
  end

  def choose
    puts "Please choose rock, paper, or scissors:"
    self.move = Move.new(ask_for_player_choice)
  end
end

class Computer < Player
  def set_name
    self.player_name = ['R2D2', 'C3PO', 'Chappie', "HAL"].sample
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
  attr_accessor :human, :computer

  def initialize
    @human = Human.new
    @computer = Computer.new
  end

  def display_welcome_message
    puts "Welcome to Rock, Paper, Scissors, #{human.player_name}!"
  end

  def display_goodbye_message
    puts "Thanks for playing Rock, Paper, Scissors, #{human.player_name}! Goodbye."
  end


  def display_moves
    puts "=> You chose #{human.move}."
    puts "=> #{computer.player_name} chose #{computer.move}."
    print "=> "
  end

  def display_winner
    if human.move > computer.move
      puts "You won!"
    elsif human.move < computer.move
      puts "You lost..."
    else
      puts "It's a tie!"
    end
  end

  def play
    display_welcome_message

    loop do
      human.choose
      computer.choose
      display_moves
      display_winner
      puts "Would you like to play again? (Y or N)"
      break unless play_again?
    end

    display_goodbye_message
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
