require_relative "contact"

class ContactManager
  class ContactRepository
    NAMES_FIRST = %w[
      Liam
      Noah
      William
      James
      Oliver
      Benjamin
      Elijah
      Lucas
      Mason
      Logan
      Alexander
      Ethan
      Jacob
      Michael
      Daniel
      Henry
      Jackson
      Sebastian
      Aiden
      Matthew
      Samuel
      David
      Joseph
      Carter
      Owen
      Wyatt
      John
      Jack
      Luke
      Jayden
      Dylan
      Grayson
      Levi
      Isaac
      Gabriel
      Julian
      Mateo
      Anthony
      Jaxon
      Lincoln
      Joshua
      Christopher
      Andrew
      Theodore
      Caleb
      Ryan
      Asher
      Nathan
      Thomas
      Leo
      Isaiah
      Charles
      Josiah
      Hudson
      Christian
      Hunter
      Connor
      Eli
      Ezra
      Aaron
      Landon
      Adrian
      Jonathan
      Nolan
      Jeremiah
      Easton
      Elias
      Colton
      Cameron
      Carson
      Robert
      Angel
      Maverick
      Nicholas
      Dominic
      Jaxson
      Greyson
      Adam
      Ian
      Austin
      Santiago
      Jordan
      Cooper
      Brayden
      Roman
      Evan
      Ezekiel
      Xaviar
      Jose
      Jace
      Jameson
      Leonardo
      Axel
      Everett
      Kayden
      Miles
      Sawyer
      Jason
      Emma
      Olivia
      Ava
      Isabella
      Sophia
      Charlotte
      Mia
      Amelia
      Harper
      Evelyn
      Abigail
      Emily
      Elizabeth
      Mila
      Ella
      Avery
      Sofia
      Camila
      Aria
      Scarlett
      Victoria
      Madison
      Luna
      Grace
      Chloe
      Penelope
      Layla
      Riley
      Zoey
      Nora
      Lily
      Eleanor
      Hannah
      Lillian
      Addison
      Aubrey
      Ellie
      Stella
      Natalie
      Zoe
      Leah
      Hazel
      Violet
      Aurora
      Savannah
      Audrey
      Brooklyn
      Bella
      Claire
      Skylar
      Lucy
      Paisley
      Everly
      Anna
      Caroline
      Nova
      Genesis
      Emilia
      Kennedy
      Samantha
      Maya
      Willow
      Kinsley
      Naomi
      Aaliyah
      Elena
      Sarah
      Ariana
      Allison
      Gabriella
      Alice
      Madelyn
      Cora
      Ruby
      Eva
      Serenity
      Autumn
      Adeline
      Hailey
      Gianna
      Valentina
      Isla
      Eliana
      Quinn
      Nevaeh
      Ivy
      Sadie
      Piper
      Lydia
      Alexa
      Josephine
      Emery
      Julia
      Delilah
      Arianna
      Vivian
      Kaylee
      Sophie
      Brielle
      Madeline
    ]
    NAMES_LAST = %w[
      Smith
      Johnson
      Williams
      Brown
      Jones
      Miller
      Davis
      Wilson
      Anderson
      Taylor
    ]
    def initialize(contacts = nil)
      @contacts = contacts || 1000.times.map do |n|
        random_first_name_index = (rand*NAMES_FIRST.size).to_i
        random_last_name_index = (rand*NAMES_LAST.size).to_i
        first_name = NAMES_FIRST[random_first_name_index]
        last_name = NAMES_LAST[random_last_name_index]
        email = "#{first_name}@#{last_name}.com".downcase
        Contact.new(
          first_name: first_name,
          last_name: last_name,
          email: email
        )
      end
    end
  
    def find(attribute_filter_map)
      @contacts.find_all do |contact|
        match = true
        attribute_filter_map.keys.each do |attribute_name|
          contact_value = contact.send(attribute_name).downcase
          filter_value = attribute_filter_map[attribute_name].downcase
          match = false unless contact_value.match(filter_value)
        end
        match
      end
    end
  end
end
