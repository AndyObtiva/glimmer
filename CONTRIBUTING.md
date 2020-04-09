# Contributing

## Pre-requisites

- MacOS
- Other pre-requisites mentioned in [README.md](https://github.com/AndyObtiva/glimmer/tree/master#pre-requisites)

## Machine Setup

Follow these steps, running mentioned commands in the terminal:
- Fork project repo
- Ensure pre-requisites installed (installing JRuby via RVM on the Mac)
- cd into project again to activate RVM glimmer gemset
- gem install bundler
- bundle
- rake # runs specs (ensure they finish successfully)
- Once done, open a pull request with master branch.

### rspec

`rake` or `rake spec` runs all specs.

To run a specific spec file, run:
```
rake SPEC=spec_file_path
```

To run a specific spec, run:
```
rake SPEC=spec_file_path:line_number
```

To display Glimmer debug information, run:
```
GLIMMER_DEBUG=true rake SPEC=spec_file_path:line_number
```


Note: make sure not to use the keyword or mouse while tests are running since they bring up UI elements behind the scenes (invisible). This avoids fudging them and causing false test failures. If you get obscure failures related to focus of widgets, they are most likely false negatives. Just rerun the specs without touching the keyboard or mouse and they should pass assuming they are not really broken.

### build

`rake build` builds the Glimmer gem under the `pkg` directory.

### glimmer command

To run a glimmer sample, run local `bin/glimmer` command:
```
bin/glimmer samples/hello_world.rb
```

It will notify you that you are in development mode.

### girb command

To experiment with glimmer syntax using `girb`, run local `bin/girb`:
```
bin/girb
```

It will notify you that you are in development mode.
