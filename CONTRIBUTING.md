# Contributing

## Pre-requisites

- MacOS
- Other pre-requisites mentioned in README.md

## Machine Setup

Follow these steps, running mentioned commands in the terminal:
- Fork project repo
- Ensure pre-requisites (installing JRuby via RVM on the Mac)
- cd into project again to activiate RVM glimmer gemset
- gem install bundler
- bundle
- rake # runs specs (ensure they finish successfully)
- rake install # builds/installs glimmer gem to be able to run samples via (glimmer samples/**)
- Once done, open a pull request with master branch.

To run a specific spec, run:
`rake SPEC=spec_file_path`
