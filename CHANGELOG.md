# Change Log

## 0.7.1

- Make shell auto-activate on show with 0.25 delay 
- Support bidirectional data-binding of menu item selection (e.g. radio menu item)
- Fix crash issue with data-binding widget properties that are not supported in both directions
- Override inspect on Observables to avoid getting frozen while printing very long messages on logging/error-raising

## 0.7.0

- Expose `rake glimmer:package` rake task via `glimmer package` command
- Scaffold a Glimmer app: provide a standard structure for building a Glimmer app (models, views, and assets [images, videos, sounds])
- Scaffold a Glimmer custom shell
- Scaffold a Glimmer custom widget
- Scaffold a Glimmer custom widget gem
- Scaffold a Glimmer custom shell gem
- Extract Video widget into its own custom widget glimmer-video gem
- Extract Gladiator into its own custom shell glimmer-gladiator gem
- Support disable_dsl/enable_dsl/enabled_dsls=
- Minify CSS produced by CSS DSL
- Avoid using p in CSS DSL as it clashes with HTML p. Use pv instead (property value).
- Configure scaffold rspec_helper with glimmer-appropriate after block
- Move logger/import_swt_packages methods on Glimmer to Glimmer::Config
- Reorganize samples as hello and elaborate inside samples directory

## 0.6.0

- Added multi-DSL support back to Glimmer
- Glimmer XML (HTML) DSL
- Glimmer CSS DSL
- Support mixing DSLs (e.g. SWT browser widget that has an XML text)
- Fixed Gladiator issue with not saving on quit
- Made color, rgb, and rgba SWT DSL static expressions instead of dynamic

## 0.5.11

- Added file and url attribute writers to `video` widget
- Fix Gladiator issue with empty replace text field
- Fix Gladiator issue with opening empty file
- Support picking up VERSION and LICENSE.txt files in glimmer:package rake task
- Update packaging to build app DMG file with humanized name (having spaces for multiple words) and to autoset a default mac bundle ID

## 0.5.10

- Fix video widget scrolling bar appearing issue
- Ensure on_about/on_preferences menu items are ignored on Windows
- Support SWT negative symbols postfixed by exclamation mark (e.g. :max! for no :max)
- Fix a bug in girb that made it not start anymore
- Fix a bug in Gladiator when jumping to line before a caret has been set

## 0.5.9

- Allow discovery of custom widgets without namespace if there are no existing classes with same name
- Add filters (global listeners) to SWT Display
- ShellProxy #pack and #pack_same_size methods
- Added Gladiator (Glimmer Editor) sample and command

## 0.5.8

- Support hooking into About and Preferences application menu items
- Support passing multiple SWT styles to a shell

## 0.5.7

- Make mixing Glimmer into a class enable Glimmer DSL in both class instance scope and singleton class scope
- Remove app_name and app_version since they show up from plist file upon Mac packaging
- Change default packaged app name (shows up in top menu bar on Mac) to humanized form (e.g. MathBowling becomes Math Bowling)
- Provide README instructions and easy packaging options for signing apps (Glimmer::Package.javapackager_extra_args)

## 0.5.6

- Add `rake glimmer:package:config` command to generate JAR config file
- Enabling passing extra args to javapackager via `JAVAPACKAGER_EXTRA_ARGS="..." rake glimmer:package`

## 0.5.5

- shell widget args for SWT Display app name and app version
- Glimmer DSL colors lazy initialize and don't have an SWT Display object dependency anymore
- Glimmer DSL Menu/MenuItem support

## 0.5.4

- Support custom data-binding property converters for nested/index data-binding
- Add glimmer command --log-level option
- Add glimmer command env var support
- Improvements to video widget (new methods and events to listen to)

## 0.5.3

- Upgraded rake dependency to 10.1.0 to avoid conflicting dependencies
- Stopped disposing display upon closing a shell to allow reuse
- Support custom data-binding property converters
- Automatic re-packing of shell when layout or layout data is updated with data-binding

## 0.5.2

- Support publishing a Glimmer app for the Mac (package as dmg file)
- Fix background_image widget property support to accept files in a JAR file
- Fix video widget support to accept files in a JAR file

## 0.5.0

- Upgraded SWT to version 4.15
- Upgraded to JRuby 9.2.11.1
- Refurbished/refactored Glimmer code design and APIs getting a performance boost
- Scraped XML and multi-DSL support
- Renamed `#add_contents` to `#content`
- made it configurable to include SWT Packages or not
- Supported color keyword for standard colors
- Supported swt keyword for style
- Supported async_exec/sync_exec keywords in Glimmer DSL directly
- Changed "def body" to body { } in custom widget/shell
- Renamed commands to keywords in Glimmer
- Made Glimmer::Launcher automatically figure out dev mode when run as bin/glimmer locally
- Added LOAD_PATH explicitly

