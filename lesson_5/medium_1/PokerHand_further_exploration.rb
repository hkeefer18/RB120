class Card
  include Comparable
  attr_reader :rank, :suit

  LOW_TO_HIGH = [2, 3, 4, 5, 6, 7, 8, 9, 10, 'Jack', 'Queen',
                 'King', 'Ace']

  def initialize(rank, suit)
    @rank = rank
    @suit = suit
  end

  # Compares cards based on their rank's indexed position
  def <=>(other)
    LOW_TO_HIGH.index(rank) <=> LOW_TO_HIGH.index(other.rank)
  end

  def to_s
    "#{rank} of #{suit}"
  end
end

class Deck
  RANKS = ((2..10).to_a + %w(Jack Queen King Ace)).freeze
  SUITS = %w(Hearts Clubs Diamonds Spades).freeze

  # Allows user to pass in specific cards, as in the test cases
  def initialize(deck = nil)
    deck ? @deck = deck : generate_deck
  end

  def draw
    card = @deck.pop
    generate_deck if @deck.empty?
    card
  end

  private

  def generate_deck
    deck = []
    RANKS.each do |rank|
      SUITS.each do |suit|
        deck << Card.new(rank, suit)
      end
    end
    @deck = deck.shuffle
  end
end

class PokerHand
  include Comparable

  attr_reader :hand

  HANDS_RANKING = { 'Royal flush' => 10, 'Straight flush' => 9,
                    'Four of a kind' => 8, 'Full house' => 7, 'Flush' => 6,
                    'Straight' => 5, 'Three of a kind' => 4, 'Two pair' => 3,
                    'Pair' => 2, 'High card' => 1 }
  N_OF_A_KIND = { 'Four of a kind' => 4, 'Full house' => 3, 'Three of a kind' => 3,
                  'Two pair' => 2, 'Pair' => 2 }

  def initialize(cards)
    @cards = cards.clone
    @hand = deal_hand
  end

  def print
    puts hand
  end

  def evaluate
    case
    when royal_flush?     then 'Royal flush'
    when straight_flush?  then 'Straight flush'
    when four_of_a_kind?  then 'Four of a kind'
    when full_house?      then 'Full house'
    when flush?           then 'Flush'
    when straight?        then 'Straight'
    when three_of_a_kind? then 'Three of a kind'
    when two_pair?        then 'Two pair'
    when pair?            then 'Pair'
    else                       'High card'
    end
  end

  def <=>(other)
    hand_type_self = evaluate
    compare = HANDS_RANKING[hand_type_self] <=> HANDS_RANKING[other.evaluate]
    return compare unless compare == 0
    if N_OF_A_KIND.keys.include?(hand_type_self)
      return compare_n_of_a_kind(other, N_OF_A_KIND[hand_type_self])
    end
    compare_high_card(hand, other.hand) # works for every other hand type
  end

  # Can find best 5 cards out of all the cards passed to
  # PokerHand#initialize when instantiating a new PokerHand object
  # Returns a new PokerHand object whose @hand instance
  # variable references an array of Card objects
  def best_5_cards
    (hand + @cards).combination(5).to_a.map do |hand|
      PokerHand.new(hand)
    end.max
  end

  private

  def compare_n_of_a_kind(other, n)
    cards, remaining = split_cards_by_n_kind(hand, n)
    other_cards, other_remaining = split_cards_by_n_kind(other.hand, n)
    compare = cards.max <=> other_cards.max
    # check low pair if hand is two pair
    compare = cards.min <=> other_cards.min if compare == 0
    compare = compare_high_card(remaining, other_remaining) if compare == 0
    compare
  end

  # partitions into the cards that are involved in the n of a kind
  # and the remaining cards that can be checked for high card if
  # same ranks in n of a kind
  def split_cards_by_n_kind(hand, n)
    hand.partition { |card| hand.count(card) == n }
  end

  # pairs up highest cards in each hand and compares them until
  # one card is higher than the corresponding card in the other hand
  # or until it has compared each card and found that all are equal
  def compare_high_card(hand1, hand2)
    index = - 1
    compare = nil
    loop do
      compare = hand1.sort[index] <=> hand2.sort[index] # uses Card#<=>
      break if compare != 0 || index == -hand1.size
      index -= 1
    end
    compare
  end

  def deal_hand
    hand = []
    5.times do
      hand << @cards.draw
    end
    hand
  end

  def royal_flush?
    straight_flush? && @hand.max.rank == 'Ace'
  end

  def straight_flush?
    straight? && flush?
  end

  def n_of_a_kind?(num)
    @hand.map(&:rank).any? { |card| @hand.map(&:rank).count(card) == num }
  end

  def four_of_a_kind?
    n_of_a_kind?(4)
  end

  def full_house?
    three_of_a_kind? && pair?
  end

  def flush?
    @hand.map(&:suit).uniq.size == 1
  end

  def straight?
    return false if @hand.map(&:rank).uniq.size < 5
    min_rank = @hand.min.rank
    max_rank = @hand.max.rank
    Card::LOW_TO_HIGH.index(min_rank) ==
      Card::LOW_TO_HIGH.index(max_rank) - 4
  end

  def three_of_a_kind?
    n_of_a_kind?(3)
  end

  def two_pair?
    pair? && @hand.map(&:rank).uniq.size == 3
  end

  def pair?
    n_of_a_kind?(2)
  end
