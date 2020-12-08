class Cat
  attr_reader :name

  def initialize(name)
    @name = name
  end

  def self.generic_greeting
    puts "I am a cat. Meow!"
  end

  def personal_greeting
    puts "And my name is #{name}."
  end
end

kitty = Cat.new('Sophie')

Cat.generic_greeting
kitty.personal_greeting