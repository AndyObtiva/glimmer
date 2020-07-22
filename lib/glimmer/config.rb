module Glimmer
  module Config
    class << self
      LOOP_MAX_COUNT_DEFAULT = 100
      
      attr_writer :loop_max_count
      
      def loop_max_count
        @loop_max_count ||= LOOP_MAX_COUNT_DEFAULT
      end
      
      # Returns Glimmer logger (standard Ruby logger)
      def logger
        reset_logger! unless defined? @@logger
        @@logger
      end
      
      def logger=(custom_logger)
        @@logger = custom_logger
      end
  
      def reset_logger!
        self.logger = Logger.new(STDOUT).tap do |logger| 
          logger.level = Logger::ERROR
        end
      end
    end
  end
end

if ENV['GLIMMER_LOGGER_LEVEL']
  Glimmer::Config.logger.level = ENV['GLIMMER_LOGGER_LEVEL'].downcase
end
