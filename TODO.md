# TODO

Here is a list of tasks to do (please delete once done):

## Up Next

- Handle focus on display of a CustomShell
- Add visible observable event to GShell and CustomShell and making Glimmer accept working with such custom events on top of SWT listener events
- Make `glimmer` command work with Bundler to grab glimmer only if Gemfile is available
- Support CustomWidget before_body and after_body hooks
- Support CustomShell before_open/before_show and after_open/after_show hooks
- Support CustomShell before_hide and after_hide hooks (taking close into account in hide)
- Fix issue requiring us to include Glimmer again in CustomShell to get SWT packages included (consider making SwtPackages a super_module) [perhaps fix super_module bugs/limitations?]
- Update setBackgroundImage to take an image path string for convenience (instead of an SWT image)

## Feature Suggestions
- Image custom widget
- Glimmer Application: provide a standard structure for building a Glimmer app (models, views, and assets [images, videos, sounds])
- Scaffold a Glimmer app
- Glimmer Wizard: provide a standard structure for building a Glimmer wizard (multi-step/multi-screen process)
- bind_collection: an iterator that enables spawning widgets based on a variable collection (e.g. `bind_collection('user.addresses') { |address| address_widget {...} }` spawns 3 `AddressWidget`s if `user.addresses` is set with 3 addresses; and replaces with 2 `AddressWidget`s if `user.addresses` is reset with 2 addresses only). Needs further thought on naming and functionality.
- Automatic relayout of "glimmer components" when disposing one or as an option
- Consider easy rerendering support for Glimmer upon processing events
- Support re-rendering when updating a layout file for development.
- Provide friendly error messages for all failures
- Provide girb option to run without including Glimmer. Useful when testing an application that is not a hello world sort of example

## Technical Tasks

- Support Tree databinding (bidirectional)
- Figure out what is missing from table databinding (bidirectional?)
- Explore rewriting shine with Ruby 2 support
- Consider need for a startup progress dialog (with Glimmer branding)
- Externalize constants to make easily configurable
- Extract ListenerParent into its own file from WidgetListenerCommandHandler
- Enhance XML DSL support (special characters, CDATA, escaped characters (#, {, }, .))
- Build a sample demonstrating how to use Glimmer from Java only for the View layer in a desktop MVC SWT app
- Support data binding translator option via a block
- Consider using Ruby Refinements for Glimmer
- Simplify API for add_contents (putting directly on widgets)
- Simplify API for async_exec and sync_exec (putting directly on Glimmer)
- Restore badges for README
- Look into what to do regarding Glimmer silent failures (when things fall off the chain of command)
- Support on_*** observers on GWidget's directly without using add_contents
- Check for need to recursively call dispose on widget descendants
- Support Glimmer DSL observe keyword
- Report a friendly error message for  can't modify frozen NilClass when mistakenly observing a nil model instead of doing a nested bind(self, 'model.property')
- Support method_name? methods in data-binding just like standard attr readers
- Decide on whether to continue to pass a widget var to blocks or give them access to widget parent through parent method
- Provide general DSL to construct any object with Glimmer even if not a widget. Useful for easily setting style_range on a StyledText widget. Maybe make it work like layout_data where it knows type to instantiate automatically. With style_range, that's easy since it can be inferred from args.
- Consider implementing Glimmer.app_dir as Pathname object referring to app root path of Glimmer application project (not Glimmer library)
- Consider implementing Glimmer.__lib_dir__ as Pathname object referring to root path of Glimmer library
- Support publishing a Glimmer app as a Mac/Windows/Linux executable or installer quickly and easily via a command (https://github.com/jruby/jruby/wiki/StandaloneJarsAndClasses - https://github.com/jruby/warbler - https://docs.oracle.com/javase/8/docs/technotes/guides/deploy/packager.html ) See if there is anything to contribute to JRuby in the process
- Support a Glimmer custom widget (custom shell) publishing/consumption mechanism that bypasses Ruby gems by pre-downloading their code directly by convention of custom widget name and github repository name (e.g. containing word glimmer or a special prefix like 'glimmer_public__some_widget_name'). Also, gets packaged when shipping a product or a gem. This should make 100s if not 1000s of widget available very easily online as authors won't be required beyond following a GitHub hosting convention from creating Ruby gems
- Support a Glimmer ruby gem generator for custom widgets to easily and quickly wrap and publish as a Ruby gem if desired (despite option of github convention consumption mentioned above)
- Put Glimmer on Travis CI and test on many platforms and with many jruby versions
- Get rid of dispose widget error upon quitting a Glimmer app

## Documentation Tasks
- Document G*** classes like GWidget and GShell
- Document Glimmer.add_contents
- Document custom widget custom attributes/observers
- Document how to build 3rd party library custom widgets and custom shells for distribution and consumption
- Explain MVC and MVP
- Double down on using the wording property vs attribute to minimize confusion
- Document async_exec and sync_exec
- Document example of using an external Java SWT custom widget by importing its java package directly to do the trick
- Document Glimmer::Launcher
