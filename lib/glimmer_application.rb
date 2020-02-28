require 'net/http'
require 'fileutils'
require 'os'
require 'yaml'

class GlimmerApplication
  SWT_ZIP_FILE = File.join(`echo ~`.strip, '.glimmer', 'vendor', 'swt.zip')
  SWT_JAR_FILE = File.join(File.dirname(SWT_ZIP_FILE), 'swt.jar')

  OPERATING_SYSTEMS = ["mac", "windows", "linux"]
  REGEX_SETUP = /--setup/
  REGEX_SWT_VERSION = /[0-9]+[.0-9]*/
  REGEX_APPLICATION = /.+/
  REGEX_OPTIONS = [
    REGEX_SETUP, REGEX_SWT_VERSION, REGEX_APPLICATION
  ].map {|re| "(#{re})?"}.join("\s*")

  attr_reader :setup_requested, :swt_version_specified, :application
  alias :setup_requested? :setup_requested

  # Accepts the following options string:
  # --setup app_file_path.rb
  # or
  # --setup
  # or
  # app_file_path.rb
  def initialize(options)
    options_regex_match = options.join(' ').match(REGEX_OPTIONS)
    @setup_requested = !!options_regex_match[1]
    @swt_version_specified = options_regex_match[2]
    @application = options_regex_match[3]
  end

  def start
    usage unless setup_requested? || application

    setup if setup_requested? || !File.exist?(SWT_JAR_FILE)

    if application && File.exist?(SWT_JAR_FILE)
      puts "Starting Glimmer Application #{application}"
      system "ruby #{additional_options} -J-classpath \"#{SWT_JAR_FILE}\" #{application}"
    end
  end

  def usage
    puts <<-MULTILINE
Usage: glimmer [--setup] [SWT_VERSION] [application_ruby_file_path.rb]

Example 1: glimmer hello_combo.rb
This runs the Glimmer application hello_combo.rb
If the SWT Jar is missing, it first downloads the latest version supported.

Example 2: glimmer --setup hello_combo.rb
This performs setup and then runs the Glimmer application hello_combo.rb
It downloads and sets up the latest SWT jar whether missing or not.

Example 3: glimmer --setup
This downloads and sets up the latest SWT jar whether missing or not.

Example 4: glimmer --setup 4.14
This downloads and sets up the SWT jar specified version 4.14 whether missing or not.
    MULTILINE
  end

  def setup
    puts "#{SWT_JAR_FILE} is missing! Will obtain a new copy now." unless File.exist?(SWT_JAR_FILE)
    FileUtils.mkdir_p(File.dirname(SWT_ZIP_FILE))
    download(SWT_ZIP_FILE)
    puts "Unzipping #{SWT_ZIP_FILE}"
    `unzip -o #{SWT_ZIP_FILE} -d #{File.dirname(SWT_ZIP_FILE)}`
    puts "Finished unzipping"
  rescue => e
    puts e.message
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
    swt_config[swt_version][platform_swt_url_key]
  rescue
    raise "SWT version #{swt_version} is not available for download!"
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
