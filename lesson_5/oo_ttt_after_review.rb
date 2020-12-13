# Game orchestration engine
class TTTGame
  HUMAN_MARKER = 'X'
  COMPUTER_MARKER = 'O'
  # change to false if don't want to allow player to choose
  CHOOSE_WHO_GOES_FIRST = true
  FIRST_TO_MOVE = HUMAN_MARKER
  WINS_NEEDED = 2

  attr_reader :board, :human, :computer

  def initialize
    @board = Board.new
    @human = Human.new(HUMAN_MARKER)
    @computer = Computer.new(COMPUTER_MARKER)
    @current_marker = FIRST_TO_MOVE
  end

  def play
    clear
    display_welcome_message
    set_names
    choose_marker
    main_game
    display_goodbye_message
  end

  private

  def main_game
    loop do
      choose_first_player if CHOOSE_WHO_GOES_FIRST
      display_board
      player_move
      display_result
      update_and_display_score
      break unless play_again?
      reset
      display_play_again_message
    end
  end

  def set_names
    human.set_name
    computer.set_name
    clear
  end

  def choose_first_player
    answer = nil
    loop do
      puts "Would you like to go first?\n "
      puts "Type 'y' if you would like to go first."
      puts "Type 'n' if you would like #{computer.name} to go first."
      answer = gets.chomp.downcase
      break if %w(y n).include?(answer)
    end
    change_to_computer_first if answer == 'n'
    clear
  end

  def change_to_computer_first
    @current_marker = COMPUTER_MARKER
  end

  def choose_marker
    choice = nil
    loop do
      puts 'Choose your marker (must be a single character):'
      choice = gets.chomp
      break if choice.size == 1

      puts 'Invalid choice.'
    end
    HUMAN_MARKER.replace(choice)
    COMPUTER_MARKER.replace('X') if ['0', 'o'].include?(choice.downcase)
    clear
  end

  def player_move
    loop do
      current_player_moves
      break if board.someone_won? || board.full?

      clear_screen_and_display_board if human_turn?
    end
  end

  def display_welcome_message
    puts 'Welcome to Tic Tac Toe!'
    puts ''
    puts "First to #{WINS_NEEDED} wins the tournament!"
    puts ''
  end

  def display_goodbye_message
    puts 'Thanks for playing Tic Tac Toe! Goodbye!'
  end

  def clear
    system 'clear'
  end

  def display_board
    puts "You're a #{human.marker}. #{computer.name} is a #{computer.marker}."
    puts ''
    board.draw
    puts ''
  end

  def clear_screen_and_display_board
    clear
    display_board
  end

  def current_player_moves
    if human_turn?
      human.move(board)
      @current_marker = COMPUTER_MARKER
    else
      computer.move(board)
      @current_marker = HUMAN_MARKER
    end
  end

  def human_turn?
    @current_marker == HUMAN_MARKER
  end

  def display_result
    clear_screen_and_display_board
    case board.winning_marker
    when human.marker
      puts 'You won!'
    when computer.marker
      puts "#{computer.name} won!"
    else
      puts "It's a tie!"
    end
  end

  def update_score
    case board.winning_marker
    when human.marker then human.score.increment
    when computer.marker then computer.score.increment
    end
  end

  def display_score
    puts ''
    puts "#{human.name}: #{human.score}"
    puts "#{computer.name}: #{computer.score}"
    puts ''
    display_champion
  end

  def update_and_display_score
    update_score
    display_score
  end

  def champion
    return human if human.score.value == WINS_NEEDED
    return computer if computer.score.value == WINS_NEEDED
  end

  def display_champion
    if champion == human
      puts "You won the tournament!"
    elsif champion == computer
      puts "#{computer.name} won the tournament!"
    end
  end

  def play_again_prompt
    if champion
      'Would you like to play in another tournament? (y/n)'
    else
      'Would you like to play again? (y/n)'
    end
  end

  def play_again?
    answer = nil
    loop do
      puts ''
      puts play_again_prompt
      answer = gets.chomp.downcase
      break if %w(y n).include?(answer)
      puts 'Sorry, must be y or n'
    end

    answer == 'y'
  end

  def reset
    board.reset
    @current_marker = FIRST_TO_MOVE
    clear
    human.score.reset && computer.score.reset if champion
  end

  def display_play_again_message
    puts "Let's play again!"
    puts ''
  end
end

