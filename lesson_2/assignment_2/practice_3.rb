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

  private

  def split_names(fullname)
    names = fullname.split
    self.first_name = names[0]
    self.last_name = names.size > 1 ? names[-1] : ""
    self.middle_name = names.size > 2 ? names[1..-2] : ""
  end
end

bob = Person.new('Robert')
p bob.name                  # => 'Robert'
p bob.first_name            # => 'Robert'
p bob.last_name             # => ''
bob.last_name = 'Smith'
p bob.name                  # => 'Robert Smith'

bob.name = "John Adams"
p bob.first_name            # => 'John'
p bob.last_name             # => 'Adams'
p bob.name