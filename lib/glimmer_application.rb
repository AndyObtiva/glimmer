require 'net/http'
require 'fileutils'
require 'os'
require 'yaml'

class GlimmerApplication
  SWT_ZIP_FILE = File.join(`echo ~`.strip, '.glimmer', 'vendor', 'swt.zip')
  SWT_JAR_FILE = File.join(File.dirname(SWT_ZIP_FILE), 'swt.jar')

  OPERATING_SYSTEMS = ["mac", "windows", "linux"]
  REGEX_SWT_VERSION = /^[0-9]+(\.[0-9]+)*$/

  attr_reader :setup_requested, :swt_version_specified, :application
  alias :setup_requested? :setup_requested

  # Accepts the following options string:
  # --setup app_file_path.rb
  # or
  # --setup
  # or
  # app_file_path.rb
  def initialize(options)
    application_option_index = 0
    (@setup_requested = (options[0] == '--setup')).yield_self {|present| present && application_option_index+=1}
    (@swt_version_specified = options[1] && options[1].match(REGEX_SWT_VERSION)[0]).yield_self {|present| present && application_option_index+=1}
    @application = options[application_option_index]
  end

  def start
    usage unless setup_requested? || application

    setup if setup_requested? || !File.exist?(SWT_JAR_FILE)

    if application
      puts "Starting Glimmer Application #{application}"
      system "ruby #{additional_options} -J-classpath \"#{SWT_JAR_FILE}\" #{application}"
    end
  end

  def usage
    puts <<-MULTILINE
Usage: glimmer [--setup] [application_ruby_file_path.rb]

Example 1: glimmer hello_combo.rb
This runs the Glimmer application hello_combo.rb
If the SWT Jar is missing, it downloads it and sets it up first.

Example 2: glimmer --setup hello_combo.rb
This performs setup and then runs the Glimmer application hello_combo.rb
It downloads and sets up the SWT jar whether missing or not.

Example 3: glimmer --setup
This downloads and sets up the SWT jar whether missing or not.
    MULTILINE
  end

  def setup
    puts "#{SWT_JAR_FILE} is missing! Will obtain a new copy now." unless File.exist?(SWT_JAR_FILE)
    FileUtils.mkdir_p(File.dirname(SWT_ZIP_FILE))
    download(SWT_ZIP_FILE)
    puts "Unzipping #{SWT_ZIP_FILE}"
    `unzip -o #{SWT_ZIP_FILE} -d #{File.dirname(SWT_ZIP_FILE)}`
    puts "Finished unzipping"
  end

  def download(file)
    uri = URI(platform_swt_url)
    puts "Downloading #{uri}"
    File.open(file, 'w') do |f|
      f.write(Net::HTTP.get(uri))
    end
    puts "Finished downloading"
  end

  def platform_swt_url
    require 'puts_debuggerer'
    swt_config[swt_version][platform_swt_url_key]
  rescue
    puts "SWT version #{swt_version_specified} is not available!" if swt_version_specified
  end

  def swt_config
    @swt_config ||= YAML.load_file(File.join(__FILE__, '..', '..', 'config', 'swt.yml'))['SWT']
  end

  def swt_version
    swt_version_specified || swt_latest_version
  end

  def swt_latest_version
    @swt_latest_version ||= swt_config.keys.max_by {|v| v.split('.').reverse.map(&:to_i).each_with_index.map {|n, i| n*(1000**i)}.sum}
  end

  def platform_swt_url_key
    "#{platform_os}_#{platform_cpu}"
  end

  def platform_os
    OPERATING_SYSTEMS.detect {|os| OS.send("#{os}?")}
  end

  def platform_cpu
    OS.host_cpu
  end

  def additional_options
    OS.mac? ? "-J-XstartOnFirstThread" : ""
  end
end
