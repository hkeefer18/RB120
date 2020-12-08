# class Banner
#   def initialize(message)
#     @message = message
#   end

#   def to_s
#     [horizontal_rule, empty_line, message_line, empty_line, horizontal_rule].join("\n")
#   end

#   private

#   def horizontal_rule
#     "+#{"-" * (@message.size + 2)}+"
#   end

#   def empty_line
#     "|#{" " * (@message.size + 2)}|"
#   end

#   def message_line
#     "| #{@message} |"
#   end
# end

# banner = Banner.new('To boldly go where no one has gone before.')
# puts banner

# Further Exploration

class Banner
  def initialize(message, fixed_width = nil)
    @message = message
    @fixed_width = fixed_width
  end

  def to_s
    return "Selected width is too narrow." if width < @message.size
    return "Selected width is too wide." if width > 76 && @fixed_width
    return "Message has too many characters." if width > 76
    [horizontal_rule, empty_line, message_line, empty_line, horizontal_rule].join("\n")
  end

  private

  def width
    if @fixed_width
      @fixed_width - 4
    else
      @message.size
    end
  end

  def horizontal_rule
    "+ #{"-" * width} +"
  end

  def empty_line
    "| #{" " * width} |"
  end

  def whitespace
    if @fixed_width
      (width - @message.size) / 2 + 1
    else
      1
    end
  end

  def extra_space
    (width - @message.size).odd? ? 1 : 0
  end

  def message_line
    "|#{' ' * whitespace}#{@message}#{' ' * whitespace}#{' ' * extra_space}|"
  end
end

banner = Banner.new('To boldly go where no one has gone before.')
banner2 = Banner.new('Hello world', 11)
banner3 = Banner.new('Hello world', 15)
banner4 = Banner.new('Hello world', 81)
banner5 = Banner.new('The message in the banner should be centered within the banner of that width. Decide for yourself how you want to handle widths that are either too narrow or too wide.')
puts banner
puts banner2 # too narrow
puts banner3
puts banner4 # too wide because selected width too long
puts banner5 # too wide because message too long