# TODO

Here is a list of tasks to do (please move to [CHANGELOG.md](CHANGELOG.md) once done). 

Follow instructions in [CONTRIBUTING.md](CONTRIBUTING.md) before you implement a task below and contribute via a [Pull Request](https://github.com/AndyObtiva/glimmer/pulls) (ensuring it hasn't been reported or contributed already).

Related TODO files:
- [glimmer-dsl-swt/TODO.md](https://github.com/AndyObtiva/glimmer-dsl-swt/blob/master/TODO.md)

## Next

- Fix issue with 'handle' keyword cascading to last expression handler incorrectly
- Extract data-binding/observe keywords from glimmer-dsl-swt back into glimmer as a built in default DSL. That way, they can be shared/reused with glimmer-dsl-opal and glimmer-dsl-tk
- Extract glimmer rake tasks that are common from glimmer-dsl-swt into glimmer such as list:gems:dsl

### Version TBD

- Consider creating a configuration DSL

## Refactorings

- Rename Observable methods (including subclasses) to observe/unobserve
- Prefix ObservableModel/ObservableArray utility methods with double-underscore
