class Person
  attr_reader :name, :first_name, :last_name

  def initialize(fn)
    @first_name = fn
    @name = @first_name
    @last_name = String.new
  end

  def last_name=(ln)
    @last_name = ln
    @name = "#{first_name} #{last_name}"
  end
end

bob = Person.new('Robert')
p bob.name                  # => 'Robert'
p bob.first_name            # => 'Robert'
p bob.last_name             # => ''
bob.last_name = 'Smith'
p bob.name                  # => 'Robert Smith'