end

# Danger danger danger: monkey
# patching for testing purposes.
class Array
  alias_method :draw, :pop
end

# Testing normal features

hand = PokerHand.new(Deck.new)
hand.print # results vary each time
puts hand.evaluate # results vary each time

straight_flush = PokerHand.new([
  Card.new(8,       'Clubs'),
  Card.new(9,       'Clubs'),
  Card.new('Queen', 'Clubs'),
  Card.new(10,      'Clubs'),
  Card.new('Jack',  'Clubs')
])
puts straight_flush.evaluate == 'Straight flush'

three_of_a_kind = PokerHand.new([
  Card.new(3, 'Hearts'),
  Card.new(3, 'Clubs'),
  Card.new(5, 'Diamonds'),
  Card.new(3, 'Spades'),
  Card.new(6, 'Diamonds')
])
puts three_of_a_kind.evaluate == 'Three of a kind'

# Further exploration

# Testing choosing best hand between two hands

# Three of a kind vs pair
hand00 = PokerHand.new([
  Card.new('Jack',  'Clubs'),
  Card.new(5, 'Hearts'),
  Card.new(2,  'Hearts'),
  Card.new('Jack',  'Hearts'),
  Card.new('Jack',  'Spades')
])

hand0 = PokerHand.new([
  Card.new('Ace',  'Clubs'),
  Card.new(5, 'Hearts'),
  Card.new(2,  'Hearts'),
  Card.new('Ace',  'Hearts'),
  Card.new('Jack',  'Spades')
])

puts hand00 > hand0 # three of a kind better than pair

# Two pair vs pair
hand1 = PokerHand.new([
  Card.new(9, 'Hearts'),
  Card.new(9, 'Clubs'),
  Card.new(5, 'Diamonds'),
  Card.new(8, 'Spades'),
  Card.new(5, 'Hearts')
])

hand2 = PokerHand.new([
  Card.new(2, 'Hearts'),
  Card.new(9, 'Clubs'),
  Card.new(5, 'Diamonds'),
  Card.new(9, 'Spades'),
  Card.new(3, 'Diamonds')
])

puts hand1 > hand2 == true # two pair better than pair

# High card
hand3 = PokerHand.new([
  Card.new(2,      'Hearts'),
  Card.new('King', 'Clubs'),
  Card.new(5,      'Diamonds'),
  Card.new(8,      'Spades'),
  Card.new(3,      'Diamonds')
])

hand4 = PokerHand.new([
  Card.new(2,      'Clubs'),
  Card.new('King', 'Hearts'),
  Card.new(5,      'Hearts'),
  Card.new(10,      'Diamonds'),
  Card.new(3,      'Clubs')
])

puts hand3 < hand4 == true # Same high card, hand4 has next high card

# Flushes
hand5 = PokerHand.new([
  Card.new(10, 'Hearts'),
  Card.new('Ace', 'Hearts'),
  Card.new(2, 'Hearts'),
  Card.new('King', 'Hearts'),
  Card.new(3, 'Hearts')
])

hand6 = PokerHand.new([
  Card.new(10, 'Clubs'),
  Card.new('Ace', 'Clubs'),
  Card.new(2, 'Clubs'),
  Card.new('King', 'Clubs'),
  Card.new(3, 'Clubs')
])

puts (hand5 == hand6) == true # Both flushes, same card values

# Straights
hand7 = PokerHand.new([
  Card.new(8,      'Clubs'),
  Card.new(9,      'Diamonds'),
  Card.new(10,     'Clubs'),
  Card.new(7,      'Hearts'),
  Card.new('Jack', 'Clubs')
])

hand8 = PokerHand.new([
  Card.new(8,       'Clubs'),
  Card.new(9,       'Diamonds'),
  Card.new(10,      'Clubs'),
  Card.new('Queen', 'Hearts'),
  Card.new('Jack',  'Clubs')
])

