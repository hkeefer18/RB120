class GuessingGame
  GUESSES_AT_START = 7

  def initialize
    @number_of_guesses = GUESSES_AT_START
    @number_to_guess = random_number
    @current_guess = nil
  end

  def play
    reset
    loop do
      break if @current_guess == @number_to_guess || @number_of_guesses == 0
      display_guesses_remaining
      @current_guess = player_guess
      display_result
      increment_guesses
    end
    display_end_of_game_message
  end

  private

  def increment_guesses
    @number_of_guesses -= 1
  end

  def random_number
    (1..100).to_a.sample
  end

  def reset
    @number_of_guesses = GUESSES_AT_START
    @number_to_guess = random_number
    @current_guess = nil
  end

  def display_guesses_remaining
    if @number_of_guesses > 1
      puts "You have #{@number_of_guesses} guesses remaining."
    else
      puts "You have #{@number_of_guesses} guess remaining."
    end
  end

  def player_guess
    guess = nil
    puts 'Enter a number between 1 and 100:'
    loop do
      guess = gets.chomp.to_i
      return guess if (1..100).cover?(guess)
      puts 'Invalid guess. Enter a number between 1 and 100:'
    end
  end

  def low_high_or_correct
    case @current_guess
    when @number_to_guess then :correct
    when 1...@number_to_guess then :low
    when @number_to_guess..100 then :high
    end
  end

  def display_result
    case low_high_or_correct
    when :correct then puts "That's the number!"
    when :low then puts 'Your guess is too low.'
    when :high then puts 'Your guess is too high.'
    end
    puts ''
  end

  def display_end_of_game_message
    if @number_of_guesses == 0
      puts 'You have no more guesses. You lost!'
    else
      puts 'You won!'
    end
  end
end

game = GuessingGame.new
game.play

game.play

    

