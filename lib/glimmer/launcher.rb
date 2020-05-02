require 'os'
require 'rake'

require_relative 'rake_task'

module Glimmer
  class Launcher
    OPERATING_SYSTEMS_SUPPORTED = ["mac", "windows", "linux"]
    
    TEXT_USAGE_PREFIX = <<~MULTI_LINE_STRING
      Usage: glimmer [--debug] [--log-level=VALUE] [[ENV_VAR=VALUE]...] [[-jruby-option]...] (application.rb or task[task_args]) [[application2.rb]...]
    
      Runs Glimmer applications/tasks.
    
      Either a single task or one or more applications may be specified.
    
      When a task is specified, it runs via rake. Some tasks take arguments in square brackets.
    
      Available tasks are below (you may also lookup by adding `require 'glimmer/rake_task'` in Rakefile and running rake -T):
    MULTI_LINE_STRING

    TEXT_USAGE_SUFFIX = <<~MULTI_LINE_STRING
    
      When applications are specified, they are run using JRuby, 
      automatically preloading the glimmer Ruby gem and SWT jar dependency.
    
      Optionally, extra Glimmer options, JRuby options and environment variables may be passed in.
    
      Glimmer options:
      - "--debug"           : Displays extra debugging information and passes "--debug" to JRuby
      - "--log-level=VALUE" : Sets Glimmer's Ruby logger level ("ERROR" / "WARN" / "INFO" / "DEBUG"; default is "WARN")
    
      Example: glimmer samples/hello_world.rb
    
      This runs the Glimmer application samples/hello_world.rb
    MULTI_LINE_STRING

    GLIMMER_LIB_LOCAL = File.expand_path(File.join(__FILE__, '..', '..', 'glimmer.rb'))
    GLIMMER_LIB_GEM = 'glimmer'
    GLIMMER_OPTIONS = %w[--log-level]
    GLIMMER_OPTION_ENV_VAR_MAPPING = {
      '--log-level' => 'GLIMMER_LOGGER_LEVEL'
    }
    REGEX_RAKE_TASK_WITH_ARGS = /^([^\[]+)\[?([^\]]*)\]?$/

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
        glimmer_options.reduce({}) do |hash, pair|
          hash.merge(GLIMMER_OPTION_ENV_VAR_MAPPING[pair.first] => pair.last)
        end
      end

      def load_env_vars(env_vars)
        env_vars.each do |key, value|
          ENV[key] = value
        end
      end

      def launch(application, jruby_options: [], env_vars: {}, glimmer_options: {})
        jruby_options_string = jruby_options.join(' ') + ' ' if jruby_options.any?
        env_vars = env_vars.merge(glimmer_option_env_vars(glimmer_options))
        env_vars_string = env_vars.map {|k,v| "#{k}=#{v}"}.join(' ')
        the_glimmer_lib = glimmer_lib
        devmode_require = nil
        if the_glimmer_lib == GLIMMER_LIB_LOCAL
          devmode_require = '-r puts_debuggerer '
        end
        rake_tasks = Rake.application.tasks.map(&:to_s).map {|t| t.sub('glimmer:', '')}
        potential_rake_task_parts = application.match(REGEX_RAKE_TASK_WITH_ARGS)
        application = potential_rake_task_parts[1]
        rake_task_args = potential_rake_task_parts[2].split(',')
        if rake_tasks.include?(application)
          load_env_vars(glimmer_option_env_vars(glimmer_options))
          rake_task = "glimmer:#{application}"
          puts "Running Glimmer rake task: #{rake_task}" if jruby_options_string.to_s.include?('--debug')
          Rake::Task[rake_task].invoke(*rake_task_args)
        else
          @@mutex.synchronize do
            puts "Launching Glimmer Application: #{application}" unless application.to_s.match(/(irb)|(gladiator)/)
          end
          command = "#{env_vars_string} jruby #{jruby_options_string}#{jruby_os_specific_options} #{devmode_require}-r #{the_glimmer_lib} -S #{application}"
          puts command if jruby_options_string.to_s.include?('--debug')
          system command
        end
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
      rake_tasks = `rake -T`.gsub('rake glimmer:', 'glimmer ').split("\n").select {|l| l.start_with?('glimmer ')}
      puts TEXT_USAGE_PREFIX
      puts rake_tasks.join("\n")
      puts TEXT_USAGE_SUFFIX
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
