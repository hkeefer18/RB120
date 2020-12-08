# class Shelter
#   @@owners = []

#   def adopt(owner, pet)
#     owner.new_pets(pet)
#     @@owners << owner if !@@owners.include?(owner)
#   end

#   def print_adoptions
#     @@owners.each do |owner|
#       puts "#{owner.name} has adopted the following pets:"
#       owner.pets.each do |pet|
#         puts pet
#       end
#       puts
#     end
#   end
# end

# class Owner
#   attr_reader :name, :number_of_pets, :pets

#   def initialize(name)
#     @name = name
#     @pets = []
#   end

#   def number_of_pets
#     @pets.size
#   end

#   def new_pets(pet)
#     @pets << pet
#   end
# end

# class Pet
#   attr_reader :type, :name

#   def initialize(type, name)
#     @type = type
#     @name = name
#   end

#   def to_s
#     "a #{type} named #{name}"
#   end
# end

# butterscotch = Pet.new('cat', 'Butterscotch')
# pudding      = Pet.new('cat', 'Pudding')
# darwin       = Pet.new('bearded dragon', 'Darwin')
# kennedy      = Pet.new('dog', 'Kennedy')
# sweetie      = Pet.new('parakeet', 'Sweetie Pie')
# molly        = Pet.new('dog', 'Molly')
# chester      = Pet.new('fish', 'Chester')

# phanson = Owner.new('P Hanson')
# bholmes = Owner.new('B Holmes')

# shelter = Shelter.new
# shelter.adopt(phanson, butterscotch)
# shelter.adopt(phanson, pudding)
# shelter.adopt(phanson, darwin)
# shelter.adopt(bholmes, kennedy)
# shelter.adopt(bholmes, sweetie)
# shelter.adopt(bholmes, molly)
# shelter.adopt(bholmes, chester)
# shelter.print_adoptions
# puts "#{phanson.name} has #{phanson.number_of_pets} adopted pets."
# puts "#{bholmes.name} has #{bholmes.number_of_pets} adopted pets."

# Further exploration

class Shelter
  attr_reader :available_pets
  @@owners = []

  def initialize
    @@available_pets = []
  end

  def adopt(owner, pet)
    @@available_pets.delete(pet)
    owner.new_pets(pet)
    @@owners << owner if !@@owners.include?(owner)
  end

  def print_adoptions
    @@owners.each do |owner|
      puts "#{owner.name} has adopted the following pets:"
      owner.pets.each do |pet|
        puts pet
      end
      puts
    end
  end

  def print_available_pets
    puts "The Animal Shelter has the following unadopted pets:"
    @@available_pets.each do |pet|
      puts pet
    end
    puts '      ...     '
  end

  def print_owner_info
    @@owners.each do |owner|
      puts "#{owner.name} has adopted #{owner.number_of_pets} pets."
    end
  end

  def print_shelter_info
    puts "The Animal shelter has #{@@available_pets.size} unadopted pets."
  end
end

class Owner
  attr_reader :name, :number_of_pets, :pets

  def initialize(name)
    @name = name
    @pets = []
  end

  def number_of_pets
    @pets.size
  end

  def new_pets(pet)
    @pets << pet
  end
end

class Pet < Shelter
  attr_reader :type, :name

  def initialize(type, name)
    @type = type
    @name = name
    @@available_pets << self
  end

  def to_s
    "a #{type} named #{name}"
  end
end

shelter = Shelter.new

butterscotch = Pet.new('cat', 'Butterscotch')
pudding      = Pet.new('cat', 'Pudding')
darwin       = Pet.new('bearded dragon', 'Darwin')
kennedy      = Pet.new('dog', 'Kennedy')
sweetie      = Pet.new('parakeet', 'Sweetie Pie')
molly        = Pet.new('dog', 'Molly')
chester      = Pet.new('fish', 'Chester')

phanson = Owner.new('P Hanson')
bholmes = Owner.new('B Holmes')

shelter.print_available_pets
shelter.adopt(phanson, butterscotch)
shelter.adopt(phanson, pudding)
shelter.adopt(phanson, darwin)
shelter.adopt(bholmes, kennedy)
shelter.adopt(bholmes, sweetie)
shelter.adopt(bholmes, molly)
shelter.adopt(bholmes, chester)
shelter.print_adoptions
shelter.print_owner_info
shelter.print_shelter_info