class Person
  attr_accessor :name

  def initialize(name)
    @name = name
  end
end



bob = Person.new('bob')
p bob.name                  # => 'bob'
bob.name = 'Robert'
p bob.name                  # => 'Robert'