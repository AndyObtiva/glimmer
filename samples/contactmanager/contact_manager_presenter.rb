require_relative "contact_repository"

class ContactManagerPresenter
  attr_accessor :results
  @@contact_attributes = [:first_name, :last_name, :email]
  @@contact_attributes.each {|attribute_name| attr_accessor attribute_name}

  def initialize(contact_repository = nil)
    @contact_repository = contact_repository || ContactRepository.new
    @results = []
  end

  def list
    self.results = @contact_repository.find({})
  end

  def find
    filter_map = {}
    @@contact_attributes.each do |attribute_name|
      filter_map[attribute_name] = self.send(attribute_name) if self.send(attribute_name)
    end
    self.results = @contact_repository.find(filter_map)
    @sort_attribute_name = nil
    @sort_direction_ascending = nil
  end

  def toggle_sort(attribute_name)
    @sort_attribute_name = attribute_name
    @sort_direction_ascending = !@sort_direction_ascending
    sorted_results = self.results.sort_by {|contact| contact.send(attribute_name).downcase}
    sorted_results = sorted_results.reverse unless @sort_direction_ascending
    self.results = sorted_results
  end
end
