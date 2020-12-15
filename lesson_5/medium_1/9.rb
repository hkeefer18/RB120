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

deck = Deck.new
drawn = []
52.times { drawn << deck.draw }
p drawn.count { |card| card.rank == 5 } == 4
p drawn.count { |card| card.suit == 'Hearts' } == 13

drawn2 = []
52.times { drawn2 << deck.draw }
p drawn != drawn2 # Almost always.