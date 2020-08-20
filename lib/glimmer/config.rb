module Glimmer
  module Config
    class << self
      LOOP_MAX_COUNT_DEFAULT = 100
      REGEX_METHODS_EXCLUDED = /^(to_|\[)/
      
      attr_writer :loop_max_count
      
      def excluded_keyword_checkers
        @excluded_keyword_checkers ||= reset_excluded_keyword_checkers!
      end
      
      def excluded_keyword_checkers=(checkers)
        @excluded_keyword_checkers = checkers
      end
      
      def reset_excluded_keyword_checkers!
        @excluded_keyword_checkers = [
          lambda { |method_symbol, *args| method_symbol.to_s.match(REGEX_METHODS_EXCLUDED) }
        ]
      end
      
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
          logger.level = ENV['GLIMMER_LOGGER_LEVEL'] ? ENV['GLIMMER_LOGGER_LEVEL'].downcase : Logger::ERROR
        end
      end
    end
  end
end
