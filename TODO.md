# TODO

Here is a list of tasks to do (please delete once done):

## Up Next

- Make WidgetProxys and custom widgets proxy method calls to wrapped widget
- Correct attribute/property naming (unify as attributes)
- Recapture all of readme's sample screenshots on Mac, Windows, and Linux (except the general widget listing for now)
- Provide girb option to run without including Glimmer. Useful when testing an application that is not a "hello, world!" sort of example
- Image custom widget similar to video, and supporting gif
- Scaffold a Glimmer app: provide a standard structure for building a Glimmer app (models, views, and assets [images, videos, sounds])
- Scaffold a View/View-Model pair
- Scaffold a custom widget
- Scaffold a custom shell
- Implement Glimmer sample launcher
- Add Glossary


## Feature Suggestions
- Glimmer Wizard: provide a standard structure for building a Glimmer wizard (multi-step/multi-screen process)
- bind_collection: an iterator that enables spawning widgets based on a variable collection (e.g. `bind_collection('user.addresses') { |address| address_widget {...} }` spawns 3 `AddressWidget`s if `user.addresses` is set with 3 addresses; and replaces with 2 `AddressWidget`s if `user.addresses` is reset with 2 addresses only). Needs further thought on naming and functionality.
Another idea:
bind(model, 'addresses').each { |address|
  label {
    bind(address, :street)
  }
  label {
    bind(address, :zip)    
  }
}
- Automatic relayout of "glimmer components" when disposing one or as an option
- Consider easy rerendering support for Glimmer upon processing events
- Support re-rendering when updating a layout file for development.
- Provide friendly error messages for all failures

## Technical Tasks

- Support Tree databinding in the other direction (from tree update to model)
- Figure out what is missing from table databinding (bidirectional?)
- Explore rewriting shine with Ruby 2 support
- Consider need for a startup progress dialog (with Glimmer branding)
- Externalize constants to make easily configurable
- Extract ListenerParent into its own file from WidgetListenerCommandHandler
- Enhance XML DSL support (special characters, CDATA, escaped characters (#, {, }, .))
- Build a sample demonstrating how to use Glimmer from Java only for the View layer in a desktop MVC SWT app
- Support data binding translator option via a block
- Simplify API for async_exec and sync_exec (putting directly on Glimmer)
- Restore badges for README
- Look into what to do regarding Glimmer silent failures (when things fall off the chain of command)
- Check for need to recursively call dispose on widget descendants
- Report a friendly error message for  can't modify frozen NilClass when mistakenly observing a nil model instead of doing a nested bind(self, 'model.property')
- Support method_name? methods in data-binding just like standard attr readers
- Provide general DSL to construct any object with Glimmer even if not a widget. Useful for easily setting style_range on a StyledText widget. Maybe make it work like layout_data where it knows type to instantiate automatically. With style_range, that's easy since it can be inferred from args.
- Consider implementing Glimmer.app_dir as Pathname object referring to app root path of Glimmer application project (not Glimmer library)
- Consider implementing Glimmer.__lib_dir__ as Pathname object referring to root path of Glimmer library
- Support publishing a Glimmer app as a Mac/Windows/Linux executable or installer quickly and easily via a command (https://github.com/jruby/jruby/wiki/StandaloneJarsAndClasses - https://github.com/jruby/warbler - https://docs.oracle.com/javase/8/docs/technotes/guides/deploy/packager.html ) See if there is anything to contribute to JRuby in the process
- Support a Glimmer custom widget (custom shell) publishing/consumption mechanism that bypasses Ruby gems by pre-downloading their code directly by convention of custom widget name and github repository name (e.g. containing word glimmer or a special prefix like 'glimmer_public__some_widget_name'). Also, gets packaged when shipping a product or a gem. This should make 100s if not 1000s of widget available very easily online as authors won't be required beyond following a GitHub hosting convention from creating Ruby gems
- Support a Glimmer ruby gem generator for custom widgets to easily and quickly wrap and publish as a Ruby gem if desired (despite option of github convention consumption mentioned above)
- Put Glimmer on Travis CI and test on many platforms and with many jruby versions
- Get rid of dispose widget error upon quitting a Glimmer app
- Make observers 'method?' friendly
- Compose ModelBinding out of another ModelBinding (nesting deeper)
- add a `#shell` method to WidgetProxy and custom widget classes to get ShellProxy containing them (or custom shell [think about the implications of this one])
- Support proper `dispose` of widgets across the board (already support garbage collecting observers upon dispose... check if anything else is missing, like nested widget disposal)
- Support reading Bundler Gemfile in glimmer command if available

## Documentation Tasks
- Document custom widget custom properties/observers
- Document how to build 3rd party library custom widgets and custom shells for distribution and consumption
- Explain MVC and MVP
- Double down on using the wording property vs attribute to minimize confusion
- Document async_exec and sync_exec
- Document example of using an external Java SWT custom widget by importing its java package directly to do the trick
- Make a video documenting how to build Tic Tac Toe (no AI) step by step
- Document on_ SWT event listeners for events declared on SWT constant like show and hide
- Document Glimmer DSL in full detail by generating translated documentation from SWT API (write a program) and adding to it
