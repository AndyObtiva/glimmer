# TODO

Here is a list of tasks to do (please move to [CHANGELOG.md](CHANGELOG.md) once done).

Follow instructions in [CONTRIBUTING.md](CONTRIBUTING.md) before you implement a task below and contribute via a [Pull Request](https://github.com/AndyObtiva/glimmer/pulls) (ensuring it hasn't been reported or contributed already).

Related TODO files:
- [glimmer-dsl-swt/TODO.md](https://github.com/AndyObtiva/glimmer-dsl-swt/blob/master/TODO.md)

## Next

- Document Observer/Observable/Data-Binding API
- Extract data-binding/observe keywords from glimmer-dsl-swt back into glimmer as a built in default DSL. That way, they can be shared/reused with glimmer-dsl-opal and glimmer-dsl-tk
- Extract glimmer-dsl-databinding out of glimmer as an observer/data-binding DSL library and reuse across other DSLs (SWT, Opal, and Tk)
- Move glimmer projects underneath glimmer organization

- Fix issue with 'handle' keyword cascading to last expression handler incorrectly
[2020-11-22 20:27:22] ERROR glimmer: Encountered an invalid keyword at this object:
[2020-11-22 20:27:22] ERROR glimmer: /Users/User/.rvm/gems/jruby-9.2.13.0@glimmer-cs-gladiator/gems/glimmer-1.0.4/lib/glimmer/dsl/expression_handler.rb:58:in `handle': Glimmer keyword can_interpret? with args [nil, "async_exec"] cannot be handled! Check the validity of the code. (Glimmer::InvalidKeywordError)
  from /Users/User/.rvm/gems/jruby-9.2.13.0@glimmer-cs-gladiator/gems/glimmer-1.0.4/lib/glimmer/dsl/expression_handler.rb:52:in `handle'
  from /Users/User/.rvm/gems/jruby-9.2.13.0@glimmer-cs-gladiator/gems/glimmer-1.0.4/lib/glimmer/dsl/expression_handler.rb:52:in `handle'
  from /Users/User/.rvm/gems/jruby-9.2.13.0@glimmer-cs-gladiator/gems/glimmer-1.0.4/lib/glimmer/dsl/expression_handler.rb:52:in `handle'
  from /Users/User/.rvm/gems/jruby-9.2.13.0@glimmer-cs-gladiator/gems/glimmer-1.0.4/lib/glimmer/dsl/expression_handler.rb:52:in `handle'
  from /Users/User/.rvm/gems/jruby-9.2.13.0@glimmer-cs-gladiator/gems/glimmer-1.0.4/lib/glimmer/dsl/expression_handler.rb:52:in `handle'
  from /Users/User/.rvm/gems/jruby-9.2.13.0@glimmer-cs-gladiator/gems/glimmer-1.0.4/lib/glimmer/dsl/expression_handler.rb:52:in `handle'
  from /Users/User/.rvm/gems/jruby-9.2.13.0@glimmer-cs-gladiator/gems/glimmer-1.0.4/lib/glimmer/dsl/expression_handler.rb:52:in `handle'
  from /Users/User/.rvm/gems/jruby-9.2.13.0@glimmer-cs-gladiator/gems/glimmer-1.0.4/lib/glimmer/dsl/expression_handler.rb:52:in `handle'
  from /Users/User/.rvm/gems/jruby-9.2.13.0@glimmer-cs-gladiator/gems/glimmer-1.0.4/lib/glimmer/dsl/expression_handler.rb:52:in `handle'
  from /Users/User/.rvm/gems/jruby-9.2.13.0@glimmer-cs-gladiator/gems/glimmer-1.0.4/lib/glimmer/dsl/expression_handler.rb:52:in `handle'
  from /Users/User/.rvm/gems/jruby-9.2.13.0@glimmer-cs-gladiator/gems/glimmer-1.0.4/lib/glimmer/dsl/expression_handler.rb:52:in `handle'
  from /Users/User/.rvm/gems/jruby-9.2.13.0@glimmer-cs-gladiator/gems/glimmer-1.0.4/lib/glimmer/dsl/expression_handler.rb:52:in `handle'
  from /Users/User/.rvm/gems/jruby-9.2.13.0@glimmer-cs-gladiator/gems/glimmer-1.0.4/lib/glimmer/dsl/expression_handler.rb:52:in `handle'
  from /Users/User/.rvm/gems/jruby-9.2.13.0@glimmer-cs-gladiator/gems/glimmer-1.0.4/lib/glimmer/dsl/expression_handler.rb:52:in `handle'
  from /Users/User/.rvm/gems/jruby-9.2.13.0@glimmer-cs-gladiator/gems/glimmer-1.0.4/lib/glimmer/dsl/expression_handler.rb:52:in `handle'
  from /Users/User/.rvm/gems/jruby-9.2.13.0@glimmer-cs-gladiator/gems/glimmer-1.0.4/lib/glimmer/dsl/engine.rb:169:in `interpret'
  from /Users/User/.rvm/gems/jruby-9.2.13.0@glimmer-cs-gladiator/gems/glimmer-1.0.4/lib/glimmer.rb:73:in `method_missing'
  from /Users/User/.rvm/gems/jruby-9.2.13.0@glimmer-cs-gladiator/gems/glimmer-1.0.4/lib/glimmer/dsl/engine.rb:58:in `block in Engine'
  from /Users/User/code/glimmer-cs-gladiator/lib/models/glimmer/gladiator/file.rb:172:in `block in start_filewatcher'
  from /Users/User/.rvm/gems/jruby-9.2.13.0@glimmer-cs-gladiator/gems/filewatcher-1.1.1/lib/filewatcher/cycles.rb:40:in `block in trigger_changes'
  from org/jruby/RubyArray.java:1809:in `each'
  from /Users/User/.rvm/gems/jruby-9.2.13.0@glimmer-cs-gladiator/gems/filewatcher-1.1.1/lib/filewatcher/cycles.rb:39:in `block in trigger_changes'
  from /Users/User/.rvm/gems/jruby-9.2.13.0@glimmer-cs-gladiator/gems/logging-2.3.0/lib/logging/diagnostic_context.rb:474:in `block in create_with_logging_context'


- Extract glimmer rake tasks that are common from glimmer-dsl-swt into glimmer such as list:gems:dsl
- Report Opal project issue regarding method/singleton_method and define_method/define_singleton_method not working in direct class/module vs instance like in Ruby

### Version TBD

- Add in-model support for specifying computed observer dependencies to avoid specifying it in the bind statement.
- Consider creating a configuration DSL

## Refactorings

- Prefix ObservableModel/ObservableArray utility methods with double-underscore
- Observer: refactor code to be more smart/polymorphic/automated and honor open/closed principle
- Observer: Consier memoizing Observer#registration_for

## DSLs

- glimmer-dsl-databinding
- glimmer-dsl-jsound
- glimmer-dsl-wasm
