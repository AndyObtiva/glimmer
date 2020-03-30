# TODO

Here is a list of tasks to do (please delete once done):

Up Next:

- Video custom widget
- Girb update to include Glimmer

## Feature Suggestions
- Image custom widget
- Glimmer Application: provide a standard structure for building a Glimmer app
- Scaffold a Glimmer app
- Glimmer Wizard: provide a standard structure for building a Glimmer wizard (multi-step/multi-screen process)
- bind_collection: an iterator that enables spawning widgets based on a variable collection (e.g. `bind_collection('user.addresses') { |address| address_widget {...} }` spawns 3 `AddressWidget`s if `user.addresses` is set with 3 addresses; and replaces with 2 `AddressWidget`s if `user.addresses` is reset with 2 addresses only). Needs further thought on naming and functionality.
- Automatic relayout of "glimmer components" when disposing one or as an option
- Consider easy rerendering support for Glimmer upon processing events
- Support re-rendering when updating a layout file for development.
- Add TruffleRuby support
- Provide friendly error messages for all failures
- Update setBackgroundImage to take an image path string for convenience (instead of an SWT image)
- Update setBackgroundImage to support animated gif images
- Support a new Glimmer widget background_video property

## Technical Tasks

- Support Tree databinding (bidirectional)
- Figure out what is missing from table databinding (bidirectional?)
- Explore rewriting shine with Ruby 2 support
- Add a startup progress dialog (consider Glimmer branding)
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

## Documentation Tasks
- Document G*** classes like GWidget and GShell
- Document "#widget" method on GWidget
- Document Glimmer.add_contents
- Document custom widget custom attributes/observers
- Explain MVC and MVP
- Double down on using the wording property vs attribute to minimize confusion
- document async_exec and sync_exec
