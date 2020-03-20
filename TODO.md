# TODO

Here is a list of tasks to do (please delete once done):

## Feature Suggestions
- Glimmer Application: provide a standard structure for building a Glimmer app
- Glimmer Component: Glimmer already supports components by externalizing to objects, but it would be good if there is a module to include so Glimmer would automatically register
a new component and extend the DSL with it
- Glimmer Wizard: provide a standard structure for building a Glimmer wizard (multi-step/multi-screen process)
- bind_collection: an iterator that enables spawning widgets based on a variable collection (e.g. `bind_collection('user.addresses') { |address| address_widget {...} }` spawns 3 `AddressWidget`s if `user.addresses` is set with 3 addresses; and replaces with 2 `AddressWidget`s if `user.addresses` is reset with 2 addresses only). Needs further thought on naming and functionality.
- Automatic relayout of "glimmer components" when disposing one or as an option
- Consider easy rerendering support for Glimmer upon processing events
- Support re-rendering when updating a layout file for development.
- Add TruffleRuby support
- Provide friendly error messages for all failures

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
