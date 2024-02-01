class Player
  CHOICES = ["rock", "paper", "scissors"]
  attr_accessor :move, :player_name

  def initialize(player_type = :human)
    @player_type = player_type
    @move = nil
    set_name
  end

  def set_name
    case player_type
    when :human
      name = "Player 1"
      loop do
        puts "What's your name?"
        name = gets.chomp
        break unless name.empty?
      end

      self.player_name = name
    when :computer
      self.player_name = ['R2D2', 'C3PO', 'Chappie', "HAL"].sample
    end
  end

  def choose
    case player_type
    when :human
      puts "Please choose rock, paper, or scissors:"
      self.move = get_player_choice
    when :computer
      self.move = CHOICES.sample
    end
  end

  def get_player_choice
    loop do
      choice = gets.chomp.downcase
      return choice if CHOICES.include?(choice)
      puts "Invalid choice. Please choose either rock, paper, or scissors:"
    end
  end

  private

  attr_reader :player_type
end

class RPSGame
  attr_accessor :human, :computer
  WIN_CONDITIONS = { "rock" => "scissors", "scissors" => "paper", "paper" => "rock" }

  def initialize
    @human = Player.new(:human)
    @computer = Player.new(:computer)
  end

  def display_welcome_message
    puts "Welcome to Rock, Paper, Scissors, #{human.player_name}!"
  end

  def display_goodbye_message
    puts "Thanks for playing Rock, Paper, Scissors, #{human.player_name}! Goodbye."
  end

  def display_winner
    puts "=> You chose #{human.move}."
    puts "=> #{computer.player_name} chose #{computer.move}."
    print "=> "
    if human.move == computer.move
      puts "It's a tie!"
    elsif computer.move == WIN_CONDITIONS[human.move]
      puts "You won!"
    else
      puts "You lost..."
    end
  end

  def play
    display_welcome_message

    loop do
      human.choose
      computer.choose
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
      break if ['y','n'].include?(answer)
      puts "Invalid answer. Please chose Y to play again or N to end the game."
    end

    return true if answer == 'y'
    false
  end

end

RPSGame.new.play