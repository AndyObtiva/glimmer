class Contact
  attr_accessor :first_name, :last_name, :email

  def initialize(attribute_map)
    @first_name = attribute_map[:first_name]
    @last_name = attribute_map[:last_name]
    @email = attribute_map[:email]
  end
end
