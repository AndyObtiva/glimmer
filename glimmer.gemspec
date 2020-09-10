# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run 'rake gemspec'
# -*- encoding: utf-8 -*-
# stub: glimmer 0.10.4 ruby lib

Gem::Specification.new do |s|
  s.name = "glimmer".freeze
  s.version = "0.10.4"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["AndyMaleh".freeze]
  s.date = "2020-09-10"
  s.description = "Ruby Desktop Development GUI Library (JRuby on SWT)".freeze
  s.email = "andy.am@gmail.com".freeze
  s.extra_rdoc_files = [
    "LICENSE.txt",
    "README.md"
  ]
  s.files = [
    "LICENSE.txt",
    "README.md",
    "VERSION",
    "lib/glimmer.rb",
    "lib/glimmer/config.rb",
    "lib/glimmer/data_binding/model_binding.rb",
    "lib/glimmer/data_binding/observable.rb",
    "lib/glimmer/data_binding/observable_array.rb",
    "lib/glimmer/data_binding/observable_model.rb",
    "lib/glimmer/data_binding/observer.rb",
    "lib/glimmer/dsl/engine.rb",
    "lib/glimmer/dsl/expression.rb",
    "lib/glimmer/dsl/expression_handler.rb",
    "lib/glimmer/dsl/parent_expression.rb",
    "lib/glimmer/dsl/static_expression.rb",
    "lib/glimmer/dsl/top_level_expression.rb",
    "lib/glimmer/error.rb",
    "lib/glimmer/excluded_keyword_error.rb",
    "lib/glimmer/invalid_keyword_error.rb"
  ]
  s.homepage = "http://github.com/AndyObtiva/glimmer".freeze
  s.licenses = ["MIT".freeze]
  s.rubygems_version = "3.0.6".freeze
  s.summary = "Ruby Desktop Development GUI Library".freeze

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<array_include_methods>.freeze, [">= 1.0.2", "< 2.0.0"])
      s.add_runtime_dependency(%q<facets>.freeze, [">= 3.1.0", "< 4.0.0"])
      s.add_development_dependency(%q<rspec-mocks>.freeze, ["~> 3.5.0"])
      s.add_development_dependency(%q<rspec>.freeze, ["~> 3.5.0"])
      s.add_development_dependency(%q<puts_debuggerer>.freeze, ["~> 0.10.0"])
      s.add_development_dependency(%q<rake>.freeze, [">= 10.1.0", "< 14.0.0"])
      s.add_development_dependency(%q<jeweler>.freeze, [">= 2.3.9", "< 3.0.0"])
      s.add_development_dependency(%q<rdoc>.freeze, [">= 6.2.1", "< 7.0.0"])
      s.add_development_dependency(%q<coveralls>.freeze, ["= 0.8.23"])
      s.add_development_dependency(%q<simplecov>.freeze, ["~> 0.16.1"])
      s.add_development_dependency(%q<simplecov-lcov>.freeze, ["~> 0.7.0"])
    else
      s.add_dependency(%q<array_include_methods>.freeze, [">= 1.0.2", "< 2.0.0"])
      s.add_dependency(%q<facets>.freeze, [">= 3.1.0", "< 4.0.0"])
      s.add_dependency(%q<rspec-mocks>.freeze, ["~> 3.5.0"])
      s.add_dependency(%q<rspec>.freeze, ["~> 3.5.0"])
      s.add_dependency(%q<puts_debuggerer>.freeze, ["~> 0.10.0"])
      s.add_dependency(%q<rake>.freeze, [">= 10.1.0", "< 14.0.0"])
      s.add_dependency(%q<jeweler>.freeze, [">= 2.3.9", "< 3.0.0"])
      s.add_dependency(%q<rdoc>.freeze, [">= 6.2.1", "< 7.0.0"])
      s.add_dependency(%q<coveralls>.freeze, ["= 0.8.23"])
      s.add_dependency(%q<simplecov>.freeze, ["~> 0.16.1"])
      s.add_dependency(%q<simplecov-lcov>.freeze, ["~> 0.7.0"])
    end
  else
    s.add_dependency(%q<array_include_methods>.freeze, [">= 1.0.2", "< 2.0.0"])
    s.add_dependency(%q<facets>.freeze, [">= 3.1.0", "< 4.0.0"])
    s.add_dependency(%q<rspec-mocks>.freeze, ["~> 3.5.0"])
    s.add_dependency(%q<rspec>.freeze, ["~> 3.5.0"])
    s.add_dependency(%q<puts_debuggerer>.freeze, ["~> 0.10.0"])
    s.add_dependency(%q<rake>.freeze, [">= 10.1.0", "< 14.0.0"])
    s.add_dependency(%q<jeweler>.freeze, [">= 2.3.9", "< 3.0.0"])
    s.add_dependency(%q<rdoc>.freeze, [">= 6.2.1", "< 7.0.0"])
    s.add_dependency(%q<coveralls>.freeze, ["= 0.8.23"])
    s.add_dependency(%q<simplecov>.freeze, ["~> 0.16.1"])
    s.add_dependency(%q<simplecov-lcov>.freeze, ["~> 0.7.0"])
  end
end

