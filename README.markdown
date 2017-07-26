# Glimmer (The Original One And Only)
[![Coverage Status](https://coveralls.io/repos/github/AndyObtiva/glimmer/badge.svg?branch=master)](https://coveralls.io/github/AndyObtiva/glimmer?branch=master)

Glimmer is a cross-platform Ruby desktop development library. Glimmer's main innovation is a JRuby DSL that enables easy and efficient authoring of desktop application user-interfaces while relying on the robust platform-independent Eclipse SWT library. Glimmer additionally innovates by having built-in desktop UI data-binding support to greatly facilitate synchronizing the UI with domain models. As a result, that achieves true decoupling of object oriented components, enabling developers to solve business problems without worrying about UI concerns, or alternatively drive development UI-first, and then write clean business components test-first afterward.

You may learn more by reading this article: [Eclipse Zone Tutorial](http://eclipse.dzone.com/articles/an-introduction-glimmer)

![Glimmer](https://github.com/AndyObtiva/glimmer/raw/master/images/Bitter-sweet.jpg)

## Example

```ruby
    shell {
      text "Example"
      label {
        text "Hello World!"
      }
    }.open
```

## Pre-requisites

JRuby 9.1.12.0 (supporting Ruby 2.3.0 syntax)

Easiest way to obtain is through [RVM](http://rvm.io)

With RVM installed on your system, please run this command to install JRuby:

```bash
rvm install jruby-9.1.12.0
```

## Setup

Please follow these instructions to make the `glimmer` command available on your system.

### Option 1: Bundler

Add the following to `Gemfile`:
```
gem 'glimmer', '~> 0.1.9.470'
```

And, then run:
```
bundle install
```

### Option 2: Direct RubyGem

Run this command to get directly:
```
gem install glimmer -v 0.1.9.470
```

## Usage

Usage: `glimmer [--setup] [application_ruby_file_path.rb]`

Example 1: `glimmer hello_combo.rb`
This runs the Glimmer application hello_combo.rb
If the SWT Jar is missing, it downloads it and sets it up first.

Example 2: `glimmer --setup hello_combo.rb`
This performs setup and then runs the Glimmer application hello_combo.rb
It downloads and sets up the SWT jar whether missing or not.

Example 3: `glimmer --setup`
This downloads and sets up the SWT jar whether missing or not.    

## Girb (Glimmer irb)

You may run girb instead of standard irb to have SWT preloaded and the Glimmer required and included for quick Glimmer coding/testing.  

## Samples

Check the "samples" folder for examples on how to write Glimmer applications.

## Background

Ruby is a dynamically-typed object-oriented language, which provides great productivity gains due to its powerful expressive syntax and dynamic nature. While it is proven by the Ruby on Rails framework for web development, it currently lacks a robust platform-independent framework for building desktop applications. Given that Java libraries can now be utilized in Ruby code through JRuby, Eclipse technologies, such as SWT, JFace, and RCP can help fill the gap of desktop application development with Ruby.

## Logging

Glimmer comes with a Ruby Logger accessible via `Glimmer.logger`
Its level of logging defaults to `Logger::WARN`
It may be configured to show a different level of logging as follows:
```ruby
Glimmer.logger.level = Logger::DEBUG
```
This results in more verbose debugging log to `STDOUT`, which is helpful in troubleshooting Glimmer DSL syntax when needed.

Example log:
```
D, [2017-07-21T19:23:12.587870 #35707] DEBUG -- : method: shell and args: []
D, [2017-07-21T19:23:12.594405 #35707] DEBUG -- : ShellCommandHandler will handle command: shell with arguments []
D, [2017-07-21T19:23:12.844775 #35707] DEBUG -- : method: composite and args: []
D, [2017-07-21T19:23:12.845388 #35707] DEBUG -- : parent is a widget: true
D, [2017-07-21T19:23:12.845833 #35707] DEBUG -- : on listener?: false
D, [2017-07-21T19:23:12.864395 #35707] DEBUG -- : WidgetCommandHandler will handle command: composite with arguments []
D, [2017-07-21T19:23:12.864893 #35707] DEBUG -- : widget styles are: []
D, [2017-07-21T19:23:12.874296 #35707] DEBUG -- : method: list and args: [:multi]
D, [2017-07-21T19:23:12.874969 #35707] DEBUG -- : parent is a widget: true
D, [2017-07-21T19:23:12.875452 #35707] DEBUG -- : on listener?: false
D, [2017-07-21T19:23:12.878434 #35707] DEBUG -- : WidgetCommandHandler will handle command: list with arguments [:multi]
D, [2017-07-21T19:23:12.878798 #35707] DEBUG -- : widget styles are: [:multi]
```

## Mac Support

In order to run Glimmer on the Mac, you need to pass an extra option to JRuby. For example:
`jruby -J-XstartOnFirstThread samples/hello_world.rb`

## Contributing to Glimmer

Please follow these instructions if you would like to help us develop Glimmer:

1. Download and extract the ["SWT binary and source"](http://download.eclipse.org/eclipse/downloads/drops4/R-4.7-201706120950/#SWT).
2. Add swt.jar to your Java CLASSPATH environment (e.g. `export CLASSPATH="$CLASSPATH:/path_to_swt_jar/swt.jar"`)
3. Download and setup jRuby 1.5.6 (`rvm install jruby-9.1.12.0`)
4. Install bundler (gem install bundler)
5. Install project required gems (bundle install)
6. Write a program that requires the file "lib/glimmer.rb" (or glimmer gem) and has the UI class (view) include the Glimmer module
7. Run your program with `bin/glimmer` or jruby (pass `-J-XstartOnFirstThread` option if on the Mac)

## Resources

* [Eclipse Zone Tutorial](http://eclipse.dzone.com/articles/an-introduction-glimmer)
* [InfoQ Article](http://www.infoq.com/news/2008/02/glimmer-jruby-swt)
* [RubyConf 2008 Video](http://rubyconf2008.confreaks.com/desktop-development-with-glimmer.html)
* [Code Painter Blog](http://andymaleh.blogspot.com/search/label/Glimmer)

## Contributors

* Annas "Andy" Al Maleh (Founder)
* Dennis Theisen

## License

Copyright (c) 2007-2017 Annas Al Maleh.
See LICENSE.txt for further details.
