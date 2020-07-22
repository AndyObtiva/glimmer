require 'spec_helper'

module GlimmerSpec
  describe Glimmer::Config do
    include Glimmer
    
    describe '::logger' do
      after do
        described_class.reset_logger!
      end
      
      it 'returns a default logger instance' do
        logger = described_class.logger
        
        expect(logger).to be_a(::Logger)
        expect(logger.level).to eq(Logger::ERROR)
        expect(logger.formatter).to be_nil
      end
      
      it 'accepts a custom logger' do
        custom_logger = ::Logger.new(STDOUT)
        custom_logger.level = :warn
        custom_formatter = Logger::Formatter.new
        custom_logger.formatter = custom_formatter
        logger = described_class.logger = custom_logger
        
        expect(logger).to eq(custom_logger)
        expect(logger.level).to eq(Logger::WARN)
        expect(logger.formatter).to eq(custom_formatter)
      end
    end
    
    describe '::loop_max_count' do
      after do
        Glimmer.loop_reset!(true)
      end
    
      it 'raises an error if default loop max count is reached' do
        expect do
          html {
            described_class.loop_max_count.times {
              input(type: 'text', value: 'Hello, World!')
            }
          }
        end.to raise_error("Glimmer looped #{described_class.loop_max_count} times with keyword 'input'! Check code for errors.")
      end
      
      it 'does not raise an error if default loop max count is not reached' do
        expect do
          html {
            (described_class.loop_max_count - 1).times {
              input(type: 'text', value: 'Hello, World!')
            }
          }
        end.to_not raise_error
      end
      
      it 'does not raise an error if keyword args vary even if default loop max count is reached' do
        expect do
          html {
            described_class.loop_max_count.times { |i|
              input(type: 'text', value: "Hello, World! #{i}")
            }
          }
        end.to_not raise_error
      end
      
      it 'raises an error if custom loop max count is reached' do
        described_class.loop_max_count = 3
      
        expect do
          html {
            described_class.loop_max_count.times {
              input(type: 'text', value: 'Hello, World!')
            }
          }
        end.to raise_error("Glimmer looped 3 times with keyword 'input'! Check code for errors.")
      end
      
      it 'raises no error if loop max count is disabled by setting to -1' do
        described_class.loop_max_count = -1
      
        expect do
          html {
            described_class.loop_max_count.times {
              input(type: 'text', value: 'Hello, World!')
            }
          }
        end.to_not raise_error
      end
    end    
  end
end
