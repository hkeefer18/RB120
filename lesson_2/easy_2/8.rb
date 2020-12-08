class Expander
  def initialize(string)
    @string = string
  end

  def to_s
    self.expand(3) # before ruby 2.7, could not call private
    # methods with an explicit caller, even self. But now 
    # you can so this code runs fine
  end

  private

  def expand(n)
    @string * n
  end
end

expander = Expander.new('xyz')
puts expander