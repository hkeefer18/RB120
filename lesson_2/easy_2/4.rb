class Transform
  attr_reader :my_data

  def initialize(my_data)
    @my_data = my_data
  end

  def uppercase
    my_data.upcase
  end

  def self.lowercase(string)
    string.downcase
  end
end


my_data = Transform.new('abc')
puts my_data.uppercase
puts Transform.lowercase('XYZ')