class Board
  WINNING_LINES = [[1, 2, 3], [4, 5, 6], [7, 8, 9]] + # rows
                  [[1, 4, 7], [2, 5, 8], [3, 6, 9]] + # cols
                  [[1, 5, 9], [3, 5, 7]]              # diagonals
  def initialize
    @squares = {}
    reset
  end

  def []=(key, marker)
    @squares[key].marker = marker
  end

  # rubocop:disable Metrics/AbcSize
  def draw
    puts "     |     |     "
    puts "  #{@squares[1]}  |  #{@squares[2]}  |  #{@squares[3]}"
    puts '-----+-----+-----'
    puts "     |     |     "
    puts "  #{@squares[4]}  |  #{@squares[5]}  |  #{@squares[6]}"
    puts "     |     |     "
    puts '-----+-----+-----'
    puts "     |     |     "
    puts "  #{@squares[7]}  |  #{@squares[8]}  |  #{@squares[9]}"
    puts "     |     |     "
  end
  # rubocop:enable Metrics/AbcSize

  def unmarked_keys
    @squares.keys.select { |key| @squares[key].unmarked? }
  end

  def full?
    unmarked_keys.empty?
  end

  def someone_won?
    !!winning_marker
  end

  # return winning marker or nil
  def winning_marker
    WINNING_LINES.each do |line|
      squares = @squares.values_at(*line)
      if three_identical_markers?(squares)
        return squares.first.marker
      end
    end
    nil
  end

  # return integer square number of best move or nil if no best move exists yet
  def find_best_square(def_or_off)
    marker = marker_for_defense_or_offense(def_or_off)
    WINNING_LINES.each do |line|
      squares = @squares.values_at(*line)
      if two_identical_and_one_empty?(squares, marker)
        return @squares.key(squares.select(&:unmarked?)[0])
      end
    end
    nil
  end

  def reset
    (1..9).each { |key| @squares[key] = Square.new }
  end

  private

  def marker_for_defense_or_offense(def_or_off)
    if def_or_off == :offense
      TTTGame::COMPUTER_MARKER
    elsif def_or_off == :defense
      TTTGame::HUMAN_MARKER
    end
  end

  def two_identical_and_one_empty?(squares, marker)
    markers = squares.map(&:marker)
    markers.count(marker) == 2 && markers.count(Square::INITIAL_MARKER) == 1
  end

  def three_identical_markers?(squares)
    markers = squares.select(&:marked?).map(&:marker)
    return false if markers.size != 3
    markers.min == markers.max
  end
end

class Square
  INITIAL_MARKER = ' '

  attr_accessor :marker

  def initialize(marker = INITIAL_MARKER)
    @marker = marker
  end

  def to_s
    @marker
  end

  def marked?
    marker != INITIAL_MARKER
  end

  def unmarked?
    marker == INITIAL_MARKER
  end
end

class Player
  attr_reader :marker, :score, :name

  def initialize(marker)
    @marker = marker
    @score = Score.new
    @name = nil
  end
end

class Human < Player
  def set_name
    name = nil
    loop do
      puts 'What is your name?'
      name = gets.chomp
      break unless name.strip.empty? || Computer::NAMES.include?(name)

      puts name_error_message(name)
    end
    @name = name
  end

  def move(board)
    puts "Chose a square between (#{joinor(board.unmarked_keys)}):"
    square = nil
    loop do
      square = gets.chomp.to_i
      break if board.unmarked_keys.include?(square)

      puts 'Sorry, that is not a valid choice.'
    end

    board[square] = marker
  end

  private

  def name_error_message(name)
    if Computer::NAMES.include?(name)
      "Sorry, #{name} is a reserved choice for the computer player."
    else
      'Must enter a value.'
    end
  end

  def joinor(array, symbol = ', ', conjunct = 'or')
    case array.size
    when 1 then array[0]
    when 2 then array.join(" #{conjunct} ")
    else
      array[0..-2].join(symbol) + "#{symbol}#{conjunct} " + array[-1].to_s
    end
  end
end

class Computer < Player
  NAMES = %w(R2D2 Hal Chappie Sonny)

  def set_name
    @name = NAMES.sample
  end


  def move(board)
    square = board.find_best_square(:offense)
    square ||= board.find_best_square(:defense)
    square ||= 5 if board.unmarked_keys.include?(5)
    square ||= board.unmarked_keys.sample
    board[square] = marker
  end
end

class Score
  attr_accessor :value

  def initialize
    reset
  end

  def increment
    self.value += 1
  end

  def reset
    self.value = 0
  end

  def to_s
    value.to_s
  end
end

game = TTTGame.new
game.play
