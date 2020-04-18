require 'glimmer/package'

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
            line = line.sub('# ', '').sub(/=[^=\n]+$/, '= %w(app config db lib script bin images sounds videos)')
          end
          if line.include?('config.autodeploy_dir =')
            line = line.sub('# ', '')
          end
          output + "\n" + line
        end
        File.write('config/warble.rb', new_config)
      end
    end
  end

  desc 'Package app for distribution'
  task :package => 'package:config' do
    require 'facets/string/titlecase'
    require 'facets/string/underscore'
    project_name = File.basename(File.expand_path('.'))
    human_name = project_name.underscore.titlecase
    system('mkdir -p dist')
    puts "Generating JAR with Warbler..."
    system('warble')
    command = "javapackager -deploy -native -outdir packages -outfile #{project_name} -srcfiles \"dist/#{project_name}.jar\" -appclass JarMain -name \"#{project_name}\" -title \"#{human_name}\" -BjvmOptions=-XstartOnFirstThread"
    command += " -Bmac.CFBundleName=\"#{human_name}\""
    command += " #{Glimmer::Package.javapackager_extra_args}" if Glimmer::Package.javapackager_extra_args
    command += " #{ENV['JAVAPACKAGER_EXTRA_ARGS']}" if ENV['JAVAPACKAGER_EXTRA_ARGS']
    puts "Generating DMG/PKG/APP/JNLP with javapackager..."
    puts command
    system command
  end
end
