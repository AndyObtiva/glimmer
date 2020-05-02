require 'fileutils'
require 'os'
require 'facets'

class Scaffold
  class << self
    include FileUtils

    VERSION = File.read(File.expand_path('../../../VERSION', __FILE__)).strip
    RUBY_VERSION = File.read(File.expand_path('../../../RUBY_VERSION', __FILE__)).strip

    GEMFILE = <<~MULTI_LINE_STRING
      # frozen_string_literal: true
      
      source "https://rubygems.org"
      
      git_source(:github) {|repo_name| "https://github.com/\#{repo_name}" }
      
      gem 'glimmer', '#{VERSION}'
      
      group :test do
        gem 'rspec'
      end
    MULTI_LINE_STRING

    RAKEFILE = <<~MULTI_LINE_STRING
      require 'glimmer/rake_task'
      
      ## Uncomment the following section if you would like to customize javapackager
      ## arguments for `glimmer package` command.
      #
      # Glimmer::Package.javapackager_extra_args =
      #   " -BlicenseType=" +
      #   " -Bmac.CFBundleIdentifier=" +
      #   " -Bmac.category=" +
      #   " -Bmac.signing-key-developer-id-app="
    MULTI_LINE_STRING

    RVM_FUNCTION = <<~MULTI_LINE_STRING
      # Load RVM into a shell session *as a function*
      if [[ -s "$HOME/.rvm/scripts/rvm" ]] ; then
      
        # First try to load from a user install
        source "$HOME/.rvm/scripts/rvm"
      
      elif [[ -s "/usr/local/rvm/scripts/rvm" ]] ; then
      
        # Then try to load from a root install
        source "/usr/local/rvm/scripts/rvm"
      
      fi
    MULTI_LINE_STRING

    def app(app_name)
      mkdir app_name
      cd app_name
      write '.ruby-version', RUBY_VERSION        
      write '.ruby-gemset', app_name
      write 'VERSION', '1.0.0'
      write 'LICENSE.txt', "Copyright (c) #{Time.now.year} #{app_name}"
      write 'Gemfile', GEMFILE
      write 'Rakefile', RAKEFILE
      mkdir 'app'
      write "app/#{file_name(app_name)}.rb", app_main_file(app_name)
      mkdir 'app/models'
      mkdir 'app/views'
      custom_shell('AppView')
      if OS.mac?
        mkdir_p 'package/macosx'
        icon_file = "package/macosx/#{human_name(app_name)}.icns"
        cp File.expand_path('../../../icons/scaffold_app.icns', __FILE__), icon_file
        puts "Created #{app_dir}/#{icon_file}"
      end
      mkdir 'bin'
      write "bin/#{file_name(app_name)}", app_bin_file(app_name)
      FileUtils.chmod 0755, "bin/#{app_name.underscore}"
      system "bash -c '#{RVM_FUNCTION}\n cd .\n bundle\n glimmer package\n'"
      system "open packages/bundles/#{human_name(app_name).gsub(' ', '\ ')}.app"
    end

    def custom_shell(custom_shell_name)
      write "app/views/#{file_name(custom_shell_name)}.rb", custom_shell_file(custom_shell_name)
    end

    private

    def write(file, content)
      File.write file, content
      file_path = File.expand_path(file)
      puts "Created #{app_dir}/#{file}"
    end

    def app_dir
      File.basename(File.expand_path('.'))
    end

    def class_name(app_name)
      app_name.camelcase(:upper)
    end

    def file_name(app_name)
      app_name.underscore
    end

    def human_name(app_name)
      app_name.underscore.titlecase
    end

    def app_main_file(app_name)
      <<~MULTI_LINE_STRING
        $LOAD_PATH.unshift(File.expand_path('..', __FILE__))
        
        require 'glimmer'
        require 'views/app_view'

        class #{class_name(app_name)}
          include Glimmer
        
          APP_ROOT = File.expand_path('../..', __FILE__)        
          VERSION = File.read(File.expand_path('VERSION', APP_ROOT))
                    
          def open
            app_view.open
          end
        end
        
        #{class_name(app_name)}.new.open
      MULTI_LINE_STRING
    end

    def app_bin_file(app_name)
      <<~MULTI_LINE_STRING
        #!/usr/bin/env ruby

        require_relative '../app/#{file_name(app_name)}'
      MULTI_LINE_STRING
    end

    def custom_shell_file(custom_shell_name)
      <<~MULTI_LINE_STRING
        class #{class_name(app_dir)}
          class #{class_name(custom_shell_name)}
            include Glimmer::UI::CustomShell
        
            ## Add options like these to configure CustomShell by outside consumers
            #
            # options :title, :background_color
            # option :width, 320
            # option :height, 240
        
            ## Uncomment before_body block to pre-initialize variables to use in body
            #
            #
            # before_body {
            # 
            # }
        
            ## Uncomment after_body block to setup observers for widgets in body
            #
            # after_body {
            # 
            # }
        
            ## Add custom widget content under body shell
            #
            body {
              shell {
                # add custom widget content
                minimum_size 320, 240
                text "#{human_name(app_dir)}"
                grid_layout
                label(:center) {
                  text "Hello, World!"
                  font height: 40
                  layout_data :center, :center, true, true
                }
              }
            }
        
          end
        end        
      MULTI_LINE_STRING
    end
  end
end
