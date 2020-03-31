# Glimmer 0.4.8 Beta (JRuby Desktop UI DSL + Data-Binding)
[![Coverage Status](https://coveralls.io/repos/github/AndyObtiva/glimmer/badge.svg?branch=master)](https://coveralls.io/github/AndyObtiva/glimmer?branch=master)

Glimmer is a cross-platform Ruby desktop development library. Glimmer's main innovation is a JRuby DSL that enables easy and efficient authoring of desktop application user-interfaces while relying on the robust platform-independent Eclipse SWT library. Glimmer additionally innovates by having built-in desktop UI data-binding support to greatly facilitate synchronizing the UI with domain models. As a result, that achieves true decoupling of object oriented components, enabling developers to solve business problems without worrying about UI concerns, or alternatively drive development UI-first, and then write clean business components test-first afterward.

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

![Hello World](images/glimmer-hello-world.png)

### Tic Tac Toe

Glimmer code (from `samples/tictactoe/tic_tac_toe.rb`):

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
            @tic_tac_toe_board.mark_box(row, column)
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
glimmer samples/tictactoe/tic_tac_toe.rb
```

Glimmer app:

![Tic Tac Toe](images/glimmer-tic-tac-toe.png)

NOTE: Glimmer is in beta mode. Please help make better by adopting for small or low risk projects and providing feedback.

## Background

Ruby is a dynamically-typed object-oriented language, which provides great productivity gains due to its powerful expressive syntax and dynamic nature. While it is proven by the Ruby on Rails framework for web development, it currently lacks a robust platform-independent framework for building desktop applications. Given that Java libraries can now be utilized in Ruby code through JRuby, Eclipse technologies, such as SWT, JFace, and RCP can help fill the gap of desktop application development with Ruby.

## Platform Support

Glimmer runs on the following platforms:
- Mac
- Windows
- Linux

SWT uses Win32 on Windows, Cocoa on Mac, and GTK on Linux according to Eclipse WIKI:

https://wiki.eclipse.org/SWT/Devel/Gtk/Dev_guide#Win32.2FCocoa.2FGTK

The SWT FAQ has further details:

https://www.eclipse.org/swt/faq.php


## Pre-requisites

* Java SE Runtime Environment 7 or higher (find at https://www.oracle.com/java/technologies/javase-downloads.html)
* JRuby 9.2.10.0 (supporting Ruby 2.5.x syntax) (find at https://www.jruby.org/download)
* SWT 4.14 (comes included in Glimmer)

On **Mac** and **Linux**, an easy way to obtain JRuby is through [RVM](http://rvm.io) by running:

```bash
rvm install jruby-9.2.10.0
```

## Setup

Please follow these instructions to make the `glimmer` command available on your system.

### Option 1: Direct Install

Run this command to install directly:
```
jgem install glimmer -v 0.4.8
```

### Option 2: Bundler

Add the following to `Gemfile`:
```
gem 'glimmer', '~> 0.4.8'
```

And, then run:
```
bundle install
```

## Glimmer Command

Usage:
```
glimmer application.rb
```

Runs a Glimmer application using JRuby, automatically preloading
the glimmer ruby gem and SWT jar dependency.

Example:
```
glimmer samples/hello_world.rb
```
This runs the Glimmer application hello_world.rb

## Girb (Glimmer irb) Command

With Glimmer installed, you may want to run `girb` instead of standard `irb` to have SWT preloaded and the Glimmer library required and included for quick Glimmer coding/testing.

## Glimmer DSL Syntax

### Widgets

Glimmer UIs (user interfaces) are modeled with widgets, which are wrappers around the SWT library widgets found here:

https://www.eclipse.org/swt/widgets/

This screenshot taken from the link above should give a glimpse of how SWT widgets look and feel:

![SWT Widgets](images/glimmer-swt-widgets.png)

In Glimmer DSL, widgets are declared with lowercase underscored names mirroring their SWT names minus the package name:

- `shell` instantiates `org.eclipse.swt.widgets.Shell`
- `text` instantiates `org.eclipse.swt.widgets.Text`
- `button` instantiates `org.eclipse.swt.widgets.Button`
- `label` instantiates `org.eclipse.swt.widgets.Label`
- `composite` instantiates `org.eclipse.swt.widgets.Composite`
- `tab_folder` instantiates `org.eclipse.swt.widgets.TabFolder`
- `tab_item` instantiates `org.eclipse.swt.widgets.TabItem`
- `table` instantiates `org.eclipse.swt.widgets.Table`
- `table_column` instantiates `org.eclipse.swt.widgets.TableColumn`
- `tree` instantiates `org.eclipse.swt.widgets.Tree`
- `combo` instantiates `org.eclipse.swt.widgets.Combo`
- `list` instantiates `org.eclipse.swt.widgets.List`

A **widget** name is followed by a Ruby block that contains the widget **properties** and **content**. Optionally, an SWT **style** ***argument*** may also be passed (see [next section](#widget-styles) for details).

For example, if we were to revisit `samples/hello_world.rb` above:

```ruby
shell {
  text "Glimmer"
  label {
    text "Hello World!"
  }
}.open
```

Note that `shell` instantiates the outer shell **widget**, in other words, the window that houses all of the desktop graphical user interface.

`shell` is then followed by a ***block*** that contains

```ruby
# ...
  text "Glimmer" # text property of shell
  label { # label widget declaration
    text "Hello World!" # text property of label
  }
# ...
```

The first line declares a **property** called `text`, which sets the title of the shell (window) to `"Glimmer"`. **Properties** always have ***arguments***, such as the text `"Glimmer"` in this case, and do **NOT** have a ***block***.

The second line declares the `label` **widget**, which is followed by a Ruby **content** ***block*** that contains its `text` **property** with value `"Hello World!"`

Note that The `shell` widget is always the outermost widget containing all others in a Glimmer desktop windowed application.

After it is declared, a `shell` must be opened with the `#open` method, which can be called on the block directly as in the example above, or by capturing `shell` in a `@shell` variable (shown in example below), and calling `#open` on it independently (recommended in actual apps)

```ruby
@shell = shell {
  # properties and content
  # ...
}
@shell.open
```

It is centered upon initial display and has a minimum width of 130 (can be re-centered when needed with `@shell.center` method after capturing `shell` in a `@shell` variable as per samples)

Check out the [samples](samples) directory for more examples.

Example from [hello_tab.rb](samples/hello_tab.rb) sample:

![Hello Tab 1](images/glimmer-hello-tab1.png)

![Hello Tab 2](images/glimmer-hello-tab2.png)

```ruby
shell {
  text "SWT"
  tab_folder {
    tab_item {
      text "Tab 1"
      label {
        text "Hello World!"
      }
    }
    tab_item {
      text "Tab 2"
      label {
        text "Bonjour Univers!"
      }
    }
  }
}.open
```

#### Video Widget

![Video Widget](images/glimmer-video-widget.png)

Glimmer comes with a video widget not in SWT. It comes with very basic video functionality at the moment, such as autoplay by default, displaying controls, looping, and setting background.

Attributes (passed in an options hash as arguments to video widget):
- `autoplay` (true [default] or false): plays video automatically as soon as loaded
- `controls` (true [default] or false): displays controls
- `looped` (true or false [default]): plays video in looped mode
- `background` (Glimmer color [default: white]): sets background color just like with any other widget
- `fit_to_width` (true [default] or false): fits video width to widget allotted width regardless of video's original size. Maintains video aspect ratio.
- `fit_to_height` (true [default] or false): fits video height to widget allotted height regardless of video's original size. Maintains video aspect ratio.
- `offset_x` (integer [default: 0]): offset from left border. Could be a negative number if you want to show only an area of the video. Useful when fit_to_width is false to pick an area of the video to display.
- `offset_y` (integer [default: 0]): offset from top border. Could be a negative number if you want to show only an area of the video. Useful when fit_to_height is false to pick an area of the video to display.

Methods:
- `play`: plays video
- `pause`: pauses video

Example ([samples/video/hello_video.rb](samples/video/hello_video.rb)):

```ruby
# ...
shell {
  video(file: video_file)
}.open
```

Example ([samples/video/hello_looped_video_with_black_background.rb](samples/video/hello_looped_video_with_black_background.rb)):

```ruby
# ...
shell {
  minimum_size 1024, 640
  video(file: video_file, looped: true, background: :black)
}.open
```

#### Browser Widget

Glimmer supports SWT Browser widget, which can load URLs or render HTML. It can even be instrumented with JavaScript when needed (though highly discouraged in Glimmer except for rare cases when leveraging a pre-existing web codebase in a desktop app).

Example loading a URL:

```ruby
shell {
  minimum_size 1024, 860
  browser {
    url 'http://brightonresort.com/about'
  }
}.open
```

Example rendering HTML with JavaScript on document ready:

```ruby
shell {
  minimum_size 130, 130
  @browser = browser {
    text <<~HTML
      <html>
        <head>
        </head>
        <body>
          <h1>Hello, World!</h1>
        </body>
      </html>
    HTML
    on_completed { # on load of the page execute this JavaScript
      @browser.widget.execute("alert('Hello, World!');")
    }
  }
}.open
```

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

https://help.eclipse.org/2019-12/nftopic/org.eclipse.platform.doc.isv/reference/api/org/eclipse/swt/SWT.html

#### Advanced case outside of standard Glimmer DSL

When building a widget-related SWT object manually (e.g. `GridData.new(...)`), you are expected to use `SWT::CONSTANT` directly or BIT-OR a few SWT constants together like `SWT::BORDER | SWT::V_SCROLL`.

Glimmer facilitates that with `GSWT` class by allowing you to pass multiple styles as an argument array of symbols instead of dealing with BIT-OR. For example: `GSWT[:border, :v_scroll]`

#### Non-resizable Window

SWT Shell widget by default is resizable. To make it non-resizable, one must pass a complicated style bit concoction like `GSWT[:shell_trim] & (~GSWT[:resize]) & (~GSWT[:max])`.

Glimmer makes this easier by alternatively offering `:no_resize` extra SWT style, added for convenience. This makes declaring an non-resizable window as easy as:
```ruby
shell(:no_resize) {
  # ...
}
```

### Widget Properties

Widget properties such as text value, enablement, visibility, and layout details are set within the widget block using methods matching SWT widget property names in lower snakecase. You may refer to SWT widget guide for details on available widget properties:

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

#### Colors

Colors make up a subset of widget properties. SWT accepts color objects created with RGB (Red Green Blue) or RGBA (Red Green Blue Alpha). Glimmer supports constructing color objects using the `rgb` and `rgba` DSL methods.

Example:

```ruby
label {
  background rgb(144, 240, 244)
  foreground rgba(38, 92, 232, 255)
}
```

SWT also supports standard colors available as constants under the `SWT` namespace with the `COLOR_` prefix (e.g. `SWT::COLOR_BLUE`, `SWT::COLOR_WHITE`, `SWT::COLOR_RED`)

Glimmer accepts these constants as lowercase Ruby symbols with or without `color_` prefix.

Example:

```ruby
label {
  background :black
  foreground :yellow
}
label {
  background :color_white
  foreground :color_red
}
```

You may check out all available standard colors in `SWT` over here (having `COLOR_` prefix):

https://help.eclipse.org/2019-12/nftopic/org.eclipse.platform.doc.isv/reference/api/org/eclipse/swt/SWT.html

#### Fonts

Fonts are represented in Glimmer as a hash of name, height, and style keys.

The style can be one (or more) of 3 values: `:normal`, `:bold`, and `:italic`

Example:

```ruby
label {
  font name: 'Arial', height: 36, style: :normal
}
```

Keys are optional, so some of them may be left off.
When passing multiple styles, they are included in an array.

Example:

```ruby
label {
  font style: [:bold, :italic]
}
```

### Layouts

Glimmer lays widgets out visually using SWT layouts, which can only be set on composite widget and subclasses.

The most common SWT layouts are:
- `FillLayout`: lays widgets out in equal proportion horizontally or vertically with spacing/margin options. This is the ***default*** layout for ***shell*** (with `:horizontal` option) in Glimmer.
- `RowLayout`: lays widgets out horizontally or vertically in varying proportions with advanced spacing/margin/justify options
- `GridLayout`: lays widgets out in a grid with advanced spacing/margin/alignment/indentation options. This is the **default** layout for **composite** in Glimmer. It is important to master.

In Glimmer DSL, just like widgets, layouts can be specified with lowercase underscored names followed by a block containing properties, also lowercase underscored names (e.g. `RowLayout` is `row_layout`).

Example:

```ruby
composite {
  row_layout {
    wrap true
    pack false
    justify true
    type :vertical
    margin_left 1
    margin_top 2
    margin_right 3
    margin_bottom 4
    spacing 5
  }
  # ... widgets follow
}
```

Alternatively, a layout may be constructed by following the SWT API for the layout object. For example, a `RowLayout` can be constructed by passing it an SWT style constant (Glimmer automatically accepts symbols (e.g. `:horizontal`) for SWT style arguments like `SWT::HORIZONTAL`.)

```ruby
composite {
  row_layout :horizontal
  # ... widgets follow
}
```

Here is a more sophisticated example taken from [hello_computed.rb](samples/hellocomputed/hello_computed.rb) sample:
```ruby
shell {
  text "Hello Computed"
  composite {
    grid_layout {
      num_columns 2
      make_columns_equal_width true
      horizontal_spacing 20
      vertical_spacing 10
    }
    label {text "First &Name: "}
    text {
      text bind(@contact, :first_name)
      layout_data {
        horizontalAlignment :fill
        grabExcessHorizontalSpace true
      }
    }
    label {text "&Last Name: "}
    text {
      text bind(@contact, :last_name)
      layout_data {
        horizontalAlignment :fill
        grabExcessHorizontalSpace true
      }
    }
    label {text "&Year of Birth: "}
    text {
      text bind(@contact, :year_of_birth)
      layout_data {
        horizontalAlignment :fill
        grabExcessHorizontalSpace true
      }
    }
    label {text "Name: "}
    label {
      text bind(@contact, :name, computed_by: [:first_name, :last_name])
      layout_data {
        horizontalAlignment :fill
        grabExcessHorizontalSpace true
      }
    }
    label {text "Age: "}
    label {
      text bind(@contact, :age, :fixnum, computed_by: [:year_of_birth])
      layout_data {
        horizontalAlignment :fill
        grabExcessHorizontalSpace true
      }
    }
  }
}.open
```

Check out the samples directory for more advanced examples of layouts in Glimmer.

**Defaults**:

Glimmer composites always come with grid_layout by default, but you can still specify explicitly if you'd like to set specific properties on it.

Glimmer shell always comes with fill_layout having :horizontal type.

This is a great guide for learning more about SWT layouts:

https://www.eclipse.org/articles/Article-Understanding-Layouts/Understanding-Layouts.htm

Also, for a reference, check the SWT API:

https://help.eclipse.org/2019-12/nftopic/org.eclipse.platform.doc.isv/reference/api/index.html

### Layout Data

Layouts organize widgets following common rules for all widgets directly under a composite. But, what if a specific widget needs its own rules. That's where layout data comes into play.

By convention, SWT layouts expect widgets to set layout data with a class matching their class name with the word "Data" replacing "Layout":
- `GridLayout` on a composite demands `GridData` on contained widgets
- `RowLayout` on a composite demands `RowData` on contained widgets

Not all layouts support layout data to further customize widget layouts. For example, `FillLayout` supports no layout data.

Unlike widgets and layouts in Glimmer DSL, layout data is simply specified with `layout_data` keyword nested inside a widget block body, and followed by arguments and/or a block of its own properties (lowercase underscored names).

Glimmer automatically deduces layout data class name by convention as per rule above, with the assumption that the layout data class lives under the same exact Java package as the layout (one can set custom layout data that breaks convention if needed in rare cases. See code below for an example)

Glimmer also automatically accepts symbols (e.g. `:fill`) for SWT style arguments like `SWT::FILL`.

Examples:

```ruby
composite {
  row_layout :horizontal
  label {
    layout_data { # followed by properties
      width 50
      height 30
    }
  }
  # ... more widgets follow
}
```

```ruby
composite {
  grid_layout 3, false # grid layout with 3 columns not of equal width
  label {
    # layout data followed by arguments passed to SWT GridData constructor
    layout_data :fill, :end, true, false
  }
}
```

```ruby
composite {
  grid_layout 3, false # grid layout with 3 columns not of equal width
  label {
    # layout data set explicitly via an object (helps in rare cases that break convention)
    layout_data GridData.new(GSWT[:fill], GSWT[:end], true, false)
  }
}
```

**NOTE**: Layout data must never be reused between widgets. Always specify or clone again for every widget.

This is a great guide for learning more about SWT layouts:

https://www.eclipse.org/articles/Article-Understanding-Layouts/Understanding-Layouts.htm

Also, for a reference, check the SWT API:

https://help.eclipse.org/2019-12/nftopic/org.eclipse.platform.doc.isv/reference/api/index.html

### Data-Binding

Data-binding is done with `bind` command following widget property to bind and taking model and bindable attribute as arguments.

Data-binding examples:
- `text bind(contact, :first_name)`
- `text bind(contact, 'address.street')`
- `text bind(contact, 'addresses[1].street')`
- `text bind(contact, :age, computed_by: :date_of_birth)`
- `text bind(contact, :name, computed_by: [:first_name, :last_name])`
- `text bind(contact, 'profiles[0].name', computed_by: ['profiles[0].first_name', 'profiles[0].last_name'])`

The 1st example binds the text property of a widget like `label` to the first name of a contact model.

The 2nd example binds the text property of a widget like `label` to the nested street of
the address of a contact. This is called nested property data binding.

The 3rd example binds the text property of a widget like `label` to the nested indexed address street of a contact. This is called nested indexed property data binding.

The 4th example demonstrates computed value data binding whereby the value of `age` depends on changes to `date_of_birth`.

The 5th example demonstrates computed value data binding whereby the value of `name` depends on changes to both `first_name` and `last_name`.

The 6th example demonstrates nested indexed computed value data binding whereby the value of `profiles[0].name` depends on changes to both nested `profiles[0].first_name` and `profiles[0].last_name`.

Example from [hello_combo.rb](samples/hello_combo.rb) sample:

![Hello Combo](images/glimmer-hello-combo.png)

![Hello Combo](images/glimmer-hello-combo-expanded.png)

```ruby
class Person
  attr_accessor :country, :country_options

  def initialize
    self.country_options=["", "Canada", "US", "Mexico"]
    self.country = "Canada"
  end

  def reset_country
    self.country = "Canada"
  end
end

class HelloCombo
  include Glimmer
  def launch
    person = Person.new
    shell {
      composite {
        combo(:read_only) {
          selection bind(person, :country)
        }
        button {
          text "Reset"
          on_widget_selected do
            person.reset_country
          end
        }
      }
    }.open
  end
end

HelloCombo.new.launch
```

`combo` widget is data-bound to the country of a person. Note that it expects `person` object to have `:country` attribute and `:country_options` attribute containing all available countries.

Example from [hello_list_single_selection.rb](samples/hello_list_single_selection.rb) sample:

![Hello List Single Selection](images/glimmer-hello-list-single-selection.png)

```ruby
shell {
  composite {
    list {
      selection bind(person, :country)
    }
    button {
      text "Reset"
      on_widget_selected do
        person.reset_country
      end
    }
  }
}.open
```

`list` widget is also data-bound to the country of a person similarly to the combo widget. Not much difference here (the rest of the code not shown is the same).

Nonetheless, in the next example, a multi-selection list is declared instead allowing data-binding of multiple selection values to the bindable attribute on the model.

![Hello List Multi Selection](images/glimmer-hello-list-multi-selection.png)

```ruby
class Person
  attr_accessor :provinces, :provinces_options

  def initialize
    self.provinces_options=[
      "",
      "Quebec",
      "Ontario",
      "Manitoba",
      "Saskatchewan",
      "Alberta",
      "British Columbia",
      "Nova Skotia",
      "Newfoundland"
    ]
    self.provinces = ["Quebec", "Manitoba", "Alberta"]
  end

  def reset_provinces
    self.provinces = ["Quebec", "Manitoba", "Alberta"]
  end
end

class HelloListMultiSelection
  include Glimmer
  def launch
    person = Person.new
    shell {
      composite {
        list(:multi) {
          selection bind(person, :provinces)
        }
        button {
          text "Reset"
          on_widget_selected do
            person.reset_provinces
          end
        }
      }
    }.open
  end
end

HelloListMultiSelection.new.launch
```

The Glimmer code is not much different from above except for passing the `:multi` style to the `list` widget. However, the model code behind the scenes is quite different as it is a `provinces` array bindable to the selection of multiple values on a `list` widget. `provinces_options` contains all available province values just as expected by a single selection `list` and `combo`.

Note that in all the data-binding examples above, there was also an observer attached to the `button` widget to trigger an action on the model, which in turn triggers a data-binding update on the `list` or `combo`. Observers will be discussed in more details in the [next section](#observer).

You may learn more about Glimmer's data-binding syntax by reading the [Eclipse Zone Tutorial](http://eclipse.dzone.com/articles/an-introduction-glimmer) mentioned in resources and opening up the samples under the [samples](samples) directory.

### Observer

Glimmer comes with `Observer` module, which is used internally for data-binding, but can also be used externally for custom use of the Observer Pattern. It is hidden when observing widgets, and used explicitly when observing models.

#### Observing Widgets

Glimmer supports observing widgets with an `on_*event*` declaration where the '*event*' part is replaced with the lowercase underscored name of an SWT listener event method.

To figure out what the available events for an SWT widget are, check out all of its API methods starting with `add` and ending with `Listener`, and then open the listener class to check its "event methods".

For example, if you look at the `Button` SWT API:
https://help.eclipse.org/2019-12/index.jsp?topic=%2Forg.eclipse.platform.doc.isv%2Freference%2Fapi%2Forg%2Feclipse%2Fswt%2Fbrowser%2FBrowser.html

It has `addSelectionListener`. Additionally, under its `Control` super class, it has `addControlListener`, `addDragDetectListener`, `addFocusListener`, `addGestureListener`, `addHelpListener`, `addKeyListener`, `addMenuDetectListener`, `addMouseListener`, `addMouseMoveListener`, `addMouseTrackListener`, `addMouseWheelListener`, `addPaintListener`, `addTouchListener`, and `addTraverseListener`

Suppose, we select `addSelectionListener`, which is responsible for what happens when a user selects a button (clicks it). Then, open its argument `SelectionListener` SWT API, and you find the event (instance) methods: `widgetDefaultSelected` and `widgetSelected​`. Let's select the second one, which is what gets invoked when a button is clicked.

Now, Glimmer simplifies the process of hooking into that listener (observer) by neither requiring you to call the `addSelectionListener` method nor requiring you to implement/extend the `SelectionListener` API.

Instead, simply add a `on_widget_selected` followed by a Ruby block containing the logic to perform. Glimmer figures out the rest.

Let's revisit the Tic Tac Toe example shown near the beginning of the page:

```ruby
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
            @tic_tac_toe_board.mark_box(row, column)
          }
        }
      }
    }
  }
}
```

Note that every Tic Tac Toe grid cell has its `text` and `enabled` properties data-bound to the `sign` and `empty` attributes on the `TicTacToeBoard` model respectively.

Next however, each of these Tic Tac Toe grid cells, which are clickable buttons, have an `on_widget_selected` observer, which once triggered, marks the box (cell) on the `TicTacToeBoard` to make a move.

#### Observing Models

The class that needs to observe a model object must include (mix in) the `Observer` module and implement the `#call(new_value)` method. The class to be observed doesn't need to do anything. It will automatically be enhanced by Glimmer for observation.

To register observer, one has to call the `#observe` method and pass in the observable and the property(ies) to observe.

```ruby
class TicTacToe
  include Glimmer
  include Observer

  def initialize
    # ...
    observe(@tic_tac_toe_board, :game_status)
  end

  def call(game_status)
    display_win_message if game_status == TicTacToeBoard::WIN
    display_draw_message if game_status == TicTacToeBoard::DRAW
  end
  # ...
end
```

Alternatively, one can use a default Observer::Proc implementation via Observer.proc method:
```ruby
observer = Observer.proc { |new_value| puts new_value }
observer.observe(@tic_tac_toe_board, :game_status)
```

Observers can be a good mechanism for displaying dialog messages with Glimmer (using SWT's `MessageBox`).

Look at `samples/tictactoe/tic_tac_toe.rb` for an `Observer` dialog message example (sample below).

```ruby
class TicTacToe
  include Glimmer
  include Observer

  def initialize
    # ...
    observe(@tic_tac_toe_board, :game_status)
  end

  def call(game_status)
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
  # ...
end
```

### Custom Widgets

Glimmer supports creating custom widgets with minimal code, which automatically extends Glimmer's DSL syntax with an underscored lowercase keyword.

Simply create a new class that includes `Glimmer::SWT::CustomWidget` and put Glimmer DSL code in its `#body` method (its return value is stored in `#body_root` attribute). Glimmer will then automatically recognize this class by convention when it encounters a keyword matching the class name converted to underscored lowercase (and namespace double-colons `::` replaced with double-underscores `__`)

**Example:**

Definition:
```ruby
class RedLabel
  include Glimmer::SWT::CustomWidget

  def body
    label(swt_style) {
      background :red
    }
  end
end
```

Usage:
```ruby
shell {
  red_label {
    text 'Red Label'
  }
}
```

As you can see, `RedLabel` became Glimmer DSL keyword: `red_label`

**Another Example:**

Definition:
```ruby
module Red
  class Composite
    include Glimmer::SWT::CustomWidget

    def body
      composite(swt_style) {
        background :red
      }
    end
  end
```

Usage:
```ruby
shell {
  red__composite {
    label {
      foreground :white
      text 'This is showing inside a Red Composite'
    }
  }
}
```

Notice how `Red::Composite` became `red__composite` with double-underscore, which is how Glimmer Custom Widgets signify namespaces by convention.

Custom Widgets have the following attributes (attribute readers) available to call from inside the `#body` method:
- `#parent`: Glimmer object parenting custom widget
- `#swt_style`: SWT style integer. Can be useful if you want to allow consumers to customize a widget inside the custom widget body
- `#options`: a hash of options passed in parentheses when declaring a custom widget (useful for passing in model data) (e.g. `calendar(events: events)`). Custom widget class can declare option names (array) with `.options` method as shown below, which generates attribute readers for every option (not to be confused with `#options` instance method for retrieving options hash containing names & values)
- `#content`: nested block underneath custom widget. It will be automatically called at the end of processing the custom widget body. Alternatively, the custom widget body may call `content.call` at the place where the content is needed to show up as shown in the following example.

Additionally, custom widgets can call the following class methods:
- `.options`: declares a list of options by taking an option name array (symbols/strings). This generates option attribute readers (e.g. `options :orientation, :bg_color` generates `#orientation` and `#bg_color` attribute readers)
- `.option`: declares a single option taking option name and default value as arguments (also generates an attribute reader just like `.options`)

**Content/Options Example:**

Definition:
```ruby
class Sandwich
  include Glimmer::SWT::CustomWidget

  options :orientation, :bg_color
  option :fg_color, :black

  def body
    composite(swt_style) { # gets custom widget style
      fill_layout orientation # using orientation option
      background container_background # using container_background option
      label {
        text 'SANDWICH TOP'
      }
      content.call # this is where content block is called
      label {
        text 'SANDWICH BOTTOM'
      }
    }
  end
end
```

Usage:
```ruby
shell {
  sandwich(:no_focus, orientation: :horizontal, bg_color: :white) {
    label {
      text 'SANDWICH CONTENT'
    }
  }
}
```

Notice how `:no_focus` was the `swt_style` value, followed by the `options` hash `{orientation: :horizontal, bg_color: :white}`, and finally the `content` block containing the label with `'SANDWICH CONTENT'`

The following additional attributes may be called from outside a custom widget in addition to the attributes mentioned above, assuming it's been captured in a variable:
- `#body_root`: top-most root Glimmer widget returned in `#body` method
- `#widget`: actual SWT widget for `body_root`


## Samples

Check the [samples](samples) directory for examples on how to write Glimmer applications. To run a sample, make sure to install the `glimmer` gem first and then use the `glimmer` command to run it (alternatively, you may clone the repo, follow [CONTRIBUTING.md](CONTRIBUTING.md) instructions, and run samples locally with development glimmer command: `bin/glimmer --dev`).

Examples:

```
glimmer samples/hello_tab.rb
glimmer samples/hello_combo.rb
glimmer samples/hello_list_single_selection.rb
glimmer samples/hello_list_multi_selection.rb
glimmer samples/contactmanager/contact_manager.rb
```

The last example (`contact_manager.rb`) is a good sample about how to build tables with Glimmer including data-binding, filtering, and sorting. It even comes with specs in `spec/samples/contactmanager/contact_manager_presenter_spec.rb` to demonstrate how Glimmer facilitates TDD (test-driven development) with the Model View Presenter pattern (a variation on MVC) by separating testable presentation logic from the view layer with data-binding.

For a more elaborate project built with Glimmer, check out this educational game:

[Math Bowling](https://github.com/AndyObtiva/MathBowling)

## SWT Reference

https://www.eclipse.org/swt/docs.php

Here is the SWT API:

https://help.eclipse.org/2019-12/nftopic/org.eclipse.platform.doc.isv/reference/api/index.html

Here is a visual list of SWT widgets:

https://www.eclipse.org/swt/widgets/

Here is a textual list of SWT widgets:

https://help.eclipse.org/2019-12/topic/org.eclipse.platform.doc.isv/guide/swt_widgets_controls.htm?cp=2_0_7_0_0

Here is a list of SWT style bits:

https://wiki.eclipse.org/SWT_Widget_Style_Bits

## SWT Packages

Glimmer automatically imports all SWT Java packages upon adding `include Glimmer` to a class or module.

Still, if you'd like to import manually elsewhere, you may add the following lines to your code (in the class or module body) to import SWT Java packages using `include_package`:

```ruby
include_package 'org.eclipse.swt'
include_package 'org.eclipse.swt.widgets'
include_package 'org.eclipse.swt.layout'
include_package 'org.eclipse.swt.graphics'
```

To import a specific SWT Java class using `java_import`, add the following:

```ruby
java_import 'org.eclipse.swt.SWT'
```

This allows you to call SWT Java classes from Ruby without mentioning package namespaces.

For example, after imports, `org.eclipse.swt.graphics.Color` can be referenced by just `Color`

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

## Resources

* [Eclipse Zone Tutorial](http://eclipse.dzone.com/articles/an-introduction-glimmer)
* [InfoQ Article](http://www.infoq.com/news/2008/02/glimmer-jruby-swt)
* [RubyConf 2008 Video](https://confreaks.tv/videos/rubyconf2008-desktop-development-with-glimmer)
* [Code Blog](http://andymaleh.blogspot.com/search/label/Glimmer)

## Feature Suggestions

These features have been suggested. You might see them in a future version of Glimmer. You are welcome to contribute more feature suggestions.

[TODO.md](TODO.md)

## Change Log

[CHANGELOG.md](CHANGELOG.md)

## Contributing

[CONTRIBUTING.md](CONTRIBUTING.md)

## Contributors

* Andy Maleh (Founder)
* Dennis Theisen

## License

Copyright (c) 2007-2020 Andy Maleh.
See LICENSE.txt for further details.
