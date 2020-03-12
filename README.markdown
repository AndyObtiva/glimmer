# Glimmer (The Original One And Only)
[![Coverage Status](https://coveralls.io/repos/github/AndyObtiva/glimmer/badge.svg?branch=master)](https://coveralls.io/github/AndyObtiva/glimmer?branch=master)

Glimmer is a cross-platform Ruby desktop development library. Glimmer's main innovation is a JRuby DSL that enables easy and efficient authoring of desktop application user-interfaces while relying on the robust platform-independent Eclipse SWT library. Glimmer additionally innovates by having built-in desktop UI data-binding support to greatly facilitate synchronizing the UI with domain models. As a result, that achieves true decoupling of object oriented components, enabling developers to solve business problems without worrying about UI concerns, or alternatively drive development UI-first, and then write clean business components test-first afterward.

You may learn more by reading this article: [Eclipse Zone Tutorial](http://eclipse.dzone.com/articles/an-introduction-glimmer)

## Examples

### Hello World

Glimmer code (from `samples/hello_world.rb`):
```ruby
include Glimmer

shell {
  text "Glimmer"
  label {
    text "Hello World!"
  }
}.open
```

Run:
```
glimmer samples/hello_world.rb
```

Glimmer app:

![Hello World](https://github.com/AndyObtiva/glimmer/raw/master/images/glimmer-hello-world.png)

### Tic Tac Toe

Glimmer code (from `samples/tictactoe/tic_tac_toe.rb`):

```ruby
shell {
  text "Tic-Tac-Toe"
  composite {
    layout GridLayout.new(3,true)
    (1..3).each { |row|
      (1..3).each { |column|
        button {
          layout_data GridData.new(:fill.swt_constant, :fill.swt_constant, true, true)
          text        bind(@tic_tac_toe_board.box(row, column), :sign)
          enabled     bind(@tic_tac_toe_board.box(row, column), :empty)
          on_widget_selected {
            @tic_tac_toe_board.mark_box(row, column)
          }
        }
      }
    }
  }
}
```

Run:

```
glimmer samples/tictactoe/tic_tac_toe.rb
```

Glimmer app:

![Tic Tac Toe](https://github.com/AndyObtiva/glimmer/raw/master/images/glimmer-tic-tac-toe.png)

## Resources

* [Eclipse Zone Tutorial](http://eclipse.dzone.com/articles/an-introduction-glimmer)
* [InfoQ Article](http://www.infoq.com/news/2008/02/glimmer-jruby-swt)
* [RubyConf 2008 Video](https://confreaks.tv/videos/rubyconf2008-desktop-development-with-glimmer)
* [Code Blog](http://andymaleh.blogspot.com/search/label/Glimmer)

## Background

Ruby is a dynamically-typed object-oriented language, which provides great productivity gains due to its powerful expressive syntax and dynamic nature. While it is proven by the Ruby on Rails framework for web development, it currently lacks a robust platform-independent framework for building desktop applications. Given that Java libraries can now be utilized in Ruby code through JRuby, Eclipse technologies, such as SWT, JFace, and RCP can help fill the gap of desktop application development with Ruby.

## Platform Support

Glimmer runs on the following platforms:
- Mac
- Windows
- Linux

## Pre-requisites

* Java SE Runtime Environment 7 or higher (find at https://www.oracle.com/java/technologies/javase-downloads.html)
* JRuby 9.2.10.0 (supporting Ruby 2.5.x syntax) (find at https://www.jruby.org/download)

On **Mac** and **Linux**, an easy way to obtain JRuby is through [RVM](http://rvm.io) by running:

```bash
rvm install jruby-9.2.10.0
```

## Setup

Please follow these instructions to make the `glimmer` command available on your system.

### Option 1: Direct Install

Run this command to install directly:
```
jgem install glimmer -v 0.3.3
```

### Option 2: Bundler

Add the following to `Gemfile`:
```
gem 'glimmer', '~> 0.3.3'
```

And, then run:
```
bundle install
```

## Glimmer command

Usage:
```
glimmer application.rb
```

Runs a Glimmer application using JRuby, automatically preloading
the glimmer ruby gem and SWT jar dependency.

Example:
```
glimmer hello_world.rb
```
This runs the Glimmer application hello_world.rb

## Glimmer DSL Syntax

### Widgets

Glimmer UIs (user interfaces) are modeled with widgets (wrappers around the SWT library widgets found here: https://help.eclipse.org/2019-12/topic/org.eclipse.platform.doc.isv/guide/swt_widgets_controls.htm?cp=2_0_7_0_0).

In Glimmer DSL, widgets are declared with lowercase underscored naming (you may look at usage examples in the `samples` directory).

The `shell` widget is always the outermost widget containing all others in a desktop windowed application.

Other widget examples:
- `button`: wrapper for `org.eclipse.swt.widgets.Button`
- `label`: wrapper for `org.eclipse.swt.widgets.Label`
- `tab_folder`: wrapper for `org.eclipse.swt.widgets.TabFolder`
- `tab_item`: wrapper for `org.eclipse.swt.widgets.TabItem`
- `table`: wrapper for `org.eclipse.swt.widgets.Table`
- `table_column`: wrapper for `org.eclipse.swt.widgets.TableColumn`
- `tree`: wrapper for `org.eclipse.swt.widgets.Tree`

### Widget Styles

SWT widgets receive `SWT` styles in their constructor as per this guide:

https://wiki.eclipse.org/SWT_Widget_Style_Bits

Glimmer DSL facilitates that by passing symbols representing `SWT` constants as widget method arguments (i.e. inside widget `()` parentheses. See example below) in lower case version (e.g. `SWT::MULTI` becomes `:multi`).

These styles customize widget look, feel, and behavior.

Example:
```ruby
list(:multi) { # SWT styles go inside ()
  # ...
}
```

Passing `:multi` to `list` widget enables list element multi-selection.

```ruby
composite(:border) { # SWT styles go inside ()
  # ...
}
```

Passing `:border` to `composite` widget ensures it has a border.

When you need to pass in **multiple SWT styles**, simply separate by commas.

Example:
```ruby
text(:center, :border) { # Multiple SWT styles separated by comma
  # ...
}
```

Glimmer ships with SWT style **smart defaults** so you wouldn't have to set them yourself most of the time (albeit you can always override them):

- `text(:border)`
- `table(:border)`
- `spinner(:border)`
- `list(:border, :v_scroll)`
- `button(:push)`

You may check out all available `SWT` styles here:

https://help.eclipse.org/2019-12/topic/org.eclipse.platform.doc.isv/reference/api/org/eclipse/swt/SWT.html

### Widget Properties

Widget properties such as value, enablement, and layout details are set within the widget block using methods matching SWT widget property names in lower snakecase. You may refer to SWT widget guide for details on available widget properties:

https://help.eclipse.org/2019-12/topic/org.eclipse.platform.doc.isv/guide/swt_widgets_controls.htm?cp=2_0_7_0_0


Code examples:

```ruby
label {
  text "Hello World!" # SWT properties go inside {} block
}
```

In the above example, the `label` widget `text` property was set to "Hello World!".

```ruby
button {
  enabled bind(@tic_tac_toe_board.box(row, column), :empty)
}
```

In the above example, the `text` widget `enabled` property was data-bound to `#empty` method on `@tic_tac_toe_board.box(row, column)` (learn more about data-binding below)

### Color

Color makes up a subset of widget properties. SWT accepts color objects created with RGB (Red Green Blue) or RGBA (Red Green Blue Alpha). Glimmer supports constructing color objects using the `rgb` and `rgba` DSL methods.

Example:

```ruby
label {
  background rgb(144, 240, 244)
  foreground rgba(38, 92, 232, 255)
}
```

SWT also supports all standard colors available as constants under the `SWT` namespace (e.g. `SWT::COLOR_BLUE`)

Glimmer accepts these constants as Ruby symbols prefixed by `color_`.

Example:

```ruby
label {
  background :color_white
  foreground :color_black
}
```

You may check out all available standard colors in `SWT` over here:

https://help.eclipse.org/2019-12/topic/org.eclipse.platform.doc.isv/reference/api/org/eclipse/swt/SWT.html

### Data-Binding

Data-binding is done with `bind` command following widget property to bind and taking model and bindable attribute as arguments.

Data-binding examples:
- `text bind(contact, :first_name)`
- `text bind(contact, 'address.street')`
- `text bind(contact, 'addresses[1].street')`
- `text bind(contact, :name, computed_by: [:first_name, :last_name])`
- `text bind(contact, 'profiles[0].name', computed_by: ['profiles[0].first_name', 'profiles[0].last_name'])`

The first example binds the text property of a widget like `label` to the first name of a contact model.

The second example binds the text property of a widget like `label` to the nested street of
the address of a contact. This is called nested property data binding.

The third example binds the text property of a widget like `label` to the nested indexed address street of a contact. This is called nested indexed property data binding.

The fourth example demonstrates computed value data binding whereby the value of `name` depends on changes to both `first_name` and `last_name`.

The fifth example demonstrates nested indexed computed value data binding whereby the value of `profiles[0].name` depends on changes to both nested `profiles[0].first_name` and `profiles[0].last_name`.

You may learn more about Glimmer's syntax by reading the Eclipse Zone Tutorial mentioned in resources and opening up the samples under the `samples` folder.

### Observer

Glimmer comes with `Observer` module, which is used internally for data-binding, but can also be used externally for custom use of the Observer Pattern.

In summary, the class that needs to observe an object, must include Observer and implement `#update(changed_value)` method. The class to be observed doesn't need to do anything. It will automatically be enhanced by Glimmer for observation.

Observers can be a good mechanism for displaying dialog messages with Glimmer (using SWT's `MessageBox`).

Look at `samples/tictactoe/tic_tac_toe.rb` for an `Observer` dialog message example.

```ruby
observe(@tic_tac_toe_board, "game_status")
```

```ruby
def update(game_status)
  display_win_message if game_status == TicTacToeBoard::WIN
  display_draw_message if game_status == TicTacToeBoard::DRAW
end

def display_win_message
  display_game_over_message("Player #{@tic_tac_toe_board.winning_sign} has won!")
end

def display_draw_message
  display_game_over_message("Draw!")
end

def display_game_over_message(message)
  message_box = MessageBox.new(@shell.widget)
  message_box.setText("Game Over")
  message_box.setMessage(message)
  message_box.open
  @tic_tac_toe_board.reset
end
```

## Samples

Check the "samples" folder for examples on how to write Glimmer applications. To run them, make sure to install the `glimmer` gem first and then use the `glimmer` command.

Example:

```
glimmer samples/hello_world.rb
```

## SWT Reference

https://www.eclipse.org/swt/docs.php

Here is a list of SWT widgets:

https://help.eclipse.org/2019-12/topic/org.eclipse.platform.doc.isv/guide/swt_widgets_controls.htm?cp=2_0_7_0_0

Here is a list of SWT style bits:

https://wiki.eclipse.org/SWT_Widget_Style_Bits

## Girb (Glimmer irb)

With Glimmer installed, you may run want to run `girb` instead of standard `irb` to have SWT preloaded and the Glimmer library required and included for quick Glimmer coding/testing.

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

## Raw JRuby Command

If there is a need to run Glimmer directly via the `jruby` command, you
may run the following:

```
jruby -J-classpath "path_to/swt.jar" -r glimmer -S application.rb
```

The `-J-classpath` option specifies the `swt.jar` file path, which can be a
manually downloaded version of SWT, or otherwise the one included in the gem. You can lookup the one included in the gem by running `jgem which glimmer` to find the gem path and then look through the `vendor` directory.

The `-r` option preloads (requires) the `glimmer` library in Ruby.

The `-S` option specifies a script to run.

### Mac Support

Mac is well supported with the `glimmer` command. However, if there is a reason to use the raw jruby command, you need to pass an extra option (`-J-XstartOnFirstThread`) to JRuby on the Mac.

Example:
```
jruby -J-XstartOnFirstThread -J-classpath "path_to/swt.jar" -r glimmer -S application.rb
```

## Feature Suggestions

These features have been suggested. You might see them in a future version of Glimmer. You are welcome to contribute more feature suggestions.

- Glimmer Application: provide a standard structure for building a Glimmer app
- Glimmer Component: Glimmer already supports components by externalizing to objects, but it would be good if there is a module to include so Glimmer would automatically register
a new component and extend the DSL with it
- Glimmer Wizard: provide a standard structure for building a Glimmer wizard (multi-step/multi-screen process)
- bind_collection: an iterator that enables spawning widgets based on a variable collection (e.g. `bind_collection('user.addresses') { |address| address_widget {...} }` spawns 3 `AddressWidget`s if `user.addresses` is set with 3 addresses; and replaces with 2 `AddressWidget`s if `user.addresses` is reset with 2 addresses only). Needs further thought on naming and functionality.
- Automatic relayout of "glimmer components" when disposing one or as an option
- Consider using Ruby Refinements for Glimmer
- Add 'font' to Glimmer DSL to build font objects easily
- Add grid layout support to Glimmer DSL to layout grid components easily
- Add rerendering support to Glimmer to rerender any widget easily
- Avoid disposing display when disposing a shell to allow recycling
- Provide a display builder method to use independently of shell
- Supported a single computed data binding as a string (not array)
- Disallow use of SWT::CONSTANTs with ORing since it's not intuitive at all

## Contributors

* Andy Maleh (Founder)
* Dennis Theisen

## License

Copyright (c) 2007-2020 Andy Maleh.
See LICENSE.txt for further details.
