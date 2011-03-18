require File.dirname(__FILE__) + "/contact_repository"

class ContactManagerPresenter
  attr_accessor :results
  @@contact_attributes = [:first_name, :last_name, :email]
  @@contact_attributes.each {|attribute_name| attr_accessor attribute_name}
  
  def initialize
    @contact_repository = ContactRepository.new
    @results = []
  end
  
  def list
    self.results=@contact_repository.find({})
  end
  
  def find
    filter_map = {}
    @@contact_attributes.each do |attribute_name| 
      filter_map[attribute_name] = self.send(attribute_name) if self.send(attribute_name)
    end
    self.results=@contact_repository.find(filter_map)
  end
end