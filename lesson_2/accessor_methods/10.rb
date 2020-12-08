class Person
  def name=(full_nume)
    parts = full_nume.split
    @first_name = parts.first
    @last_name = parts.last
  end

  def name
    @first_name + ' ' + @last_name
  end
end

person1 = Person.new
person1.name = 'John Doe'
puts person1.name