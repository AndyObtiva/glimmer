require 'os'

module Glimmer
  class Launcher
    OPERATING_SYSTEMS_SUPPORTED = ["mac", "windows", "linux"]
    TEXT_USAGE = <<-MULTILINE
  Usage: glimmer application.rb

  Runs a Glimmer application using JRuby, automatically preloading
  the glimmer ruby gem and SWT jar dependency.

  Example: glimmer hello_world.rb
  This runs the Glimmer application hello_world.rb
    MULTILINE
    GLIMMER_LIB_LOCAL = File.expand_path(File.join(__FILE__, '..', '..', 'glimmer.rb'))
    GLIMMER_LIB_GEM = 'glimmer'

    class << self
      def platform_os
        OPERATING_SYSTEMS_SUPPORTED.detect {|os| OS.send("#{os}?")}
      end

      def swt_jar_file
        @swt_jar_file ||= File.expand_path(File.join(__FILE__, '..', '..', '..', 'vendor', 'swt', platform_os, 'swt.jar'))
      end

      def jruby_os_specific_options
        OS.mac? ? "-J-XstartOnFirstThread" : ""
      end

      def jruby_command_options
        "#{jruby_os_specific_options} -J-classpath \"#{swt_jar_file}\""
      end

      def launch(application, dev_mode = false)
        glimmer_lib = GLIMMER_LIB_GEM
        if dev_mode
          glimmer_lib = GLIMMER_LIB_LOCAL
          puts "[DEVELOPMENT MODE] (#{glimmer_lib})"
        end
        system "jruby #{jruby_command_options} -r #{glimmer_lib} -S #{application}"
      end
    end

    def initialize(options)
      @dev_mode = !!options.delete('--dev')
      @application_path = options.first
    end

    def launch
      if @application_path
        launch_application
      else
        display_usage
      end
    end

    private

    def launch_application
      puts "Launching Glimmer Application: #{@application_path}" unless @application_path == 'irb'
      self.class.launch(@application_path, @dev_mode)
    end

    def display_usage
      puts TEXT_USAGE
    end
  end
end
