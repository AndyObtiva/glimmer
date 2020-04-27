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
            line = line.sub('# ', '').sub(/=[^=\n]+$/, '= %w(app config db lib script bin docs fonts images sounds videos)')
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
    version_file = File.expand_path('./VERSION')
    version = (File.read(version_file).strip if File.exists?(version_file) && File.file?(version_file)) rescue nil
    license_file = File.expand_path('./LICENSE.txt')
    license = (File.read(license_file).strip if File.exists?(license_file) && File.file?(license_file)) rescue nil
    human_name = project_name.underscore.titlecase
    system('mkdir -p dist')
    puts "Generating JAR with Warbler..."
    system('warble')
    command = "javapackager -deploy -native -outdir packages -outfile \"#{project_name}\" -srcfiles \"dist/#{project_name}.jar\" -appclass JarMain -name \"#{human_name}\" -title \"#{human_name}\" -BjvmOptions=-XstartOnFirstThread -Bmac.CFBundleName=\"#{human_name}\" -Bmac.CFBundleIdentifier=\"org.#{project_name}.application.#{project_name}\" "
    command += " -BappVersion=#{version} -Bmac.CFBundleVersion=#{version} " if version
    command += " -srcfiles LICENSE.txt -BlicenseFile=LICENSE.txt " if license
    command += " #{Glimmer::Package.javapackager_extra_args} " if Glimmer::Package.javapackager_extra_args
    command += " #{ENV['JAVAPACKAGER_EXTRA_ARGS']} " if ENV['JAVAPACKAGER_EXTRA_ARGS']
    puts "Generating DMG/PKG/APP/JNLP with javapackager..."
    puts command
    system command
  end
end
