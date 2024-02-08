class Player
  attr_accessor :name, :hand, :score

  def initialize
    @score = 0
    @hand = []
  end

  def display_hand
    if hand.size < 3
      hand.join(" and ")
    else
      "#{hand[0..-2].join(', ')}, and #{hand[-1]}"
    end
  end

  def calculate_total
    prelim_total = hand.map(&:value).sum
    aces_count = hand.select(&:aces?).size

    one_full_ace_total = prelim_total - (Card::ACE_MODIFIER * (aces_count - 1))

    if one_full_ace_total > TwentyOneGame::BLACKJACK
      one_full_ace_total - Card::ACE_MODIFIER
    elsif prelim_total > TwentyOneGame::BLACKJACK
      one_full_ace_total
    else
      prelim_total
    end
  end

  def busted?
    calculate_total > TwentyOneGame::BLACKJACK
  end

  def blackjack?
    calculate_total == TwentyOneGame::BLACKJACK
  end

  def to_s
    name
  end
end

class Dealer < Player
  DEALER_STAY_VALUE = 17

  def initialize
    super
    @name = "Dealer"
  end

  def deal_opening_hand(deck, player)
    2.times { player.hand << deck.remove_top_card }
    2.times { hand << deck.remove_top_card }
    hand.last.visible = false
  end

  def deal(deck, current_player)
    current_player.hand << deck.remove_top_card
  end

  def hit_or_stay(deck)
    flip_hidden_card
    loop do
      break if busted? || calculate_total >= DEALER_STAY_VALUE
      deal(deck, self)
    end
  end

  private

  def flip_hidden_card
    hand.last.change_visibility
  end
end

class Deck
  SUITS = { "S" => "Spades", "H" => "Hearts", "D" => "Diamonds", "C" => "Clubs" }
  CARDS = ["Ace", ("2".."10").to_a, "Jack", "Queen", "King"].flatten

  def initialize
    @cards = []
    create_starting_deck
  end

  def remove_top_card
    cards.pop
  end

  def card_count
    cards.size
  end

  private

  attr_accessor :cards

  def create_starting_deck
    set_of_cards = CARDS.product(SUITS.keys).map do |card|
      card.join(" of ").to_sym
    end
    set_of_cards.each { |card| cards << Card.new(card) }
    shuffle_deck!
  end

  def shuffle_deck!
    cards.shuffle!
  end
end

class Card
  CARD_VALUES = {
    "2" => 2,
    "3" => 3,
    "4" => 4,
    "5" => 5,
    "6" => 6,
    "7" => 7,
    "8" => 8,
    "9" => 9,
    "10" => 10,
    "Jack" => 10,
    "Queen" => 10,
    "King" => 10,
    "Ace" => 11
  }

  ACE_MODIFIER = 10

  attr_reader :value
  attr_accessor :visible

  def initialize(name)
    @name = name
    @rank = rank_and_suit.first
    @suit = rank_and_suit.last
    @value = find_card_value
    @visible = true
  end

  def change_visibility
    self.visible = true
  end

  def aces?
    rank == "Ace"
  end

  def to_s
    visible ? "#{rank} of #{Deck::SUITS[suit]}" : "a hidden card"
  end

  private

  attr_reader :name, :rank, :suit

  def find_card_value
    CARD_VALUES[rank]
  end

  def rank_and_suit
    name.to_s.split(" of ")
  end
end

