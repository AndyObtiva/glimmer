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

## Resources

* [Eclipse Zone Tutorial](http://eclipse.dzone.com/articles/an-introduction-glimmer)
* [InfoQ Article](http://www.infoq.com/news/2008/02/glimmer-jruby-swt)
* [RubyConf 2008 Video](https://confreaks.tv/videos/rubyconf2008-desktop-development-with-glimmer)
* [Code Blog](http://andymaleh.blogspot.com/search/label/Glimmer)

## Pre-requisites

JRuby 9.2.9.0 (supporting Ruby 2.5.0 syntax)

Easiest way to obtain is through [RVM](http://rvm.io)

With RVM installed on your system, please run this command to install JRuby:

```bash
rvm install jruby-9.2.9.0
```

## Setup

Please follow these instructions to make the `glimmer` command available on your system.

### Option 1: Bundler

Add the following to `Gemfile`:
```
gem 'glimmer', '~> 0.1.10.470'
```

And, then run:
```
bundle install
```

### Option 2: Direct RubyGem

Run this command to get directly:
```
gem install glimmer -v 0.1.10.470
```

## Usage

Usage:
```
glimmer [--setup] [application_ruby_file_path.rb]
```

Example 1:
```
glimmer hello_combo.rb
```
This runs the Glimmer application `hello_combo.rb` (if the SWT Jar is missing, it downloads it and sets it up first.)

Example 2:
```
glimmer --setup hello_combo.rb
```
This performs setup and then runs the Glimmer application `hello_combo.rb` (downloads and sets up the SWT jar whether present or not)

Example 3:
```
glimmer --setup
```
This just downloads and sets up the SWT jar even if already present.

## Syntax

Check out the SWT library API for a list of available widgets:
https://help.eclipse.org/oxygen/index.jsp?topic=%2Forg.eclipse.platform.doc.isv%2Freference%2Fapi%2Forg%2Feclipse%2Fswt%2Fwidgets%2Fpackage-summary.html

In Glimmer DSL, SWT widgets are declared with lowercase underscored naming.

Widget examples:
- `button` for `org.eclipse.swt.widgets.Button`
- `label` for `org.eclipse.swt.widgets.Label`
- `table_column` for `org.eclipse.swt.widgets.TableColumn`

The `shell` widget is always the outermost widget containing all others in a desktop windowed application.

Widget properties may be set with methods matching their names in lower snakecase.

Widget property examples:
- `text` to set text value of a `label`
- `gridData` to set grid data of a `composite`

Data-binding is done with `bind` command following widget property to bind and taking model and bindable attribute as arguments.

Data-binding examples:
- `text bind(contact, :first_name)`
- `text bind(contact, :name, computed_by: [:first_name, :last_name])`

The first example binds the text property of a widget like `label` to the first name of a contact model.

The second example demonstrates computed value data binding whereby the value of `name` depends on changes to both `first_name` and `last_name`

You may learn more about Glimmer's syntax by reading the Eclipse Zone Tutorial mentioned in resources and opening up the samples under the `samples` folder.

## Girb (Glimmer irb)

With Glimmer installed, you may run want to run `girb` instead of standard `irb` to have SWT preloaded and the Glimmer library required and included for quick Glimmer coding/testing.

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

Mac is well supported with the `glimmer` command.

If there is a reason to use the raw jruby command on the Mac, you need to pass an extra option to JRuby. For example:
`jruby -J-XstartOnFirstThread samples/hello_world.rb`

## Windows Support

Windows is supported by JRuby and the Eclipse SWT library Glimmer runs on. However, the `glimmer` command has not been confirmed to be working on Windows yet. Please feel free to share experiences and provide help in ensuring support for Windows.

## Linux Support

Same as Windows

## Feature Suggestions

These features have been suggested. You might see them in a future version of Glimmer. You are welcome to contribute more feature suggestions.

- Nested binding via attribute expressions (e.g. `bind(person, "address.city")`)
- bind_collection: an iterator that enables spawning widgets based on a collection (e.g. spawn 2 `AddressWidget`s if `user.addresses` bind collection contains 2 addresses)

## Contributing to Glimmer

Please follow these instructions if you would like to help us develop Glimmer:

1. Download and extract the ["SWT binary and source"](http://download.eclipse.org/eclipse/downloads/drops4/R-4.7-201706120950/#SWT).
2. Add swt.jar to your Java CLASSPATH environment (e.g. `export CLASSPATH="$CLASSPATH:/path_to_swt_jar/swt.jar"`)
3. Download and setup jRuby 1.5.6 (`rvm install jruby-9.2.9.0`)
4. Install bundler (gem install bundler)
5. Install project required gems (bundle install)
6. Write a program that requires the file "lib/glimmer.rb" (or glimmer gem) and has the UI class (view) include the Glimmer module
7. Run your program with `bin/glimmer` or jruby (pass `-J-XstartOnFirstThread` option if on the Mac)

## Contributors

* Annas "Andy" Al Maleh (Founder)
* Dennis Theisen

## License

Copyright (c) 2007-2019 Annas "Andy" Al Maleh.
See LICENSE.txt for further details.