puts hand7 < hand8 == true # Both straights, hand8 has high card

# Four of a kinds
hand9 = PokerHand.new([
  Card.new('Jack', 'Hearts'),
  Card.new('Jack', 'Clubs'),
  Card.new(5, 'Diamonds'),
  Card.new('Jack', 'Spades'),
  Card.new('Jack', 'Diamonds')
])

hand10 = PokerHand.new([
  Card.new(3, 'Hearts'),
  Card.new(3, 'Clubs'),
  Card.new(6, 'Diamonds'),
  Card.new(3, 'Spades'),
  Card.new(3, 'Diamonds')
])

puts hand9 > hand10 == true # Jack four of a kind better than 3s

# Two pair

# Two pair, 10s and 8s
hand11 = PokerHand.new([
  Card.new(8,      'Clubs'),
  Card.new(8,      'Diamonds'),
  Card.new(10,     'Clubs'),
  Card.new(10,      'Hearts'),
  Card.new('Jack', 'Clubs')
])

# Two pair, 10s and 5s Queen high
hand12 = PokerHand.new([
  Card.new(5,       'Clubs'),
  Card.new(5,       'Diamonds'),
  Card.new(10,      'Clubs'),
  Card.new(10,      'Hearts'),
  Card.new('Queen',  'Clubs')
])

# Two pair, 9s and 6s
hand13 = PokerHand.new([
  Card.new(6,       'Clubs'),
  Card.new(6,       'Diamonds'),
  Card.new(9,      'Clubs'),
  Card.new(9,      'Hearts'),
  Card.new('Queen',  'Clubs')
])

# Two pair, 10s and 5s Ace high
hand14 = PokerHand.new([
  Card.new(5,       'Clubs'),
  Card.new(5,       'Diamonds'),
  Card.new(10,      'Clubs'),
  Card.new(10,      'Hearts'),
  Card.new('Ace',  'Clubs')
])

# Two pair, 10s and 5s Ace high
hand15 = PokerHand.new([
  Card.new(5,       'Hearts'),
  Card.new(5,       'Spades'),
  Card.new(10,      'Spades'),
  Card.new(10,      'Clubs'),
  Card.new('Ace',  'Hearts')
])
puts hand11 > hand12 == true # Equal high pair, hand11 better low pair
puts hand12 > hand13 == true # hand12 better high pair
puts hand14 > hand12 == true # Both pair equal, hand14 better kicker
puts (hand15 == hand14) == true # Equal ranks, just different suits

# Full houses
hand16 = PokerHand.new([
  Card.new(3, 'Hearts'),
  Card.new(3, 'Clubs'),
  Card.new(5, 'Diamonds'),
  Card.new(5, 'Spades'),
  Card.new(5, 'Hearts')
])

hand17 = PokerHand.new([
  Card.new(3, 'Hearts'),
  Card.new(3, 'Clubs'),
  Card.new(5, 'Diamonds'),
  Card.new(3, 'Spades'),
  Card.new(5, 'Hearts')
])

puts hand16 > hand17 == true # Both full houses, hand15 has better three of a kind

# Full houses
hand24 = PokerHand.new([
  Card.new(3, 'Hearts'),
  Card.new(3, 'Clubs'),
  Card.new(5, 'Diamonds'),
  Card.new(5, 'Spades'),
  Card.new(5, 'Hearts')
])

hand25 = PokerHand.new([
  Card.new('Ace', 'Hearts'),
  Card.new('Ace', 'Clubs'),
  Card.new(5, 'Diamonds'),
  Card.new(5, 'Spades'),
  Card.new(5, 'Hearts')
])

# Both full houses with same three of a kind, hand25 has better pair
puts hand24 < hand25 == true

# High cards
hand26 = PokerHand.new([
  Card.new('Jack', 'Hearts'),
  Card.new(8, 'Clubs'),
  Card.new(5, 'Diamonds'),
  Card.new(10, 'Spades'),
  Card.new('Queen', 'Hearts')
])

hand27 = PokerHand.new([
  Card.new('Queen', 'Hearts'),
  Card.new(5, 'Clubs'),
  Card.new(10, 'Diamonds'),
  Card.new(8, 'Spades'),
  Card.new('Jack', 'Hearts')
])

hand28 = PokerHand.new([
  Card.new('Jack', 'Hearts'),
  Card.new(8, 'Clubs'),
  Card.new(6, 'Diamonds'),
  Card.new(10, 'Spades'),
  Card.new('Queen', 'Hearts')
])

puts (hand26 == hand27) # all cards equal in rank
# ranks all equal until lowest card, hand28 higher with 6 vs 5
puts hand27 < hand28

