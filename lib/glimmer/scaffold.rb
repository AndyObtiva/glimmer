require 'fileutils'
require 'os'
require 'facets'

class Scaffold
  class << self
    include FileUtils

    VERSION = File.read(File.expand_path('../../../VERSION', __FILE__)).strip
    RUBY_VERSION = File.read(File.expand_path('../../../RUBY_VERSION', __FILE__)).strip

    # TODO externalize all constants into scaffold/files

    GITIGNORE = <<~MULTI_LINE_STRING
      *.gem
      *.rbc
      /.config
      /coverage/
      /InstalledFiles
      /pkg/
      /spec/reports/
      /spec/examples.txt
      /test/tmp/
      /test/version_tmp/
      /tmp/
      
      # Used by dotenv library to load environment variables.
      # .env
      
      ## Specific to RubyMotion:
      .dat*
      .repl_history
      build/
      *.bridgesupport
      build-iPhoneOS/
      build-iPhoneSimulator/
      
      ## Specific to RubyMotion (use of CocoaPods):
      #
      # We recommend against adding the Pods directory to your .gitignore. However
      # you should judge for yourself, the pros and cons are mentioned at:
      # https://guides.cocoapods.org/using/using-cocoapods.html#should-i-check-the-pods-directory-into-source-control
      #
      # vendor/Pods/
      
      ## Documentation cache and generated files:
      /.yardoc/
      /_yardoc/
      /doc/
      /rdoc/
      
      ## Environment normalization:
      /.bundle/
      /vendor/bundle
      /lib/bundler/man/
      
      # for a library or gem, you might want to ignore these files since the code is
      # intended to run in multiple environments; otherwise, check them in:
      Gemfile.lock
      # .ruby-version
      # .ruby-gemset
      
      # unless supporting rvm < 1.11.0 or doing something fancy, ignore this:
      .rvmrc
      
      # Mac
      .DS_Store
      
      # Gladiator (Glimmer Editor)
      .gladiator
      
      # Glimmer
      dist
      packages      
    MULTI_LINE_STRING

    GEMFILE_APP = <<~MULTI_LINE_STRING
      # frozen_string_literal: true
      
      source 'https://rubygems.org'
      
      git_source(:github) {|repo_name| "https://github.com/\#{repo_name}" }
      
      gem 'glimmer', '~> #{VERSION}'
      
      group :test do
        gem 'rspec'
      end
    MULTI_LINE_STRING

    GEMFILE_GEM = <<~MULTI_LINE_STRING
      # frozen_string_literal: true
      
      source 'https://rubygems.org'
      
      git_source(:github) {|repo_name| "https://github.com/\#{repo_name}" }
      
      gem 'glimmer', '~> #{VERSION}'
      
      group :development do
        gem 'rspec', '~> 3.5.0'
        gem 'jeweler', '2.3.9'
        gem 'simplecov', '>= 0'
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
      write '.gitignore', GITIGNORE
      write '.ruby-version', RUBY_VERSION        
      write '.ruby-gemset', app_name
      write 'VERSION', '1.0.0'
      write 'LICENSE.txt', "Copyright (c) #{Time.now.year} #{app_name}"
      write 'Gemfile', GEMFILE_APP
      write 'Rakefile', RAKEFILE
      mkdir 'app'
      write "app/#{file_name(app_name)}.rb", app_main_file(app_name)
      mkdir 'app/models'
      mkdir 'app/views'
      custom_shell('AppView', current_dir_name)
      if OS.mac?
        mkdir_p 'package/macosx'
        icon_file = "package/macosx/#{human_name(app_name)}.icns"
        cp File.expand_path('../../../icons/scaffold_app.icns', __FILE__), icon_file
        puts "Created #{current_dir_name}/#{icon_file}"
      end
      mkdir 'bin'
      write "bin/#{file_name(app_name)}", app_bin_file(app_name)
      FileUtils.chmod 0755, "bin/#{file_name(app_name)}"
      system "bash -c '#{RVM_FUNCTION}\n cd .\n bundle\n glimmer package\n'"
      system "open packages/bundles/#{human_name(app_name).gsub(' ', '\ ')}.app"
      # TODO generate rspec test suite
    end

    def custom_shell(custom_shell_name, namespace)
      namespace ||= current_dir_name
      root_dir = File.exists?('app') ? 'app' : 'lib'
      parent_dir = "#{root_dir}/views/#{file_name(namespace)}"
      mkdir_p parent_dir unless File.exists?(parent_dir)
      write "#{parent_dir}/#{file_name(custom_shell_name)}.rb", custom_shell_file(custom_shell_name, namespace)
    end

    def custom_widget(custom_widget_name, namespace)
      namespace ||= current_dir_name
      root_dir = File.exists?('app') ? 'app' : 'lib'
      parent_dir = "#{root_dir}/views/#{file_name(namespace)}"
      mkdir_p parent_dir unless File.exists?(parent_dir)
      write "#{parent_dir}/#{file_name(custom_widget_name)}.rb", custom_widget_file(custom_widget_name, namespace)
    end

    def custom_shell_gem(custom_shell_name, namespace)
      gem_name = "glimmer-cs-#{compact_name(custom_shell_name)}"
      gem_summary = "#{human_name(custom_shell_name)} - Glimmer Custom Shell"
      if namespace
        gem_name += "-#{compact_name(namespace)}"
        gem_summary += " (#{human_name(namespace)})"
      else
        namespace = 'glimmer'
      end
      system "jeweler --rspec --summary '#{gem_summary}' --description '#{gem_summary}' #{gem_name}" 
      cd gem_name
      write '.gitignore', GITIGNORE
      write '.ruby-version', RUBY_VERSION        
      write '.ruby-gemset', gem_name
      write 'VERSION', '1.0.0'
      write 'Gemfile', GEMFILE_GEM      
      write 'Rakefile', gem_rakefile(custom_shell_name, namespace)
      append "lib/#{gem_name}.rb", gem_main_file(custom_shell_name, namespace)
      mkdir 'lib/views'
      custom_shell(custom_shell_name, namespace)
      mkdir 'bin'
      write "bin/#{file_name(custom_shell_name)}", gem_bin_file(gem_name, custom_shell_name, namespace)
      FileUtils.chmod 0755, "bin/#{file_name(custom_shell_name)}"      
      if OS.mac?
        mkdir_p 'package/macosx'
        icon_file = "package/macosx/#{human_name(custom_shell_name)}.icns"
        cp File.expand_path('../../../icons/scaffold_app.icns', __FILE__), icon_file
        puts "Created #{current_dir_name}/#{icon_file}"
      end
      system "bash -c '#{RVM_FUNCTION}\n cd .\n bundle\n glimmer package\n'"
      system "open packages/bundles/#{human_name(custom_shell_name).gsub(' ', '\ ')}.app"
      puts "Finished creating #{gem_name} Ruby gem."
      puts 'Edit Rakefile to configure gem details.'
      puts 'Run `rake` to execute specs.'
      puts 'Run `rake build` to build gem.'
      puts 'Run `rake release` to release into rubygems.org once ready.'
    end

    def custom_widget_gem(custom_widget_name, namespace)
      gem_name = "glimmer-cw-#{compact_name(custom_widget_name)}"
      gem_summary = "#{human_name(custom_widget_name)} - Glimmer Custom Widget"
      if namespace
        gem_name += "-#{compact_name(namespace)}"
        gem_summary += " (#{human_name(namespace)})"
      else
        namespace = 'glimmer'
      end
      system "jeweler --rspec --summary '#{gem_summary}' --description '#{gem_summary}' #{gem_name}" 
      cd gem_name
      write '.gitignore', GITIGNORE
      write '.ruby-version', RUBY_VERSION        
      write '.ruby-gemset', gem_name
      write 'VERSION', '1.0.0'
      write 'Gemfile', GEMFILE_GEM      
      write 'Rakefile', gem_rakefile
      write 'spec/spec_helper.rb', spec_helper_file
      append "lib/#{gem_name}.rb", gem_main_file(custom_widget_name, namespace)
      mkdir 'lib/views'
      custom_widget(custom_widget_name, namespace)
      system "bash -c '#{RVM_FUNCTION}\n cd .\n bundle\n'"
      puts "Finished creating #{gem_name} Ruby gem."
      puts 'Edit Rakefile to configure gem details.'
      puts 'Run `rake` to execute specs.'
      puts 'Run `rake build` to build gem.'
      puts 'Run `rake release` to release into rubygems.org once ready.'
    end

    private

    def write(file, content)
      File.write file, content
      file_path = File.expand_path(file)
      puts "Created #{current_dir_name}/#{file}"
    end

    def append(file, content)
      File.open(file, 'a') do |f|
        f.write(content)
      end
    end

    def current_dir_name
      File.basename(File.expand_path('.'))
    end

    def class_name(app_name)
      app_name.underscore.camelcase(:upper)
    end

    def file_name(app_name)
      app_name.underscore
    end
    alias dsl_widget_name file_name

    def human_name(app_name)
      app_name.underscore.titlecase
    end

    def compact_name(gem_name)
      gem_name.underscore.camelcase.downcase
    end

    def app_main_file(app_name)
      <<~MULTI_LINE_STRING
        $LOAD_PATH.unshift(File.expand_path('..', __FILE__))

        require 'bundler/setup'
        Bundler.require(:default)
        require 'views/#{file_name(app_name)}/app_view'

        class #{class_name(app_name)}
          include Glimmer
        
          APP_ROOT = File.expand_path('../..', __FILE__)        
          VERSION = File.read(File.expand_path('VERSION', APP_ROOT))
                    
          def open
            app_view.open
          end
        end
      MULTI_LINE_STRING
    end

    def gem_main_file(custom_widget_name, namespace = nil)
      custom_widget_file_path = "views"
      custom_widget_file_path += "/#{file_name(namespace)}" if namespace
      custom_widget_file_path += "/#{file_name(custom_widget_name)}"

      <<~MULTI_LINE_STRING
        $LOAD_PATH.unshift(File.expand_path('..', __FILE__))
        
        require 'glimmer'
        require '#{custom_widget_file_path}'
      MULTI_LINE_STRING
    end

    def app_bin_file(app_name)
      <<~MULTI_LINE_STRING
        #!/usr/bin/env ruby
        
        require_relative '../app/#{file_name(app_name)}'
        
        #{class_name(app_name)}.new.open
      MULTI_LINE_STRING
    end

    def gem_bin_file(gem_name, custom_shell_name, namespace)
      <<~MULTI_LINE_STRING
        #!/usr/bin/env ruby
        
        require_relative '../lib/#{gem_name}'
        
        include Glimmer
        
        #{dsl_widget_name(custom_shell_name)}.open
      MULTI_LINE_STRING
    end

    def gem_rakefile(custom_shell_name = nil, namespace = nil)
      rakefile_content = File.read('Rakefile')
      lines = rakefile_content.split("\n")
      require_rake_line_index = lines.index(lines.detect {|l| l.include?("require 'rake'") })
      lines.insert(require_rake_line_index, "require 'glimmer/launcher'")
      gem_files_line_index = lines.index(lines.detect {|l| l.include?('# dependencies defined in Gemfile') })
      lines.insert(gem_files_line_index, "  gem.files = Dir['lib/**/*.rb']")
      spec_pattern_line_index = lines.index(lines.detect {|l| l.include?('spec.pattern =') })
      lines.insert(spec_pattern_line_index+1, "  spec.ruby_opts = [Glimmer::Launcher.jruby_swt_options]")
      lines << "\nrequire 'glimmer/rake_task'\n"       
      file_content = lines.join("\n")
      if custom_shell_name
        file_content << <<~MULTI_LINE_STRING  
          Glimmer::Package.javapackager_extra_args =
            " -name '#{human_name(custom_shell_name)}'" +
            " -title '#{human_name(custom_shell_name)}'" +
            " -Bmac.CFBundleName='#{human_name(custom_shell_name)}'" +
            " -Bmac.CFBundleIdentifier='org.#{namespace ? compact_name(namespace) : compact_name(custom_shell_name)}.application.#{compact_name(custom_shell_name)}'" 
            # " -BlicenseType=" +
            # " -Bmac.category=" +
            # " -Bmac.signing-key-developer-id-app="
        MULTI_LINE_STRING
      end
      file_content
    end

    def spec_helper_file
      content = File.read('spec/spec_helper.rb')
      lines = content.split("\n")
      require_line_index = lines.index(lines.detect {|l| l.include?(current_dir_name) })
      lines[require_line_index...require_line_index] = [
        "require 'bundler/setup'",
        'Bundler.require(:default, :development)',
      ]
      configure_block_line_index = lines.index(lines.detect {|l| l.include?('RSpec.configure do') }) + 1
      lines[configure_block_line_index...configure_block_line_index] = [
        '  # The following ensures rspec tests that instantiate and set Glimmer DSL widgets in @target get cleaned after',
        '  config.after do',
        '    @target.dispose if @target && @target.respond_to?(:dispose)',
        '    Glimmer::DSL::Engine.reset',
        '  end',
      ]
      
      lines << "\nrequire 'glimmer/rake_task'\n"
      lines.join("\n")
    end

    def custom_shell_file(custom_shell_name, namespace)
      namespace_type = class_name(namespace) == class_name(current_dir_name) ? 'class' : 'module'

      <<~MULTI_LINE_STRING
        #{namespace_type} #{class_name(namespace)}
          class #{class_name(custom_shell_name)}
            include Glimmer::UI::CustomShell
        
            ## Add options like the following to configure CustomShell by outside consumers
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
        
            ## Add widget content inside custom shell body
            ## Top-most widget must be a shell or another custom shell
            #
            body {
              shell {
                # Replace example content below with custom shell content
                minimum_size 320, 240
                text "#{human_name(namespace)} - #{human_name(custom_shell_name)}"
                grid_layout
                label {
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

    def custom_widget_file(custom_widget_name, namespace)
      namespace_type = class_name(namespace) == class_name(current_dir_name) ? 'class' : 'module'

      <<~MULTI_LINE_STRING
        #{namespace_type} #{class_name(namespace)}
          class #{class_name(custom_widget_name)}
            include Glimmer::UI::CustomWidget
        
            ## Add options like the following to configure CustomWidget by outside consumers
            #
            # options :custom_text, :background_color
            # option :foreground_color, :red
        
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
        
            ## Add widget content under custom widget body
            ##
            ## If you want to add a shell as the top-most widget, 
            ## consider creating a custom shell instead 
            ## (Glimmer::UI::CustomShell offers shell convenience methods, like show and hide)
            #
            body {
              # Replace example content below with custom widget content
              label {
                background :red
              }
            }
        
          end
        end
      MULTI_LINE_STRING
    end
  end
end
