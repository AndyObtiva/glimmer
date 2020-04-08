# Change Log

## 0.5.0

- Scraped XML and multi-DSL support
- Renamed `#add_contents` to `#content`
- make it configurable to include SWT Packages or not

## 0.4.9
- Added `org.eclipse.swt.custom` to default list of Glimmer SWT packages
- Added Custom Shell
- Made shell `#open` method remember if it was already opened before yet hidden, and just show the shell
- Implement shell `#hide` method
- Alias shell `#open` as `#show`
- Support CustomWidget/CustomShell Custom Property Observers
- Support on_*** observers on GWidget's directly
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
- Renamed `R` prefixed classes (i.e. Ruby) to `G` prefixed classes (i.e. Glimmer) (e.g. `RWidget` becomes `GWidget`)
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
