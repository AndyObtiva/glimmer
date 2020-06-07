# TODO

Here is a list of tasks to do (moved to CHANGELOG.md once done). 

## Next

### Next Revision (TBD)

### Next Minor Version (0.8.2)

- Support table single selection databinding
- Support table cell editing databinding
- Support table multi selection databinding

### Next Major Version (TBD)

N/A

## Feature Suggestions
- Glimmer Wizard: provide a standard structure for building a Glimmer wizard (multi-step/multi-screen process)
- bind_content: an iterator that enables spawning widgets based on a variable collection (e.g. `bind_content('user.addresses').each { |address| address_widget {...} }` spawns 3 `AddressWidget`s if `user.addresses` is set with 3 addresses; and replaces with 2 `AddressWidget`s if `user.addresses` is reset with 2 addresses only). Needs further thought on naming and functionality.
Another idea in which each is triggered upon every update to bind's content:
```ruby
bind_content(model, 'username') { |username|
  label {
    text username
  }
}

bind_content(model, 'addresses').each { |address|
  label {
    bind(address, :street)
  }
  label {
    bind(address, :zip)    
  }
}
```
- Image custom widget similar to video, and supporting gif
- Scroll bar listener support
- Extract FileTree Glimmer Custom widget from Gladiator
- Support Cygwin with glimmer command

## Issues

- Fix issue with not being able to data-bind layout data like exclude (often done along with visiblity on the widget)

## Technical Tasks

- Explore supporting new Shine data-binding syntax (data-binding with spaceship operator <=>):
```ruby
items <=> 'model.property' # bidirectional
items <= 'model.property' # ready-only
items <=> binding('model.property') # bidirectional explicit binding
items <= binding('model.property') # ready-only explicit binding
items <= binding('model.property') {|x| x + 2} # read-only explicit binding with converter
items <=> binding('model.property') { # bidirectional explicit binding on_read/on_write converters
  on_read {|v| !v}
  on_write {|v| !v}
}
items <=> binding {
  path 'model.property'
  on_read {|v| !v}
  on_write {|v| !v}
}
```
- Improve tree databinding so that replacing content array value updates the tree (instead of clearing and rereading elements)
- Consider need for a startup progress dialog (with Glimmer branding)
- Externalize constants to make easily configurable
- Check for need to recursively call dispose on widget descendants
- Report a friendly error message for  can't modify frozen NilClass when mistakenly observing a nil model instead of doing a nested bind(self, 'model.property')
- Provide general DSL to construct any object with Glimmer even if not a widget. Useful for easily setting style_range on a StyledText widget. Maybe make it work like layout_data where it knows type to instantiate automatically. With style_range, that's easy since it can be inferred from args.
- Consider implementing Glimmer.app_dir as Pathname object referring to app root path of Glimmer application project (not Glimmer library)
- Get rid of dispose widget error upon quitting a Glimmer app
- Make observers 'method?' friendly
- Compose ModelBinding out of another ModelBinding (nesting deeper)
- add a `#shell` method to WidgetProxy and custom widget classes to get ShellProxy containing them (or custom shell [think about the implications of this one])
- Support proper `dispose` of widgets across the board (already supporting garbage collecting observers upon dispose... check if anything else is missing, like nested widget disposal)
- consider detecting type on widget property method and automatically invoking right converter (e.g. :to_s for String text property, :to_i for Integer property, etc...)
- Provide girb option to run without including Glimmer. Useful when testing an application that is not a "hello, world!" sort of example
- Correct attribute/property naming (unify as attributes)
- Make WidgetProxy and custom widgets proxy method calls to wrapped widget
- Implement a Graphical Glimmer sample launcher
- Support `=>` syntax alternative for `computed_by` data-binding
- Support data binding boolean properties ending with ? bidirectionally (already supported for read-only)
- Support XML Top-Level Static Expression (xml { })
- Support XML DSL comments <!-- COMMENT -->
- Support XML Document Declaration Tag: <?xml version="1.0" encoding="UTF-8" standalone="no" ?>
- Support HTML Doctype Declaration <!DOCTYPE html>
- Extract SWT DSL into its own glimmer-dsl-swt gem
- Extract XML DSL into its own glimmer-dsl-xml gem
- Extract CSS DSL into its own glimmer-dsl-css gem
- Log to SysLog using this gem: https://www.rubydoc.info/gems/syslog-logger/1.6.8
- Implement Glimmer#respond_to? to accommodate method_missing
- Support the idea of application pre-warm up where an app is preloaded and shows up right away from launched
- Support data-binding shell size and location
- Support data-bind two widget attributes to each other
- Generate rspec test suite for app scaffolding
- Support eager/lazy/manual loading of SWT packages/classes. Give consumers the option to use eager (java_import), lazy (include_package), or manual, to be done in their apps.
- Consider dropping duality of data-binding syntax: bind(model, 'property'). Unify by always using bind('model.property') instead, which is simpler and better as it supports the case of model being nil starting with self as the model.
- Automatic relayout of glimmer widgets (or parent widget) when disposing a widget (or as an option when disposing)
- Make Glimmer defaults configurable
- Ensure support for packaging on Windows (exe file)
- Ensure support for packaging on Linux
- Refactor entire codebase to get rid of Java getters/setters in favor of Ruby attributes

## Samples

- HR Employee Management app
- Medical Patient Management app
- Business Accounting app

## Side Projects

### opal-spike branch

- Support web UIs via Opal Ruby (https://github.com/opal/opal)
- Support porting an existing Glimmer SWT app into a web app with very little effort

### glimmertalk project

- Build a Smalltalk-like Ruby app to allow people to build and edit GUI apps without restarting

## Documentation Tasks

- Recapture all of readme's sample screenshots on Mac, Windows, and Linux (except the general widget listing for now)
- Add Glossary
- Document custom widget custom properties/observers
- Explain MVC and MVP
- Double down on using the wording property vs attribute to minimize confusion
- Document async_exec and sync_exec
- Document example of using an external Java SWT custom widget by importing its java package directly to do the trick
- Make a video documenting how to build Tic Tac Toe (no AI) step by step
- Document on_ SWT event listeners for events declared on SWT constant like show and hide
- Document Glimmer DSL in full detail by generating translated documentation from SWT API (write a program) and adding to it
- Document how to use Glimmer as the View layer only of a Java app rebuilding tic tac toe following that kind of application architecture.
- Document structure of a glimmer app as generated by scaffold command
- Add screenshots for every sample project (under various operating systems)
- Document different Windows setup alternatives like standard CMD, Git Bash, Cygwin, and Ubuntu Bash Sybsystem
