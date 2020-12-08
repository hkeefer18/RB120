class Person
  attr_writer :phone_number
  attr_accessor :name
end

person1 = Person.new
person1.name = 'Jessica'
person1.phone_number = '0123456789'
puts person1.name