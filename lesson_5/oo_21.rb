module Clearable
  def clear
    system 'clear'
  end
end

class Game
  WINS_NEEDED = 2

  include Clearable

  attr_reader :deck, :player, :dealer

  def initialize
    reset_deck
    @player = Player.new
    @dealer = Dealer.new
  end

  def start
    opening_sequence
    loop do
      deal_cards
      take_turns
      display_result
      update_and_display_score
      play_again? ? reset_deck : break
      reset_scores if champion
    end
    display_goodbye_message
  end

  private

  def reset_deck
    @deck = Deck.new
  end

  def reset_scores
    player.score.reset
    dealer.score.reset
  end

  def opening_sequence
    clear
    display_welcome_message
    set_names
    set_scores
    display_scoring_rules
    display_play_rules
    clear
  end

  def display_welcome_message
    puts 'Welcome to Twenty-One!'
    puts ''
    puts 'The goal of the game is to score as close'
    puts 'to 21 as possible without going over.'
    puts ''
    puts "The first to win #{WINS_NEEDED} games wins the tournament!"
    puts ''
  end

  def display_goodbye_message
    puts 'Thank you for playing Twenty-One. Good bye!'
  end

  def set_names
    player.set_name
    dealer.set_name
  end

  def set_scores
    player.score = Score.new
    dealer.score = Score.new
  end

  def display_scoring_rules
    clear
    puts 'Scoring is as follows:'
    puts ''
    puts '-Face cards are worth 10'
    puts '-Numbered cards are worth their face value.'
    puts '-Aces are worth 11 if using this value results in'
    puts ' a total of 21 or less. Otherwise, aces are worth 1.'
    puts ''
    puts 'Press enter when you are ready to see how to play.'
    gets
  end

  def display_play_rules
    clear
    puts 'You and the dealer will each be dealt two cards to start.'
    puts "You will then have the option to hit or stay.\n "
    puts 'If you choose to hit, you will be dealt another card.'
    puts "If your total exceeds 21 after you hit, you bust and dealer wins.\n "
    puts "If you choose to stay, your turn ends and it's now dealer's turn.\n "
    puts "Dealer hits until their total at least 17 or until they bust.\n "
    puts 'Press enter when you are ready to play!'
    gets
  end

  def deal_cards
    player.hand = Hand.new
    dealer.hand = Hand.new
    player.hand.cards = deck.initial_deal
    dealer.hand.cards = deck.initial_deal
    dealer.set_one_card
  end

  def display_cards(participant)
    clear
    if participant == player
      show_player_cards_and_one_dealer
    else
      show_player_cards(dealer)
    end
  end

  def show_player_cards_and_one_dealer
    show_player_cards(player)
    puts "#{dealer} has #{dealer.one_card} and unknown card."
  end

  def show_player_cards(participant)
    puts "#{participant} has #{participant.hand}."
    puts "#{participant}'s total is #{participant.hand.total}."
    puts ''
  end

  def take_turns
    take_turn(player)
    take_turn(dealer) unless player.hand.busted?
  end

  def take_turn(participant)
    loop do
      display_cards(participant)
      choice = participant.hit_or_stay
      break if choice == :stay

      participant.hit(deck.draw_card)
      break if participant.hand.busted?
    end
    participant.display_end_of_turn_message
  end

  def determine_winner
    if player.hand > dealer.hand
      player
    elsif dealer.hand > player.hand
      dealer
    end
  end

  def display_result
    puts "#{player} had #{player.hand}."
    puts "#{dealer} had #{dealer.hand}.\n "
    puts 'Round Points:'
    display_final_total
    puts ''
    display_winner
  end

  def display_final_total
    puts "#{player} - #{player.hand.total}" +
         bust_message_if_bust(player)
    puts "#{dealer} - #{dealer.hand.total}" +
         bust_message_if_bust(dealer)
  end

  def bust_message_if_bust(participant)
    return ' - BUST!' if participant.hand.busted?
    ''
  end

  def display_winner
    winner = determine_winner
    puts winner ? "** #{winner} won! **" : "** It's a tie! **"
    puts ''
  end

  def update_and_display_score
    update_score
    display_score
  end

  def update_score
    # safe navigation operator skips next method call when receiver nil
    determine_winner&.score&.increment
  end

  def display_score
    puts 'Player Scores:'
    puts "#{player} - #{player.score}"
    puts "#{dealer} - #{dealer.score}"
    puts ''
    puts "#{champion} is the champion!\n " if champion
  end

  def champion
    return player if player.score.value == WINS_NEEDED
    return dealer if dealer.score.value == WINS_NEEDED
  end

  def play_again?
    answer = nil
    loop do
      puts play_again_message
      answer = gets.chomp.downcase
      break if %w(y n).include?(answer)

      puts 'Invalid input.'
    end

    answer == 'y'
  end

  def play_again_message
    if champion
      'Would you like to play in another tournament? (y/n)'
    else
      'Would you like to play again? (y/n)'
    end
  end
