module Glimmer
  module Config
    class << self
      # Returns Glimmer logger (standard Ruby logger)
      def logger
        # unless defined? @@logger
        #   @@logger = Logger.new(STDOUT).tap {|logger| logger.level = Logger::WARN}
        # end
        @@logger if defined? @@logger
      end
  
      def enable_logging
        @@logger = Logger.new(STDOUT).tap {|logger| logger.level = Logger::WARN}
      end
    end
  end
end

if ENV['GLIMMER_LOGGER_LEVEL']
  Glimmer::Config.enable_logging
  Glimmer::Config.logger.level = ENV['GLIMMER_LOGGER_LEVEL'].downcase
end