## 0.4.9
- Added `org.eclipse.swt.custom` to default list of Glimmer SWT packages
- Added Custom Shell
- Made shell `#open` method remember if it was already opened before yet hidden, and just show the shell
- Implement shell `#hide` method
- Alias shell `#open` as `#show`
- Support CustomWidget/CustomShell Custom Property Observers
- Support on_*** observers on WidgetProxy's directly
- Support on_event_*** observers for SWT.constant event listeners (like show and hide)
- Added widget focus listener and data-binding support
- Support Glimmer DSL observe keyword and make it return observer registration object to unregister later on (unobserve)
- Support CustomWidget before_body and after_body hooks
- Make Glimmer DSL block provide parent Glimmer object (not SWT widget) as block argument
- Give widgets/custom-widgets ability to add content (properties/nested widgets) after construction via `#content` method
- Update setBackgroundImage to take an image path string for convenience (instead of an SWT image)

## 0.4.8
- Video widget
- Girb fix to auto-include Glimmer

## 0.4.7
- Fixed issues with custom widget support working for custom table, custom combo, custom list, parent of layout/layout-data, and on_*** observers
- Support for custom attributes/observers on a custom widget
- Display error message when using tab item widget NOT under a tab folder

## 0.4.6
- Added SWT 4.14 library jars directly in project

## 0.4.5
- SWT Browser widget support

## 0.4.4
- Glimmer Custom Widget support
- Support --debug flag

## 0.4.3
- Provide an easy way to make windows non-resizable
- Shorten needed :color_xyz symbols for known widget color properties like background and foreground to :xyz
- Friendly error message for passing a bad widget property font style (not normal, bold, italic)
- Friendly error message for passing a bad SWT style in general
- Support a single computed data binding as a string (not array)

## 0.4.2
- Center window upon opening
- Set window minimum width (130) upon opening
- Accept SWT Shell constructor arguments

## 0.4.1
- SWT Layout DSL support
- SWT Layout Data DSL support

## 0.4.0
- Changed `BlockObserver` into `Observer.proc`
- Added `Observer#proc` to create simple block-based observers.
- Updated Observer API renaming `#update` to `#call`
- Renamed `R` prefixed classes (i.e. Ruby) to `G` prefixed classes (i.e. Glimmer) (e.g. `RWidget` becomes `WidgetProxy`)
- Namespaced all of Glimmer's classes and modules under `Glimmer`
- Added `display` Glimmer DSL keyword to instantiate an SWT Display
- Removed `String` and `Symbol` monkey-patching
- Accept standard color value passed to widget color properties as `String` or `Symbol`

## 0.3.5
- Added font support to Glimmer DSL via name/height/style hash
- Added SWTProxy to easily build SWT constants (e.g. SWTProxy[:border] is SWT::BORDER )

## 0.3.4
- Fixed color support/property converter support to work both in data-binding and in static property setting

## 0.3.3
- Added color support to Glimmer DSL (rgb, rgba, and :color_*)

## 0.3.2
- Automatically import SWT packages when including/extending Glimmer
- Automatically enhance objects as ObservableArray or ObservableModel when observing them

## 0.3.1
- Fixed issue related to unnecessary tracking of parents in Observer

## 0.3.0
- Automatic cleanup of observers upon updating values in data-binding (nested/indexed) or disposing a widget
- Change of APIs whereby Observer class is responsible for registering observers with observables on properties

## 0.2.5
- Register a property type converter for `visible` property in widget binding, to ensure converting to boolean before setting in SWT widget.

## 0.2.4
- Added nested indexed computed property data binding support (e.g. bind(person, 'addresses[0].street_count', computed_by: ['addresses[0].streets']))

## 0.2.3
- Fixed nested indexed property data binding support for indexed leaf property (e.g. bind(person, 'names[1]'))

## 0.2.2
- Added nested indexed property data binding support (e.g. bind(person, 'addresses[1].street'))

## 0.2.0
- Upgraded to JRuby 9.2.10.0
- Fixed support for Windows & Linux
- Removed need to download SWT by including directly in gem for all platforms
- Simplified usage of glimmer command by preloading glimmer and not requiring setup

## 0.1.11.SWT4.14
- Upgraded SWT to version 4.14

## 0.1.11.470
- Nested property data binding support

## 0.1.10.470
- Support Tree data-binding (one-way from model to tree)

## 0.1.8.470
- girb support

## 0.1.5.470
- Glimmer now uses a Ruby Logger in debug mode to provide helpful debugging information
- Glimmer has a smart new Ruby shell script for executing applications
- Glimmer now downloads swt.jar automatically when missing (e.g. 1st run) on Mac, Windows, and Linux, and for x86 and x86-64 CPU architectures.