end

class Deck
  CARD_VALUES = [2, 3, 4, 5, 6, 7, 8, 9, 10, 'Jack', 'Queen', 'King', 'Ace']

  attr_reader :deck

  def initialize
    @deck = initialize_and_shuffle_deck
  end

  def initial_deal
    hand = []
    2.times { hand << deck.pop }
    hand
  end

  def draw_card
    deck.pop
  end

  private

  def initialize_and_shuffle_deck
    deck = []
    4.times { CARD_VALUES.each { |card| deck << card } }
    deck.shuffle!
  end
end

class Hand
  attr_accessor :cards

  def initialize
    @cards = []
  end

  def total_without_aces
    sum = 0
    cards.reject { |card| card == 'Ace' }.each do |card|
      case card
      when 'Jack', 'Queen', 'King' then sum += 10
      else sum += card
      end
    end
    sum
  end

  def total
    current_total = total_without_aces
    aces = cards.select { |card| card == 'Ace' }
    aces.each do |_ace|
      value = current_total <= 10 ? 11 : 1
      current_total += value
    end
    current_total
  end

  def busted?
    total > 21
  end

  def >(other)
    (total > other.total || other.busted?) && !busted?
  end

  def joinand(array)
    case array.size
    when 1 then array[0]
    when 2 then array.join(' and ')
    else
      array[0..-2].join(', ') + ', and ' + array[-1].to_s
    end
  end

  def to_s
    joinand(cards)
  end
end

class Participant
  include Clearable

  attr_accessor :hand, :score
  attr_writer :name

  def pause
    sleep 1.75
  end

  def hit(new_card)
    puts "#{self} chose to hit."
    pause
    hand.cards << new_card
    clear
    puts "#{self} drew a #{new_card}."
    puts ''
  end

  def display_end_of_turn_message
    if hand.busted?
      puts "#{self} busted!"
    else
      puts "#{self} chose to stay."
    end
    pause
    clear
  end

  def to_s
    @name
  end
end

class Player < Participant
  def hit_or_stay
    puts ''
    return if hand.busted? # don't ask if busted
    choice = nil
    loop do
      puts 'Would you like to hit or stay? (h/s)'
      choice = gets.chomp.downcase
      break if %w(h s).include?(choice)

      puts "That's not a valid choice."
    end
    choice == 'h' ? :hit : :stay
  end

  def set_name
    answer = nil
    loop do
      puts 'We will go over the rules next, but first, what is your name?'
      answer = gets.chomp
      break unless answer.strip.empty?

      puts 'Must enter a value.'
    end
    self.name = answer
  end
end

class Dealer < Participant
  attr_reader :one_card

  def set_one_card
    @one_card = @hand.cards.sample
  end

  def hit_or_stay
    hand.total >= 17 ? :stay : :hit
  end

  def set_name
    # prefer dealer not to have a name for this game
    # but can easily change to sample from an array
    self.name = 'Dealer'
  end
end

class Score
  attr_reader :value

  def initialize
    reset
  end

  def reset
    @value = 0
  end

  def increment
    @value += 1
  end

  def to_s
    @value.to_s
  end
end

Game.new.start
