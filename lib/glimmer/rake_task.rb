require 'rake'

require_relative 'package'
require_relative 'scaffold'

namespace :glimmer do
  namespace :package do
    desc 'Generate JAR config file'
    task :config do
      project_name = File.basename(File.expand_path('.'))
      if !File.exists?('config/warble.rb')
        puts 'Generating JAR configuration (config/warble.rb) to use with Warbler...'
        system('mkdir -p config')
        system('warble config')
        new_config = File.read('config/warble.rb').split("\n").inject('') do |output, line|
          if line.include?('config.dirs =')
            line = line.sub('# ', '').sub(/=[^=\n]+$/, '= %w(app config db lib script bin docs fonts icons images sounds videos)')
          end
          if line.include?('config.includes =')
            line = line.sub('# ', '').sub(/=[^=\n]+$/, "= FileList['LICENSE.txt', 'VERSION']")
          end
          if line.include?('config.autodeploy_dir =')
            line = line.sub('# ', '')
          end
          output + "\n" + line
        end
        File.write('config/warble.rb', new_config)
      end
    end

    desc 'Generate JAR file'
    task :jar => 'package:config' do
      system('mkdir -p dist')
      puts "Generating JAR with Warbler..."
      system('warble')
    end

    desc 'Generate Native files (DMG/PKG/APP on the Mac)'
    task :native => 'package:jar' do
      require 'facets/string/titlecase'
      require 'facets/string/underscore'
      project_name = File.basename(File.expand_path('.'))
      version_file = File.expand_path('./VERSION')
      version = (File.read(version_file).strip if File.exists?(version_file) && File.file?(version_file)) rescue nil
      license_file = File.expand_path('./LICENSE.txt')
      license = (File.read(license_file).strip if File.exists?(license_file) && File.file?(license_file)) rescue nil
      human_name = project_name.underscore.titlecase
      command = "javapackager -deploy -native -outdir packages -outfile \"#{project_name}\" -srcfiles \"dist/#{project_name}.jar\" -appclass JarMain -name \"#{human_name}\" -title \"#{human_name}\" -BjvmOptions=-XstartOnFirstThread -Bmac.CFBundleName=\"#{human_name}\" -Bmac.CFBundleIdentifier=\"org.#{project_name}.application.#{project_name}\" -Bmac.category=\"public.app-category.business\" "
      command += " -BappVersion=#{version} -Bmac.CFBundleVersion=#{version} " if version
      command += " -srcfiles LICENSE.txt -BlicenseFile=LICENSE.txt " if license
      command += " #{Glimmer::Package.javapackager_extra_args} " if Glimmer::Package.javapackager_extra_args
      command += " #{ENV['JAVAPACKAGER_EXTRA_ARGS']} " if ENV['JAVAPACKAGER_EXTRA_ARGS']
      puts "Generating DMG/PKG/APP/JNLP with javapackager..."
      puts command
      system command
    end
  end

  desc 'Package app for distribution (generating config, jar, and native files)'
  task :package => 'package:native'


  desc 'Scaffold a Glimmer application directory structure to begin building a new app'
  task :scaffold, [:app_name] do |t, args|
    Scaffold.app(args[:app_name])
  end

  namespace :scaffold do
    desc 'Scaffold a Glimmer::UI::CustomShell subclass (represents a full window view) under app/views (namespace is optional)'
    task :custom_shell, [:custom_shell_name, :namespace] do |t, args|
      Scaffold.custom_shell(args[:custom_shell_name], args[:namespace])
    end
    
    desc 'Scaffold a Glimmer::UI::CustomWidget subclass (represents a part of a view) under app/views (namespace is optional)'
    task :custom_widget, [:custom_widget_name, :namespace] do |t, args|
      Scaffold.custom_widget(args[:custom_widget_name], args[:namespace])
    end
    
    desc 'Scaffold a Glimmer::UI::CustomWidget subclass (represents a part of a view) under its own Ruby gem project (namespace is optional)'
    task :custom_widget_gem, [:custom_widget_name, :namespace] do |t, args|
      Scaffold.custom_widget_gem(args[:custom_widget_name], args[:namespace])
    end
  end
end
