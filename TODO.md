# TODO

Here is a list of tasks to do (please move to [CHANGELOG.md](CHANGELOG.md) once done).

Follow instructions in [CONTRIBUTING.md](CONTRIBUTING.md) before you implement a task below and contribute via a [Pull Request](https://github.com/AndyObtiva/glimmer/pulls) (ensuring it hasn't been reported or contributed already).

Related TODO files:
- [glimmer-dsl-swt/TODO.md](https://github.com/AndyObtiva/glimmer-dsl-swt/blob/master/TODO.md)

## Next

- Fix issue with computed data-binding when combined with nested/indexed data-binding (it looks up computed attributes on root object instead of nested object, it seems)
- Support nested computed attributes (e.g. computed_by: {address1: [:street, :city, :state, :zip]})
- Consider the idea of having Observer#observe accept an optional block to do observation without implementing `call` (kinda like when using the `observe` keyword in the Glimmer DSL). 
- Observe an array for all children changes on a specific property (e.g. observe(@game, 'blocks[][].color') ; returns |new_color, block|)
- Ensure removing observers from hash in ObservableModel when removed from observable
- Avoid `< Struct.new` in specs (tests)
- Add built-in support to Glimmer::DSL::Engine to memoize/cache expressions similar to how that is supported for StaticExpression (but allowing an outside keyword and non-static expression to be used)

### Version TBD

- Improve API for `add_observer` methods on observables (make it accept a block, and perhaps reverse arg order)
- Allow being able to include Glimmer for a particular DSL (e.g. `include Glimmer[:data_binding]` to add `observe` keyword only) without having to enable/disable DSLs (create scoped realms of DSL activation)
- refactor observer registration code to be more smart/polymorphic/automated and honor open/closed principle (e.g. for SomeClass, search if there is ObservableSomeClass for the various hash, array, and model observables)
- Support automatic computed data-binding by monitoring method invocations of a top-level data-bound attribute. This will need the newest Ruby updates for Tracepoint, and perhaps passing options to Ruby when running apps. Whatever this Ruby bug yielded must be used: https://bugs.ruby-lang.org/issues/16383
- Support `observed` keyword to use in Observables around blocks of code that wouldn't trigger changes till completed.
- Consider specifying a bind(`triggered_by: method_name`) option that would provide the scope for when to react to an observation.   This is similar to computed_by: except it negates updates happening outside of the computed_by method.
- General nested data-binding not just on an index (e.g. 'addresses.street' not just 'addresses[0].street')
- Consider supporting the idea of observing what (nested) methods are in progress of execution on a model (maybe call methods_in_progress returning an array ordering from earliest outermost to latest innermost method invocation). That way if many fine-grained updates are happening and the observer isn't interested in reacting till a large-scale operation completed, it can do so.
- Refactor Engine: consider replacing Glimmer::DSL::Engine.static_expressions[keyword].keys - Glimmer::DSL::Engine.disabled_dsls with Glimmer::DSL::Engine.enabled_static_expression_dsls(keyword)
- Deal with Engine issue regarding async_exec static expression
- Document Observer/Observable/Data-Binding API
- Extract glimmer-dsl-databinding out of glimmer as an observer/data-binding DSL library and reuse across other DSLs (SWT, Opal, and Tk)
- Move glimmer projects underneath glimmer organization
- Extract glimmer rake tasks that are common from glimmer-dsl-swt into glimmer such as list:gems:dsl
- Consider the performance enhancement of having varied command_handlers per parent class type, hashed and ready to go
- Extract computed data-binding specs and other ModelBinding indirect specs from glimmer-dsl-swt to glimmer
- Add in-model support for specifying computed observer dependencies to avoid specifying it in the bind statement.
- Check if TopLevelExpression must be verified for dynamic expressions (currently only verified for static expressions)
- Ability to observe all properties of an ObservableModel and pass property names in observer calls as second argument
- Observe nested hashes recursively for all keys (similar to Array recursive observation)
- Consider making `#ensure_array_object_observer` optional in ObservableModel/ObservableHash/ObservableArray since it has performance implications (and perhaps make it happen as part of recursive: 1, shifting the depth understanding, instead of happening on recursive: false like it is now)
- Fix issue with `#ensure_array_object_observer` not receiving `recursive: true` option (except first time) when updating value of an attribute in `ObservableModel`
- Fix issue with `#ensure_array_object_observer` not receiving `recursive: true` option (except first time) when updating value of an attribute in `ObservableHash`
- Support keyword arguments via **kwargs in expression interpretors (new Ruby 2.7+ feature to implement once supported by JRuby and Ruby 2.6 support is dropped)
- Rubocop checker for Glimmer GUI DSL syntax

### Maybe

- Observe all attribute writers in an `Object` (observe every attribute ending with =)
- Observe all attribute writers in a `Struct` (observe every attribute ending with = as well as []= method)
- Observe all attribute writers in an `OpenStruct` (observe `set_ostruct_member_value` method)
- Support `recursive: true` with hashes that have nested hashes
- Support `recursive: true` with models that have nested models
- Observe multiple attributes or indexed/keyed/nested attribute expressions with a single observer
- Consider the idea of having before_read and before_write support cancelling a data-binding operation by returning `false`, returning `:cancel`, Or by receiving an extra arg that enables calling arg.cancel on or something similar to avoid having normal code cancel the data-binding operation just because it returns nil.

### Miscellaneous

- Report Opal project issue regarding method/singleton_method and define_method/define_singleton_method not working in direct class/module vs instance like in Ruby
- After hitting v1.0.0 on Glimmer DSL for LibUI, suggest merging Glimmer into Ruby core to provide Ruby developers with built-in support for creating the best Internal (Embedded) DSL syntax possible. This should elevate Ruby into a whole other level.

## Refactorings

- Prefix ObservableModel/ObservableArray utility methods with double-underscore
- Observer: refactor code to be more smart/polymorphic/automated and honor open/closed principle
- Observer: Consier memoizing Observer#registration_for (with the caveat being more memory usage, which might not be needed if it's fast enough to create and dispose)

## DSLs

- glimmer-dsl-rubymotion: Ruby Motion enables mobile app development with Ruby. Providing a DSL for it is useful.
- glimmer-dsl-ruby2d: Declarative Glimmer DSL for [Ruby2D](https://github.com/ruby2d/ruby2d) gaming library
- glimmer-dsl-hexapdf: Declarative Glimmer DSL for [HexaPDF](https://github.com/gettalong/hexapdf)'s canvas graphics (and general PDF generation) imperative syntax (maybe even attempt to merge back to HexaPDF if its author is interested)
- glimmer-dsl-optparse: A clean Glimmer DSL for optparse since its built-in DSL is extremely verbose and redundant
- glimmer-dsl-tui: Glimmer DSL for Text-Based User Interfaces (aka Textual User Interfaces). Have it adapt desktop apps just like Glimmer DSL for Opal
- glimmer-dsl-object: A configuration DSL for building any Ruby object via DSL syntax instead of plain old Ruby syntax (perhaps replacing PropertyExpression in Glimmer DSL for SWT with it) (perhaps using as a way to scaffold the base of new DSLs since they all share a few things like elements, properties, listeners, and data-binding)
- glimmer-dsl-ruby: Use Glimmer DSL to generate Ruby code. Useful for building class generators as an alternative to ERB

```ruby
class(*init_args) {
  attribute_name value
  non_setter_method(*args)
  block_attribute {
  }
  nested_child_class(*init_args) { # added to parent children
  }
}
```

Example:

```ruby
rectangle(width: 30, height: 40) {
  solid
  width 30
  height 40
  circle(x: 30, y: 70) {
    radius 70
  }
}
```
