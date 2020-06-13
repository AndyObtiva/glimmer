# Glimmer 0.9.0 Beta (Ruby Desktop Development GUI Library)
[![Gem Version](https://badge.fury.io/rb/glimmer.svg)](http://badge.fury.io/rb/glimmer)
[![Travis CI](https://travis-ci.com/AndyObtiva/glimmer.svg?branch=master)](https://travis-ci.com/github/AndyObtiva/glimmer)
[![Maintainability](https://api.codeclimate.com/v1/badges/38fbc278022862794414/maintainability)](https://codeclimate.com/github/AndyObtiva/glimmer/maintainability)

Glimmer is a native-GUI cross-platform desktop development library written in Ruby. Glimmer's main innovation is a JRuby DSL that enables productive and efficient authoring of desktop application user-interfaces while relying on the robust Eclipse SWT library. Glimmer additionally innovates by having built-in data-binding support to greatly facilitate synchronizing the GUI with domain models. As a result, that achieves true decoupling of object oriented components, enabling developers to solve business problems without worrying about GUI concerns, or alternatively drive development GUI-first, and then write clean business models test-first afterwards.

[<img src="https://covers.oreillystatic.com/images/9780596519650/lrg.jpg" width=105 /><br /> 
Featured in<br />JRuby Cookbook](http://shop.oreilly.com/product/9780596519650.do)

## Examples

### Hello, World!

Glimmer code (from [`samples/hello/hello_world.rb`](https://github.com/AndyObtiva/glimmer-dsl-swt/blob/master/samples/hello/hello_world.rb)):
```ruby
include Glimmer

shell {
  text "Glimmer"
  label {
    text "Hello, World!"
  }
}.open
```

Run:
```
glimmer samples/hello/hello_world.rb
```

Glimmer app:

![Hello World](images/glimmer-hello-world.png)

### Tic Tac Toe

Glimmer code (from [`samples/elaborate/tic_tac_toe.rb`](https://github.com/AndyObtiva/glimmer-dsl-swt/blob/master/samples/elaborate/tic_tac_toe.rb)):

```ruby
# ...
shell {
  text "Tic-Tac-Toe"
  composite {
    grid_layout 3, true
    (1..3).each { |row|
      (1..3).each { |column|
        button {
          layout_data :fill, :fill, true, true
          text        bind(@tic_tac_toe_board[row, column], :sign)
          enabled     bind(@tic_tac_toe_board[row, column], :empty)
          on_widget_selected {
            @tic_tac_toe_board.mark(row, column)
          }
        }
      }
    }
  }
}
# ...
```

Run:

```
glimmer samples/elaborate/tic_tac_toe.rb
```

Glimmer app:

![Tic Tac Toe](images/glimmer-tic-tac-toe.png)

NOTE: Glimmer is in beta mode. Please help make better by [contributing](#contributing), adopting for small or low risk projects, and providing feedback.

Ruby is a dynamically-typed object-oriented language, which provides great productivity gains due to its powerful expressive syntax and dynamic nature. While it is proven by the Ruby on Rails framework for web development, it currently lacks a robust platform-independent framework for building desktop applications. Given that Java libraries can now be utilized in Ruby code through JRuby, Eclipse technologies, such as SWT, JFace, and RCP can help fill the gap of desktop application development with Ruby.

## Getting Started

Glimmer is a DSL engine that supports multiple DSLs (Domain Specific Languages). 

To get started, choose one or more of the following Glimmer DSLs and follow their setup instructions:
- [SWT](https://github.com/AndyObtiva/glimmer-dsl-swt) (required): Glimmer DSL for SWT (Desktop GUI)
- [Opal](https://github.com/AndyObtiva/glimmer-dsl-opal): Glimmer DSL for Opal (Web GUI Adapter for Desktop Apps)
- [XML](https://github.com/AndyObtiva/glimmer-dsl-xml): Glimmer DSL for XML (& HTML) - Useful with SWT Browser Widget
- [CSS](https://github.com/AndyObtiva/glimmer-dsl-css): Glimmer DSL for CSS (Cascading Style Sheets) - Useful with SWT Browser Widget

## Multi-DSL Support

Glimmer automatically recognizes top-level keywords in each DSL and activates DSL accordingly. Glimmer allows mixing DSLs, which comes in handy when doing things like using the SWT Browser widget with XML and CSS. Once done processing a nested DSL top-level keyword, Glimmer switches back to the prior DSL automatically.

### SWT

Full instructions are found in the [SWT](https://github.com/AndyObtiva/glimmer-dsl-swt) DSL page.

The SWT DSL has the following top-level keywords:
- `shell`
- `display`
- `color`
- `observe`
- `async_exec`
- `sync_exec`

### Opal

Full instructions are found in the [Opal](https://github.com/AndyObtiva/glimmer-dsl-opal) DSL page.

The [Opal](https://github.com/AndyObtiva/glimmer-dsl-opal) DSL is simply a web GUI adapter for desktop apps written in Glimmer. As such, it supports all the DSL keywords of the SWT DSL and shares the same top-level keywords.

### XML

Full instructions are found in the [XML](https://github.com/AndyObtiva/glimmer-dsl-xml) DSL page.

Simply start with `html` keyword and add HTML inside its block using Glimmer DSL syntax.
Once done, you may call `to_s`, `to_xml`, or `to_html` to get the formatted HTML output.

Here are all the Glimmer XML DSL top-level keywords:
- `html`
- `tag`: enables custom tag creation for exceptional cases by passing tag name as '_name' attribute
- `name_space`: enables namespacing html tags

Element properties are typically passed as a key/value hash (e.g. `section(id: 'main', class: 'accordion')`) . However, for properties like "selected" or "checked", you must leave value `nil` or otherwise pass in front of the hash (e.g. `input(:checked, type: 'checkbox')` )

Example (basic HTML / you may copy/paste in [`girb`](#girb-glimmer-irb-command)):

```ruby
@xml = html {
  head {
    meta(name: "viewport", content: "width=device-width, initial-scale=2.0")
  }
  body {
    h1 { "Hello, World!" }
  }
}
puts @xml
```

Output:

```
<html><head><meta name="viewport" content="width=device-width, initial-scale=2.0" /></head><body><h1>Hello, World!</h1></body></html>
```

Example (explicit XML tag / you may copy/paste in [`girb`](#girb-glimmer-irb-command)):

```ruby
puts tag(:_name => "DOCUMENT")
```

Output:

```
<DOCUMENT/>
```

Example (XML namespaces using `name_space` keyword / you may copy/paste in [`girb`](#girb-glimmer-irb-command)):

```ruby
@xml = name_space(:w3c) {
  html(:id => "thesis", :class => "document") {
    body(:id => "main") {
    }
  }
}
puts @xml
```

Output:

```
<w3c:html id="thesis" class="document"><w3c:body id="main"></w3c:body></w3c:html>
```

Example (XML namespaces using dot operator / you may copy/paste in [`girb`](#girb-glimmer-irb-command)):

```ruby
@xml = tag(:_name => "DOCUMENT") {
  document.body(document.id => "main") {
  }
}
puts @xml
```

Output:

```
<DOCUMENT><document:body document:id="main"></document:body></DOCUMENT>
```


### CSS

Full instructions are found in the [CSS](https://github.com/AndyObtiva/glimmer-dsl-css) DSL page.

Simply start with `css` keyword and add stylesheet rule sets inside its block using Glimmer DSL syntax.
Once done, you may call `to_s` or `to_css` to get the formatted CSS output.

`css` is the only top-level keyword in the Glimmer CSS DSL

Selectors may be specified by `s` keyword or HTML element keyword directly (e.g. `body`)
Rule property values may be specified by `pv` keyword or underscored property name directly (e.g. `font_size`)

Example (you may copy/paste in [`girb`](#girb-glimmer-irb-command)):

```ruby
@css = css {
  body {
    font_size '1.1em'
    pv 'background', 'white'
  }
  
  s('body > h1') {
    background_color :red
    pv 'font-size', '2em'
  }
}
puts @css
```

### Listing / Enabling / Disabling DSLs

Glimmer provides a number of methods on Glimmer::DSL::Engine to configure DSL support or inquire about it:
- `Glimmer::DSL::Engine.dsls`: Lists available Glimmer DSLs
- `Glimmer::DSL::Engine.disable_dsl(dsl_name)`: Disables a specific DSL. Useful when there is no need for certain DSLs in a certain application.
- `Glimmer::DSL::Engine.disabled_dsls': Lists disabled DSLs
- `Glimmer::DSL::Engine.enable_dsl(dsl_name)`: Re-enables disabled DSL
- `Glimmer::DSL::Engine.enabled_dsls=(dsl_names)`: Disables all DSLs except the ones specified.

## Glimmer Style Guide

- Widgets are declared with underscored lowercase versions of their SWT names minus the SWT package name.
- Widget declarations may optionally have arguments and be followed by a block (to contain properties and content)
- Widget blocks are always declared with curly braces
- Widget arguments are always wrapped inside parentheses
- Widget properties are declared with underscored lowercase versions of the SWT properties
- Widget property declarations always have arguments and never take a block
- Widget property arguments are never wrapped inside parentheses
- Widget listeners are always declared starting with `on_` prefix and affixing listener event method name afterwards in underscored lowercase form
- Widget listeners are always followed by a block using curly braces (Only when declared in DSL. When invoked on widget object directly outside of GUI declarations, standard Ruby conventions apply)
- Data-binding is done via `bind` keyword, which always takes arguments wrapped in parentheses
- Custom widget body, before_body, and after_body blocks open their blocks and close them with curly braces.
- Custom widgets receive additional arguments to SWT style called options. These are passed as the last argument inside the parentheses, a hash of option names pointing to values.

## Samples

Check the [samples](samples) directory for examples on how to write Glimmer applications. To run a sample, make sure to install the `glimmer` gem first and then use the `glimmer` command to run it (alternatively, you may clone the repo, follow [CONTRIBUTING.md](CONTRIBUTING.md) instructions, and run samples locally with development glimmer command: `bin/glimmer`).

If you cloned the project and followed [CONTRIBUTING.md](CONTRIBUTING.md) instructions, you may run all samples at once via `samples/launch` command:

```
samples/launch
```

### Hello Samples

For "Hello, World!" type samples, check the following:

```
glimmer samples/hello/hello_world.rb
glimmer samples/hello/hello_browser.rb # demonstrates browser widget
glimmer samples/hello/hello_tab.rb # demonstrates tabs
glimmer samples/hello/hello_combo.rb # demonstrates combo data-binding
glimmer samples/hello/hello_list_single_selection.rb # demonstrates list single-selection data-binding
glimmer samples/hello/hello_list_multi_selection.rb # demonstrates list multi-selection data-binding
glimmer samples/hello/hello_computed.rb # demonstrates computed data-binding
```

### Elaborate Samples

For more elaborate samples, check the following:

```
glimmer samples/elaborate/login.rb # demonstrates basic data-binding
glimmer samples/elaborate/contact_manager.rb # demonstrates table data-binding
glimmer samples/elaborate/tic_tac_toe.rb # demonstrates a full MVC application
```

### External Samples

#### Glimmer Calculator

[<img src="https://raw.githubusercontent.com/AndyObtiva/glimmer-cs-calculator/v1.0.0/glimmer-cs-calculator-screenshot.png" />](https://github.com/AndyObtiva/glimmer-cs-calculator)

[Glimmer Calculator](https://github.com/AndyObtiva/glimmer-cs-calculator) is a basic calculator sample project demonstrating data-binding and TDD (test-driven-development) with Glimmer following the MVP pattern (Model-View-Presenter).

#### Gladiator

[<img src="https://raw.githubusercontent.com/AndyObtiva/glimmer-cs-gladiator/v0.1.5/images/glimmer-gladiator.png" />](https://github.com/AndyObtiva/glimmer-cs-gladiator)

[Gladiator](https://github.com/AndyObtiva/glimmer-cs-gladiator) (short for Glimmer Editor) is a Glimmer sample project under on-going development.
You may check it out to learn how to build a Glimmer Custom Shell gem.

## In Production

The following production apps have been built with Glimmer:

[<img alt="Math Bowling Logo" src="https://raw.githubusercontent.com/AndyObtiva/MathBowling/master/images/math-bowling-logo.png" width="40" />Math Bowling](https://github.com/AndyObtiva/MathBowling): an educational math game for elementary level kids

## Logging

Glimmer comes with a Ruby Logger accessible via `Glimmer::Config.logger`
Its level of logging defaults to `Logger::WARN`
It may be configured to show a different level of logging as follows:
```ruby
Glimmer::Config.enable_logging
Glimmer::Config.logger.level = Logger::DEBUG
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
## Resources

* [Code Master Blog](http://andymaleh.blogspot.com/search/label/Glimmer)
* [JRuby Cookbook by Justin Edelson & Henry Liu](http://shop.oreilly.com/product/9780596519650.do)
* [MountainWest RubyConf 2011 Video](https://confreaks.tv/videos/mwrc2011-whatever-happened-to-desktop-development-in-ruby)
* [RubyConf 2008 Video](https://confreaks.tv/videos/rubyconf2008-desktop-development-with-glimmer)
* [InfoQ Article](http://www.infoq.com/news/2008/02/glimmer-jruby-swt)
* [DZone Tutorial](https://dzone.com/articles/an-introduction-glimmer)

## Help

### Issues

You may submit [issues](https://github.com/AndyObtiva/glimmer/issues) on [GitHub](https://github.com/AndyObtiva/glimmer/issues).

[Click here to submit an issue.](https://github.com/AndyObtiva/glimmer/issues)

### IRC Channel

If you need live help, try the [#glimmer](http://widget.mibbit.com/?settings=7514b8a196f8f1de939a351245db7aa8&server=irc.mibbit.net&channel=%23glimmer) IRC channel on [irc.mibbit.net](http://widget.mibbit.com/?settings=7514b8a196f8f1de939a351245db7aa8&server=irc.mibbit.net&channel=%23glimmer). If no one was available, you may [leave a GitHub issue](https://github.com/AndyObtiva/glimmer/issues) to schedule a meetup on IRC. 

[Click here to connect to #glimmer IRC channel immediately via a web interface.](http://widget.mibbit.com/?settings=7514b8a196f8f1de939a351245db7aa8&server=irc.mibbit.net&channel=%23glimmer)

## Feature Suggestions

These features have been suggested. You might see them in a future version of Glimmer. You are welcome to contribute more feature suggestions.

[TODO.md](TODO.md)

## Change Log

[CHANGELOG.md](CHANGELOG.md)

## Contributing

[CONTRIBUTING.md](CONTRIBUTING.md)

## Contributors

* [Andy Maleh](https://github.com/AndyObtiva) (Founder)
* [Dennis Theisen](https://github.com/Soleone) (Contributor)

[Click here to view contributor commits.](https://github.com/AndyObtiva/glimmer/graphs/contributors)

## License

Copyright (c) 2007-2020 Andy Maleh.
See LICENSE.txt for further details.
