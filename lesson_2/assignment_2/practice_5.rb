class Person
  attr_accessor :first_name, :middle_name, :last_name
  attr_reader :name

  def initialize(fullname)
    split_names(fullname)
  end

  def name=(fullname)
    split_names(fullname)
  end

  def name
    "#{first_name} #{middle_name} #{last_name}".strip.squeeze(" ")
  end

  def to_s
    name
  end

  private

  def split_names(fullname)
    names = fullname.split
    self.first_name = names[0]
    self.last_name = names.size > 1 ? names[-1] : ""
    self.middle_name = names.size > 2 ? names[1..-2] : ""
  end
end

bob = Person.new("Robert Smith")
# puts "The person's name is: #{bob}" # => "The person's name is: #<Person:0x00007f22f69b7da8>"
puts "The person's name is: #{bob}" # => "The person's name is: Robert Smith"