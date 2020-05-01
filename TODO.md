# TODO

Here is a list of tasks to do (please delete once done):

## Up Next

- Scaffold a Glimmer app: provide a standard structure for building a Glimmer app (models, views, and assets [images, videos, sounds])
- Scaffold a Glimmer custom widget gem
- Make girb "include Glimmer" into the main object automatically
- Support deconfiguring DSLs
- Extract Video widget into its own glimmer-video gem
- Extract Gladiator into its own glimmer-gladiator gem
- Support web UIs via Opal Ruby (https://github.com/opal/opal)

## Gladiator (Glimmer Editor)

- Fix issue with Find not working for more than one occurrence in a line
- Fix issue with file lookup list and file explorer tree not showing up upon launching in a new directory until resizing window
- Fix issue with line numbers not scrolling perfectly along with open file (off by a few pixels)
- Fix issue with line numbers sometimes getting clipped when openig a new file until resizing window
- Fix issue with not autosaving right away when making changes with Find/Replace (until focusing in and out of text editor area)
- Implement Undo/Redo (it partially works right now from text widget built-in undo/redo)

## Soon

- DSL syntax for MessageBox
message_box {
  text 'Red Label'
  message 'This is a red label'
}.open
- DSL syntax for dialogs
- Support publishing a Glimmer app for Windows (exe file)
- Support publishing a Glimmer app for Linux
(https://github.com/jruby/jruby/wiki/StandaloneJarsAndClasses - https://github.com/jruby/warbler - https://docs.oracle.com/javase/8/docs/technotes/guides/deploy/packager.html )

## Feature Suggestions
- Glimmer Wizard: provide a standard structure for building a Glimmer wizard (multi-step/multi-screen process)
- bind_content: an iterator that enables spawning widgets based on a variable collection (e.g. `bind_content('user.addresses').each { |address| address_widget {...} }` spawns 3 `AddressWidget`s if `user.addresses` is set with 3 addresses; and replaces with 2 `AddressWidget`s if `user.addresses` is reset with 2 addresses only). Needs further thought on naming and functionality.
Another idea in which each is triggered upon every update to bind's content:
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
- Image custom widget similar to video, and supporting gif
- Automatic relayout of glimmer widgets (or parent widget) when disposing a widget (or as an option when disposing)
- Scroll bar listener support
- Web Support (e.g. via Opal?)
- Make Glimmer defaults configurable

## Technical Tasks

- Support Tree databinding in the other direction (from tree update to model)
- Improve tree databinding so that replacing content array value still updates the tree (instead of clearing and readding elements)
- Figure out what is missing from table databinding (bidirectional?)
- Explore rewriting shine with Ruby 2 support
- Consider need for a startup progress dialog (with Glimmer branding)
- Externalize constants to make easily configurable
- Restore badges for README
- Check for need to recursively call dispose on widget descendants
- Report a friendly error message for  can't modify frozen NilClass when mistakenly observing a nil model instead of doing a nested bind(self, 'model.property')
- Provide general DSL to construct any object with Glimmer even if not a widget. Useful for easily setting style_range on a StyledText widget. Maybe make it work like layout_data where it knows type to instantiate automatically. With style_range, that's easy since it can be inferred from args.
- Consider implementing Glimmer.app_dir as Pathname object referring to app root path of Glimmer application project (not Glimmer library)
- Support a Glimmer custom widget (custom shell) publishing/consumption mechanism that bypasses Ruby gems by pre-downloading their code directly by convention of custom widget name and github repository name (e.g. containing word glimmer or a special prefix like 'glimmer_public__some_widget_name'). Also, gets packaged when shipping a product or a gem. This should make 100s if not 1000s of widget available very easily online as authors won't be required beyond following a GitHub hosting convention from creating Ruby gems
- Support a Glimmer ruby gem generator for custom widgets to easily and quickly wrap and publish as a Ruby gem if desired (despite option of github convention consumption mentioned above)
- Put Glimmer on Travis CI and test on many platforms and with many jruby versions
- Get rid of dispose widget error upon quitting a Glimmer app
- Make observers 'method?' friendly
- Compose ModelBinding out of another ModelBinding (nesting deeper)
- add a `#shell` method to WidgetProxy and custom widget classes to get ShellProxy containing them (or custom shell [think about the implications of this one])
- Support proper `dispose` of widgets across the board (already support garbage collecting observers upon dispose... check if anything else is missing, like nested widget disposal)
- Support reading Bundler Gemfile in glimmer command if available
- Support question mark ending data-binding properties
- Automatically repack parent when data-binding layout or layout data properties have changes
- consider detecting type on widget property method and automatically invoking right converter (e.g. :to_s for String text property, :to_i for Integer property, etc...)
- Check into issues of closing a shell and repasting its code in girb
- Provide girb option to run without including Glimmer. Useful when testing an application that is not a "hello, world!" sort of example
- Correct attribute/property naming (unify as attributes)
- Make WidgetProxy and custom widgets proxy method calls to wrapped widget
- Implement a Graphical Glimmer sample launcher
- Support => syntax for computed_for data-binding
- Support data binding boolean properties ending with ? bidirectionally (already supported for read-only)
- Add popups to Gladiator showing the shortcut of each field (e.g. CMD+L for Line)
- Support XML Top-Level Static Expression (xml { })
- Support XML DSL comments <!-- COMMENT -->
- Support XML Document Declaration Tag: <?xml version="1.0" encoding="UTF-8" standalone="no" ?>
- Support HTML Doctype Declaration <!DOCTYPE html>

## Samples

- Scientific Calculator
- Business Accounting app
- HR Employee Management app
- Medical Patient Management app

## Documentation Tasks

- Recapture all of readme's sample screenshots on Mac, Windows, and Linux (except the general widget listing for now)
- Add Glossary
- Document custom widget custom properties/observers
- Document how to build 3rd party library custom widgets and custom shells for distribution and consumption
- Explain MVC and MVP
- Double down on using the wording property vs attribute to minimize confusion
- Document async_exec and sync_exec
- Document example of using an external Java SWT custom widget by importing its java package directly to do the trick
- Make a video documenting how to build Tic Tac Toe (no AI) step by step
- Document on_ SWT event listeners for events declared on SWT constant like show and hide
- Document Glimmer DSL in full detail by generating translated documentation from SWT API (write a program) and adding to it
- Document how to use Glimmer as the View layer only of a Java app rebuilding tic tac toe following that kind of application architecture.