class TwentyOneGame
  BLACKJACK = 21
  ROUND_LIMIT = 5
  HIT = "h"
  STAY = "s"

  def play
    display_intro_message
    ask_for_players_name
    display_house_rules
    loop do
      main_game
      display_match_winner
      break unless play_again?
      reset_game
    end
    display_goodbye_message
  end

  private

  attr_reader :user, :dealer
  attr_accessor :deck, :round, :winner

  def initialize
    @round = 1
    @winner = nil
    @user = Player.new
    @dealer = Dealer.new
    @deck = Deck.new
  end

  def display_intro_message
    print "Let's play a game of 21. Please enter your name: "
  end

  def ask_for_players_name
    input = nil
    loop do
      input = gets.chomp
      break unless input.downcase == "dealer"
      print "Sorry, you can't be the dealer. Please enter your name: "
    end
    formatted_name = input.split.map!(&:capitalize).join(" ")
    user.name = formatted_name.strip.empty? ? "Player 1" : formatted_name
  end

  def display_house_rules
    puts "\n"
    puts "Welcome #{user}. These are the house rules:"
    puts "- Cards 2-10 are worth their numbered value. Face cards are worth 10."
    puts "- Aces are worth 1 or 11 depending on your total hand value."
    puts "- Dealer stands on a soft 17 (S17)."
    puts "- No splitting hands."
    puts "- If you bust before the dealer, you lose."
    puts "\n"
    puts "Are you ready to play? (Press ENTER to start)"
    gets
  end

  def main_game
    loop do
      display_round
      play_a_hand
      break if round_over?
      puts "Ready for the next round? (Press ENTER) "
      gets
      setup_next_round
    end
  end

  def display_round
    clear
    puts "-" * 80
    puts "Round #{round}. #{user}: #{user.score}, #{dealer}: #{dealer.score}"
    puts "-" * 80
  end

  def play_a_hand
    dealer.deal_opening_hand(deck, user)
    display_opening_hands
    user_hits_or_stays
    unless winner_found?
      dealer_hits_or_stays
      display_dealers_result
    end
    update_round_winner
    display_round_result
    update_score
  end

  def display_opening_hands
    puts "Dealer has: #{dealer.display_hand}."
    print "You have: #{user.display_hand}. "
    puts "Your total is #{user.calculate_total}."
  end

  def user_hits_or_stays
    loop do
      break if users_turn_done?
      dealer.deal(deck, user)
      puts "Your new total is #{user.calculate_total}: #{user.display_hand}."
    end
    self.winner = dealer if user.busted?
  end

  def users_turn_done?
    user.busted? ||
      user.blackjack? ||
      user_makes_choice == STAY
  end

  def user_makes_choice
    answer = nil
    puts "\n"
    print "Would you like to hit (#{HIT}) or stay (#{STAY})? "
    loop do
      answer = gets.chomp.downcase
      break if [HIT, STAY].include?(answer)
      print "Please enter '#{HIT}' or '#{STAY}': "
    end
    answer
  end

  def winner_found?
    winner.is_a?(Player)
  end

  def dealer_hits_or_stays
    dealer.hit_or_stay(deck)
  end

  def display_dealers_result
    puts "\n"
    puts(
      "#{dealer}'s total is #{dealer.calculate_total}: #{dealer.display_hand}."
    )
  end

  def round_over?
    winner_found? && (winner.score == ROUND_LIMIT)
  end

  def update_round_winner
    user_total = user.calculate_total
    dealer_total = dealer.calculate_total
    self.winner = if user.busted? || (user_total < dealer_total)
                    dealer
                  elsif dealer.busted? || (user_total > dealer_total)
                    user
                  end
  end

  def update_score
    winner.score += 1 if winner_found?
  end

  def display_round_result
    puts return_result_message
    puts "\n"
  end

  def return_result_message
    user_total = user.calculate_total
    dealer_total = dealer.calculate_total
    if user.busted?
      "Bust! The #{dealer} wins this hand..."
    elsif dealer.busted?
      "#{dealer} busts! You win!"
    elsif user_total > dealer_total
      "You win!"
    elsif user_total < dealer_total
      "The #{dealer} wins this hand..."
    elsif user_total == dealer_total
      "It's a tie!"
    end
  end

  def setup_next_round
    clear
    reset_deck
    self.round += 1
    self.winner = nil
    user.hand.clear
    dealer.hand.clear
  end

  def reset_deck
    self.deck = Deck.new
  end

  def clear
    system "clear"
  end

  def display_match_winner
    puts(
      case winner
      when user
        "Congratulations, you won the match #{user.score} to #{dealer.score}!"
      when dealer
        "Sorry, the #{dealer} won the match #{dealer.score} to #{user.score}."
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

  def reset_game
    setup_next_round
    user.score = 0
    dealer.score = 0
    self.round = 1
  end

  def display_goodbye_message
    puts "Thanks for playing! Goodbye!"
  end
end

TwentyOneGame.new.play