# Testing best 5-card hand from a 7-card hand

# Method will return the best hand out of any number
# of cards passed to #new when instantiating a new PokerHand object
# (passed as an array of Card objects).
# Test cases just pass in 7 except for last one passes in 10
# to demonstrate

# Best possible hand is the flush
hand18 = PokerHand.new([
  Card.new(6, 'Clubs'),
  Card.new('Ace', 'Clubs'),
  Card.new(2, 'Clubs'),
  Card.new('King', 'Clubs'),
  Card.new(3, 'Clubs'),
  Card.new(4, 'Diamonds'),
  Card.new(5, 'Diamonds')
])

puts hand18.best_5_cards ==
  PokerHand.new([
    Card.new(6, 'Clubs'),
    Card.new('Ace', 'Clubs'),
    Card.new(2, 'Clubs'),
    Card.new('King', 'Clubs'),
    Card.new(3, 'Clubs')
  ]) # picks flush over straight

# Best possible hand royal flush
hand19 = PokerHand.new([
  Card.new('Jack',  'Clubs'),
  Card.new(10,      'Hearts'),
  Card.new('Ace',   'Hearts'),
  Card.new('Queen', 'Hearts'),
  Card.new('King',  'Hearts'),
  Card.new('Jack',  'Hearts'),
  Card.new('Jack',  'Spades')
])

puts hand19.best_5_cards ==
  PokerHand.new([
    Card.new(10,      'Hearts'),
    Card.new('Ace',   'Hearts'),
    Card.new('Queen', 'Hearts'),
    Card.new('King',  'Hearts'),
    Card.new('Jack',  'Hearts')
  ]) # picks royal flush over three of a kind

# Best possible hand high card, exclude 3 and 3
hand20 = PokerHand.new([
  Card.new(2,      'Hearts'),
  Card.new('King', 'Clubs'),
  Card.new(5,      'Diamonds'),
  Card.new(8,      'Spades'),
  Card.new(3,      'Diamonds'),
  Card.new('Queen', 'Spades'),
  Card.new(10,      'Hearts')
])

puts hand20.best_5_cards ==
  PokerHand.new([
    Card.new('King', 'Clubs'),
    Card.new(5,      'Diamonds'),
    Card.new(8,      'Spades'),
    Card.new('Queen', 'Spades'),
    Card.new(10,      'Hearts')
  ]) # hand with highest valued cards

hand21 = PokerHand.new([
  Card.new(3, 'Hearts'),
  Card.new(3, 'Clubs'),
  Card.new(5, 'Diamonds'),
  Card.new(3, 'Spades'),
  Card.new(5, 'Hearts'),
  Card.new(5, 'Clubs'),
  Card.new(7,  'Clubs')
])

# Could make two types of full house, better one has
# three of a kind 5s and a pair of 3s
puts hand21.best_5_cards ==
  PokerHand.new([
    Card.new(3, 'Clubs'),
    Card.new(5, 'Diamonds'),
    Card.new(3, 'Spades'),
    Card.new(5, 'Hearts'),
    Card.new(5, 'Clubs')
  ])

# Best possible hand is the straight
hand22 = PokerHand.new([
  Card.new(8,       'Clubs'),
  Card.new(9,       'Diamonds'),
  Card.new(10,      'Clubs'),
  Card.new('Queen', 'Hearts'),
  Card.new(2,       'Hearts'),
  Card.new('Jack',  'Clubs'),
  Card.new(2,       'Diamonds')
])

puts hand22.best_5_cards ==
  PokerHand.new([
    Card.new(8,       'Clubs'),
    Card.new(9,       'Diamonds'),
    Card.new(10,      'Clubs'),
    Card.new('Queen', 'Hearts'),
    Card.new('Jack',  'Clubs')
  ])

# Best possible hand is the straight with Queen high
hand23 = PokerHand.new([
  Card.new(8,       'Clubs'),
  Card.new(9,       'Diamonds'),
  Card.new(10,      'Clubs'),
  Card.new('Queen', 'Hearts'),
  Card.new(2,       'Hearts'),
  Card.new('Jack',  'Clubs'),
  Card.new(2,       'Diamonds'),
  Card.new(5,       'Diamonds'),
  Card.new(7,       'Clubs'),
  Card.new(10,      'Spades')
])

puts hand23.best_5_cards ==
  PokerHand.new([
    Card.new(8,       'Clubs'),
    Card.new(9,       'Diamonds'),
    Card.new(10,      'Clubs'),
    Card.new('Queen', 'Hearts'),
    Card.new('Jack',  'Clubs')
  ])
