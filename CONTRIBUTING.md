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

To run a specific spec, run:
```
rake SPEC=spec_file_path
```

Otherwise, `rake` or `rake spec` runs all specs.

### glimmer command

To run a glimmer sample, run local `bin/glimmer` command with `--dev` option to ensure loading glimmer library from local cloned project instead of installed gem:
```
bin/glimmer --dev samples/hello_world.rb
```

If `glimmer` gem is not installed, then you may simply run:
```
bin/glimmer samples/hello_world.rb
```

It will notify you that you are in development mode.

### girb command

To experiment with glimmer syntax using `girb`, run local `bin/girb` command with `--dev` option to ensure loading glimmer library from local cloned project instead of installed gem:
```
bin/girb --dev
```

If `glimmer` gem is not installed, then you may simply run:
```
bin/glimmer samples/hello_world.rb
```

It will notify you that you are in development mode.
