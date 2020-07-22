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
        @@logger if defined? @@logger
      end
  
      def enable_logging
#       , async: true
        @@logger = Logging.logger(STDOUT).tap {|logger| logger.level = :warn}
      end
    end
  end
end

if ENV['GLIMMER_LOGGER_LEVEL']
  Glimmer::Config.enable_logging
  Glimmer::Config.logger.level = ENV['GLIMMER_LOGGER_LEVEL'].downcase
end
