# Change Log

## 0.4.2
- Center window upon launching
- Set window minimum width (130) upon launching
- Support Shell constructor arguments
- Provide an easy way to make windows unresizable

## 0.4.1
- SWT Layout DSL support
- SWT Layout Data DSL support

## 0.4.0
- Changed `BlockObserver` into `Observer::Proc`
- Added `Observer#proc` to create simple block-based observers.
- Updated Observer API renaming `#update` to `#call`
- Renamed `R` prefixed classes (i.e. Ruby) to `G` prefixed classes (i.e. Glimmer) (e.g. `RWidget` becomes `GWidget`)
- Namespaced all of Glimmer's classes and modules under `Glimmer`
- Added `display` Glimmer DSL keyword to instantiate an SWT Display
- Removed `String` and `Symbol` monkey-patching
- Accept standard color value passed to widget color properties as `String` or `Symbol`

## 0.3.5
- Added font support to Glimmer DSL via name/height/style hash
- Added GSWT to easily build SWT constants (e.g. GSWT[:border] is SWT::BORDER )

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
