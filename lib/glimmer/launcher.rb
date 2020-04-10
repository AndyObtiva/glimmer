require 'os'

module Glimmer
  class Launcher
    OPERATING_SYSTEMS_SUPPORTED = ["mac", "windows", "linux"]
    TEXT_USAGE = <<-MULTILINE
  Usage: glimmer [[-jruby-option]...] application.rb [[application2.rb]...]

  Runs Glimmer applications using JRuby, automatically preloading
  the glimmer ruby gem and SWT jar dependency.

  Optionally, JRuby options may be passed in.

  Example: glimmer samples/hello_world.rb
  This runs the Glimmer application samples/hello_world.rb
    MULTILINE
    GLIMMER_LIB_LOCAL = File.expand_path(File.join(__FILE__, '..', '..', 'glimmer.rb'))
    GLIMMER_LIB_GEM = 'glimmer'

    @@mutex = Mutex.new

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

      def jruby_swt_options
        "#{jruby_os_specific_options} -J-classpath \"#{swt_jar_file}\""
      end

      def glimmer_lib
        @@mutex.synchronize do
          unless @glimmer_lib
            @glimmer_lib = GLIMMER_LIB_GEM
            glimmer_gem_listing = `jgem list #{GLIMMER_LIB_GEM}`
            if !glimmer_gem_listing.include?(GLIMMER_LIB_GEM) && File.exists?(GLIMMER_LIB_LOCAL)
              @glimmer_lib = GLIMMER_LIB_LOCAL
              puts "[DEVELOPMENT MODE] (detected #{@glimmer_lib})"
            end
          end
        end
        @glimmer_lib
      end

      def launch(application, options = [])
        options_string = options.join(' ') + ' ' if options.any?
        system "jruby #{options_string}#{jruby_swt_options} -r #{glimmer_lib} -S #{application}"
      end
    end

    def initialize(options)
      @application_paths = options.select {|option| !option.start_with?('-')}
      @application_paths.each do |application_path|
        options.delete(application_path)
      end
      @options = options
    end

    def launch
      if @application_paths.empty?
        display_usage
      else
        launch_application
      end
    end

    private

    def launch_application
      threads = @application_paths.map do |application_path|
        puts "Launching Glimmer Application: #{application_path}" unless application_path.to_s.include?('irb')
        Thread.new do
          self.class.launch(application_path, @options)
        end
      end
      threads.each(&:join)
    end

    def display_usage
      puts TEXT_USAGE
    end
  end
end
