class Card
  include Comparable
  attr_reader :rank, :suit

  LOW_TO_HIGH = [2, 3, 4, 5, 6, 7, 8, 9, 10, 'Jack', 'Queen',
                 'King', 'Ace']

  def initialize(rank, suit)
    @rank = rank
    @suit = suit
  end

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

  def initialize
    generate_deck
  end

  def draw
    generate_deck if @deck.empty?
    @deck.shift
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
  def initialize(deck)
    #@deck = deck
    #@hand = deal_hand
    @hand = deck
    @ranks_only = @hand.map { |card| card.rank }
    @suits_only = @hand.map { |card| card.suit }
  end

  def print
    puts @hand
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

  private

  def deal_hand
    hand = []
    5.times { hand << @deck.draw }
    hand
  end

  def royal_flush?
    straight_flush? && @hand.sort.last.rank == 'Ace'
  end

  def straight_flush?
    straight? && flush?
  end

  def n_of_a_kind?(num)
    @ranks_only.any? { |card| @ranks_only.count(card) == num }
  end

  def four_of_a_kind?
    n_of_a_kind?(4)
  end

  def full_house?
    three_of_a_kind? && pair?
  end

  def flush?
    @suits_only.uniq.size == 1
  end

  def straight?
    return false if @ranks_only.uniq.size < 5
    min_rank = @hand.min.rank
    max_rank = @hand.max.rank
    Card::LOW_TO_HIGH.index(min_rank) ==
      Card::LOW_TO_HIGH.index(max_rank) - 4
  end

  # This works, but refactored above based on LS solution
  
  # def straight?
  #   sorted_ranks = @hand.sort.map(&:rank)
  #   first_card = sorted_ranks[0]
  #   start_index = Card::LOW_TO_HIGH.index(first_card) - 1
  #   sorted_ranks.all? do |card|
  #     start_index += 1
  #     Card::LOW_TO_HIGH.index(card) == start_index
  #   end
  # end

  def three_of_a_kind?
    n_of_a_kind?(3)
  end

  def two_pair?
    pair? && @ranks_only.uniq.size == 3
  end

  def pair?
    n_of_a_kind?(2)
  end
end

class Array
  alias_method :draw, :pop
end

# Test that we can identify each PokerHand type.
hand = PokerHand.new([
  Card.new(10,      'Hearts'),
  Card.new('Ace',   'Hearts'),
  Card.new('Queen', 'Hearts'),
  Card.new('King',  'Hearts'),
  Card.new('Jack',  'Hearts')
])
puts hand.evaluate == 'Royal flush'

hand = PokerHand.new([
  Card.new(8,       'Clubs'),
  Card.new(9,       'Clubs'),
  Card.new('Queen', 'Clubs'),
  Card.new(10,      'Clubs'),
  Card.new('Jack',  'Clubs')
])
puts hand.evaluate == 'Straight flush'

hand = PokerHand.new([
  Card.new(3, 'Hearts'),
  Card.new(3, 'Clubs'),
  Card.new(5, 'Diamonds'),
  Card.new(3, 'Spades'),
  Card.new(3, 'Diamonds')
])
puts hand.evaluate == 'Four of a kind'

hand = PokerHand.new([
  Card.new(3, 'Hearts'),
  Card.new(3, 'Clubs'),
  Card.new(5, 'Diamonds'),
  Card.new(3, 'Spades'),
  Card.new(5, 'Hearts')
])
puts hand.evaluate == 'Full house'

hand = PokerHand.new([
  Card.new(10, 'Hearts'),
  Card.new('Ace', 'Hearts'),
  Card.new(2, 'Hearts'),
  Card.new('King', 'Hearts'),
  Card.new(3, 'Hearts')
])
puts hand.evaluate == 'Flush'

hand = PokerHand.new([
  Card.new(8,      'Clubs'),
  Card.new(9,      'Diamonds'),
  Card.new(10,     'Clubs'),
  Card.new(7,      'Hearts'),
  Card.new('Jack', 'Clubs')
])
puts hand.evaluate == 'Straight'

hand = PokerHand.new([
  Card.new('Queen', 'Clubs'),
  Card.new('King',  'Diamonds'),
  Card.new(10,      'Clubs'),
  Card.new('Ace',   'Hearts'),
  Card.new('Jack',  'Clubs')
])
puts hand.evaluate == 'Straight'

hand = PokerHand.new([
  Card.new(3, 'Hearts'),
  Card.new(3, 'Clubs'),
  Card.new(5, 'Diamonds'),
  Card.new(3, 'Spades'),
  Card.new(6, 'Diamonds')
])
puts hand.evaluate == 'Three of a kind'

hand = PokerHand.new([
  Card.new(9, 'Hearts'),
  Card.new(9, 'Clubs'),
  Card.new(5, 'Diamonds'),
  Card.new(8, 'Spades'),
  Card.new(5, 'Hearts')
])
puts hand.evaluate == 'Two pair'

hand = PokerHand.new([
  Card.new(2, 'Hearts'),
  Card.new(9, 'Clubs'),
  Card.new(5, 'Diamonds'),
  Card.new(9, 'Spades'),
  Card.new(3, 'Diamonds')
])
puts hand.evaluate == 'Pair'

hand = PokerHand.new([
  Card.new(2,      'Hearts'),
  Card.new('King', 'Clubs'),
  Card.new(5,      'Diamonds'),
  Card.new(9,      'Spades'),
  Card.new(3,      'Diamonds')
])
puts hand.evaluate == 'High card'