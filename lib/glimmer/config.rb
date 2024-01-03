# Copyright (c) 2007-2024 Andy Maleh
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

module Glimmer
  module Config
    class << self
      LOOP_MAX_COUNT_DEFAULT = 100
      REGEX_METHODS_EXCLUDED = /^(to_|\[|load_iseq)/
      
      attr_writer :loop_max_count
      attr_accessor :log_excluded_keywords
      alias log_excluded_keywords? log_excluded_keywords
      
      def excluded_keyword_checkers
        @excluded_keyword_checkers ||= reset_excluded_keyword_checkers!
      end
      
      def excluded_keyword_checkers=(checkers)
        @excluded_keyword_checkers = checkers
      end
      
      def reset_excluded_keyword_checkers!
        @excluded_keyword_checkers = [ lambda { |method_symbol, *args| method_symbol.to_s.match(REGEX_METHODS_EXCLUDED) } ]
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
        self.logger = Logger.new($stdout).tap do |logger|
          logger.level = Logger::ERROR
          begin
            logger.level = ENV['GLIMMER_LOGGER_LEVEL'].strip.downcase unless ENV['GLIMMER_LOGGER_LEVEL'].to_s.strip.empty?
          rescue => e
            puts e.message
          end
        end
      end
    end
  end
end
