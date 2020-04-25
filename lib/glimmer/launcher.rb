require 'os'

module Glimmer
  class Launcher
    OPERATING_SYSTEMS_SUPPORTED = ["mac", "windows", "linux"]
    TEXT_USAGE = <<-MULTILINE
  Usage: glimmer [--log-level=VALUE] [[ENV_VAR=VALUE]...] [[-jruby-option]...] application.rb [[application2.rb]...]

  Runs Glimmer applications using JRuby, automatically preloading
  the glimmer ruby gem and SWT jar dependency.

  Optionally, JRuby options may be passed in.

  Example: glimmer samples/hello_world.rb
  This runs the Glimmer application samples/hello_world.rb
    MULTILINE
    GLIMMER_LIB_LOCAL = File.expand_path(File.join(__FILE__, '..', '..', 'glimmer.rb'))
    GLIMMER_LIB_GEM = 'glimmer'
    GLIMMER_OPTIONS = %w[--log-level]
    GLIMMER_OPTION_ENV_VAR_MAPPING = {
      '--log-level' => 'GLIMMER_LOGGER_LEVEL'
    }

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

      def glimmer_option_env_vars(glimmer_options)
        glimmer_options.map do |k, v|
          "#{GLIMMER_OPTION_ENV_VAR_MAPPING[k]}=#{v}"
        end.join(' ')
      end

      def launch(application, jruby_options: [], env_vars: {}, glimmer_options: {})
        jruby_options_string = jruby_options.join(' ') + ' ' if jruby_options.any?
        env_vars_string = env_vars.map {|k,v| "#{k}=#{v}"}.join(' ')
        env_vars_string = [env_vars_string, glimmer_option_env_vars(glimmer_options)].join(' ')
        the_glimmer_lib = glimmer_lib
        devmode_require = nil
        if the_glimmer_lib == GLIMMER_LIB_LOCAL
          devmode_require = '-r puts_debuggerer '
        end
        puts "#{env_vars_string} jruby #{jruby_options_string}#{jruby_os_specific_options} #{devmode_require}-r #{the_glimmer_lib} -S #{application}" if jruby_options_string.to_s.include?('--debug')
        system "#{env_vars_string} jruby #{jruby_options_string}#{jruby_os_specific_options} #{devmode_require}-r #{the_glimmer_lib} -S #{application}"
      end
    end

    def initialize(raw_options)
      @application_paths = extract_application_paths(raw_options)
      @env_vars = extract_env_vars(raw_options)
      @glimmer_options = extract_glimmer_options(raw_options)
      @jruby_options = raw_options
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
        puts "Launching Glimmer Application: #{application_path}" unless application_path.to_s.match(/(irb)|(gladiator)/)
        Thread.new do
          self.class.launch(
            application_path,
            jruby_options: @jruby_options,
            env_vars: @env_vars,
            glimmer_options: @glimmer_options
          )
        end
      end
      threads.each(&:join)
    end

    def display_usage
      puts TEXT_USAGE
    end

    def extract_application_paths(options)
      options.select do |option|
        !option.start_with?('-') && !option.include?('=')
      end.each do |application_path|
        options.delete(application_path)
      end
    end

    def extract_env_vars(options)
      options.select do |option|
        !option.start_with?('-') && option.include?('=')
      end.each do |env_var|
        options.delete(env_var)
      end.reduce({}) do |hash, env_var_string|
        match = env_var_string.match(/^([^=]+)=(.+)$/)
        hash.merge(match[1] => match[2])
      end
    end

    def extract_glimmer_options(options)
      options.select do |option|
        GLIMMER_OPTIONS.reduce(false) do |result, glimmer_option|
          result || option.include?(glimmer_option)
        end
      end.each do |glimmer_option|
        options.delete(glimmer_option)
      end.reduce({}) do |hash, glimmer_option_string|
        match = glimmer_option_string.match(/^([^=]+)=?(.*)$/)
        hash.merge(match[1] => match[2])
      end
    end
  end
end
