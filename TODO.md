# TODO

Here is a list of tasks to do (please move to [CHANGELOG.md](CHANGELOG.md) once done).

Follow instructions in [CONTRIBUTING.md](CONTRIBUTING.md) before you implement a task below and contribute via a [Pull Request](https://github.com/AndyObtiva/glimmer/pulls) (ensuring it hasn't been reported or contributed already).

Related TODO files:
- [glimmer-dsl-swt/TODO.md](https://github.com/AndyObtiva/glimmer-dsl-swt/blob/master/TODO.md)

## Next

- Switch DSL Engine puts with log statements
- Provide concurrent data structure config option to enable explicitly
- Refactor Engine: consider replacing Glimmer::DSL::Engine.static_expressions[keyword].keys - Glimmer::DSL::Engine.disabled_dsls with Glimmer::DSL::Engine.enabled_static_expression_dsls(keyword)
- Deal with Engine issue regarding async_exec static expression
- Document Observer/Observable/Data-Binding API
- Extract data-binding/observe keywords from glimmer-dsl-swt back into glimmer as a built in default DSL. That way, they can be shared/reused with glimmer-dsl-opal and glimmer-dsl-tk
- Extract glimmer-dsl-databinding out of glimmer as an observer/data-binding DSL library and reuse across other DSLs (SWT, Opal, and Tk)
- Move glimmer projects underneath glimmer organization
- Extract glimmer rake tasks that are common from glimmer-dsl-swt into glimmer such as list:gems:dsl

### Version TBD

- Add in-model support for specifying computed observer dependencies to avoid specifying it in the bind statement.

### Miscellaneous

- Report Opal project issue regarding method/singleton_method and define_method/define_singleton_method not working in direct class/module vs instance like in Ruby

## Refactorings

- Prefix ObservableModel/ObservableArray utility methods with double-underscore
- Observer: refactor code to be more smart/polymorphic/automated and honor open/closed principle
- Observer: Consier memoizing Observer#registration_for (with the caveat being more memory usage, which might not be needed if it's fast enough to create and dispose)

## DSLs

- glimmer-dsl-databinding
- glimmer-dsl-jsound
- glimmer-dsl-wasm
- glimmer-dsl-uml: A DSL for building UML diagrams based on the Glimmer engine. Renders as SWT app to start. Support web later via opal.
- glimmer-dsl-object: A configuration DSL for building any Ruby object via DSL syntax instead of plain old Ruby syntax (perhaps replacing PropertyExpression in Glimmer DSL for SWT with it)
class(*init_args) {
  attribute_name value
  non_setter_method(*args)
  block_attribute {
  }
  nested_child_class(*init_args) { # added to parent children
  }
}

Example:

rectangle(width: 30, height: 40) {
  solid
  width 30
  height 40
  circle(x: 30, y: 70) {
    radius: 70
  }
}
