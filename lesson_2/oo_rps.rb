# Game orchestration engine
class RPSGame
  attr_accessor :human, :computer, :move_history

  WINNING_NUMBER = 3

  def initialize
    display_welcome_message
    @human = Human.new
    @computer = Computer.new
    @move_history = []
  end

  def display_welcome_message
    system 'clear'
    puts 'Welcome to Rock, Paper, Scissors, Lizard, Spock!'
    puts
    puts "First to #{WINNING_NUMBER} wins the tournament."
    puts
    puts 'The rules are as follows:'
    puts
    display_rules
    puts 'Press enter to continue.'
    gets
  end

  def display_rules
    puts 'Rock crushes Scissors and Lizard'
    puts 'Paper covers Rock and disproves Spock'
    puts 'Scissors cuts Paper and decapitates Lizard'
    puts 'Lizard eats Paper and poisons Spock'
    puts 'Spock vaporizes Rock and smashes Scissors'
    puts
  end

  def display_goodbye_message
    puts 'Thanks for playing Rock, Paper, Scissors, Lizard, Spock. Good bye!'
  end

  def choose_moves
    human.choose
    computer.choose
    update_move_history
  end

  def update_move_history
    move_history << [human.move, computer.move]
  end

  def display_moves(history = false)
    system 'clear'
    display_moves_header(history)
    empty_line = "#{' ' * 39}||"
    2.times { puts empty_line }
    history ? display_move_history : display_current_move
    2.times { puts empty_line }
    puts '-' * 80
    puts
  end

  def display_moves_header(history)
    hum_name = human.name
    comp_name = computer.name
    hum_spaces = determine_spaces(hum_name)
    comp_spaces = determine_spaces(comp_name)
    puts history ? "#{' ' * 32}Historical Moves" : "#{' ' * 34}Current Turn"
    puts '-' * 80
    puts "#{hum_spaces}#{hum_name}#{hum_spaces}#{comp_spaces}#{comp_name}"
  end

  def determine_spaces(name)
    ' ' * ((40 - name.size) / 2)
  end

  def display_current_move
    hum_move = human.move.to_s
    comp_move = computer.move.to_s
    puts "#{' ' * (34 - hum_move.size)}#{hum_move}     ||     #{comp_move}"
  end

  def display_move_history
    move_history.each do |moves|
      hum_move = moves[0].to_s
      comp_move = moves[1].to_s
      puts "#{' ' * (34 - hum_move.size)}#{hum_move}     ||     #{comp_move}"
    end
  end

  def there_is_history?
    system 'clear'
    !move_history.empty?
  end

  def display_history?
    answer = nil

    loop do
      puts "Would you like to see the history of each players'"
      puts 'moves before choosing your move? (y/n)'
      answer = gets.chomp
      break if %w(y n).include?(answer.downcase)

      puts 'Sorry, must be y or n.'
    end

    return true if answer.downcase == 'y'
  end

  def winner
    if human.move > computer.move
      human
    elsif human.move < computer.move
      computer
    end
  end

  def display_winner(winner)
    if winner == human
      puts "#{human.name} won!"
    elsif winner == computer
      puts "#{computer.name} won!"
    else
      puts "It's a tie!"
    end
  end

  def update_scores(winner)
    human.increment_score if winner == human
    computer.increment_score if winner == computer
  end

  def display_scores
    puts
    puts 'Current standings:'
    puts "#{human.name}: #{human.score}"
    puts "#{computer.name}: #{computer.score}"
    display_champion if champion
  end

  def champion
    return human if human.score == WINNING_NUMBER
    return computer if computer.score == WINNING_NUMBER
  end

  def display_champion
    puts
    puts "#{champion.name} is the champion!"
  end

  def play_again_message
    if champion
      'Would you like to play in another tournament? (y/n)'
    else
      'Would you like to continue in the tournament? (y/n)'
    end
  end

  def play_again?
    answer = nil
    loop do
      puts
      puts play_again_message
      answer = gets.chomp
      break if %w(y n).include?(answer.downcase)

      puts 'Sorry, must be y or n.'
    end
    return true if answer.downcase == 'y'
  end

  def reset_scores
    human.set_score
    computer.set_score
  end

  def reset_history
    self.move_history = []
  end

  def play
    loop do
      display_moves(true) if there_is_history? && display_history?
      choose_moves && display_moves
      display_winner(winner)
      update_scores(winner)
      display_scores
      break unless play_again?

      reset_scores && reset_history if champion
    end
    display_goodbye_message
  end
end

# Move class
class Move
  attr_reader :value

  VALUES = %w(rock paper scissors lizard spock).freeze

  KEY_BEATS_VAL = { 'rock' => %w(scissors lizard), 'paper' => %w(rock spock),
                    'scissors' => %w(paper lizard), 'lizard' => %w(paper spock),
                    'spock' => %w(rock scissors) }.freeze

  def initialize(value)
    @value = value
  end

  def >(other)
    KEY_BEATS_VAL.any? do |winner, losers|
      @value == winner && losers.include?(other.value)
    end
  end

  def <(other)
    KEY_BEATS_VAL.any? do |winner, losers|
      other.value == winner && losers.include?(@value)
    end
  end

  def to_s
    @value
  end
end

# Player class, superclass to Human and Computer
class Player
  attr_accessor :move, :name, :score

  def initialize
    set_name
    set_score
  end

  def set_score
    self.score = 0
  end

  def increment_score
    self.score += 1
  end
end

# Human class, subclasses Player
class Human < Player
  def set_name
    n = ''
    loop do
      puts "What's your name?"
      n = gets.chomp
      break unless n.empty? || Computer::NAMES.include?(n)

      puts name_error_message(n)
    end
    self.name = n
  end

  def name_error_message(name)
    if name.empty?
      'Sorry, invalid input.'
    else
      'Sorry, that name is a reserved choice for the computer player.'
    end
  end

  def choose
    choice = nil
    loop do
      puts 'Please choose rock, paper, scissors, lizard, or spock:'
      choice = gets.chomp
      break if Move::VALUES.include?(choice)

      puts 'Sorry, invalid choice.'
    end
    self.move = Move.new(choice)
  end
end

# Personality module
module Personality
  def values_by_person(name)
    case name
    when 'R2D2' then %w(rock) # always chooses rock
    when 'Hal' then %w(scissors scissors scissors paper) # mostly scrs, rare ppr
    when 'Chappie' then %w(lizard spock) # only chooses from 'special' choices
    when 'Sonny' then Move::VALUES # random
    end
  end
end

# Computer class, subclasses Player, includes Personality module
class Computer < Player
  NAMES = %w(R2D2 Hal Chappie Sonny).freeze

  include Personality

  def set_name
    self.name = NAMES.sample
  end

  def choose
    self.move = Move.new(values_by_person(name).sample)
  end
end

RPSGame.new.play
