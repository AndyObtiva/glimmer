# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run 'rake gemspec'
# -*- encoding: utf-8 -*-
# stub: glimmer 0.3.5 ruby lib

Gem::Specification.new do |s|
  s.name = "glimmer".freeze
  s.version = "0.3.5"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["AndyMaleh".freeze]
  s.date = "2020-03-12"
  s.description = "JRuby Desktop UI DSL + Data-Binding library that enables easy and efficient authoring of user-interfaces using the robust platform-independent Eclipse SWT library".freeze
  s.email = "andy.am@gmail.com".freeze
  s.executables = ["glimmer".freeze, "girb".freeze]
  s.extra_rdoc_files = [
    "LICENSE.txt",
    "README.markdown"
  ]
  s.files = [
    "bin/girb",
    "bin/glimmer",
    "lib/command_handler.rb",
    "lib/command_handler_chain_factory.rb",
    "lib/command_handler_chain_link.rb",
    "lib/command_handlers.rb",
    "lib/command_handlers/bind_command_handler.rb",
    "lib/command_handlers/color_command_handler.rb",
    "lib/command_handlers/combo_selection_data_binding_command_handler.rb",
    "lib/command_handlers/data_binding_command_handler.rb",
    "lib/command_handlers/list_selection_data_binding_command_handler.rb",
    "lib/command_handlers/models/block_observer.rb",
    "lib/command_handlers/models/list_selection_binding.rb",
    "lib/command_handlers/models/model_binding.rb",
    "lib/command_handlers/models/observable.rb",
    "lib/command_handlers/models/observable_array.rb",
    "lib/command_handlers/models/observable_model.rb",
    "lib/command_handlers/models/observer.rb",
    "lib/command_handlers/models/r_color.rb",
    "lib/command_handlers/models/r_runnable.rb",
    "lib/command_handlers/models/r_shell.rb",
    "lib/command_handlers/models/r_tab_item_composite.rb",
    "lib/command_handlers/models/r_widget.rb",
    "lib/command_handlers/models/r_widget_listener.rb",
    "lib/command_handlers/models/table_items_binding.rb",
    "lib/command_handlers/models/tree_items_binding.rb",
    "lib/command_handlers/models/widget_binding.rb",
    "lib/command_handlers/shell_command_handler.rb",
    "lib/command_handlers/tab_item_command_handler.rb",
    "lib/command_handlers/table_column_properties_data_binding_command_handler.rb",
    "lib/command_handlers/table_items_data_binding_command_handler.rb",
    "lib/command_handlers/tree_items_data_binding_command_handler.rb",
    "lib/command_handlers/tree_properties_data_binding_command_handler.rb",
    "lib/command_handlers/widget_command_handler.rb",
    "lib/command_handlers/widget_listener_command_handler.rb",
    "lib/command_handlers/widget_method_command_handler.rb",
    "lib/glimmer.rb",
    "lib/glimmer_application.rb",
    "lib/parent.rb",
    "lib/shine.rb",
    "lib/string.rb",
    "lib/swt_packages.rb",
    "lib/symbol.rb",
    "lib/xml_command_handlers.rb",
    "lib/xml_command_handlers/html_command_handler.rb",
    "lib/xml_command_handlers/models/depth_first_search_iterator.rb",
    "lib/xml_command_handlers/models/name_space_visitor.rb",
    "lib/xml_command_handlers/models/node.rb",
    "lib/xml_command_handlers/models/node_visitor.rb",
    "lib/xml_command_handlers/models/xml_visitor.rb",
    "lib/xml_command_handlers/xml_command_handler.rb",
    "lib/xml_command_handlers/xml_name_space_command_handler.rb",
    "lib/xml_command_handlers/xml_tag_command_handler.rb",
    "lib/xml_command_handlers/xml_text_command_handler.rb",
    "vendor/swt/linux/swt.jar",
    "vendor/swt/mac/swt.jar",
    "vendor/swt/windows/swt.jar"
  ]
  s.homepage = "http://github.com/AndyObtiva/glimmer".freeze
  s.licenses = ["MIT".freeze]
  s.rubygems_version = "3.0.6".freeze
  s.summary = "Desktop application development library".freeze

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<facets>.freeze, ["= 3.1.0"])
      s.add_runtime_dependency(%q<os>.freeze, ["= 1.0.0"])
      s.add_development_dependency(%q<rspec-mocks>.freeze, ["~> 3.5.0"])
      s.add_development_dependency(%q<rspec>.freeze, ["~> 3.5.0"])
      s.add_development_dependency(%q<rdoc>.freeze, ["~> 2.3.0"])
      s.add_development_dependency(%q<jeweler>.freeze, ["~> 2.3.9"])
      s.add_development_dependency(%q<coveralls>.freeze, ["= 0.8.5"])
      s.add_development_dependency(%q<simplecov>.freeze, ["~> 0.10.0"])
      s.add_development_dependency(%q<puts_debuggerer>.freeze, ["~> 0.8.1"])
    else
      s.add_dependency(%q<facets>.freeze, ["= 3.1.0"])
      s.add_dependency(%q<os>.freeze, ["= 1.0.0"])
      s.add_dependency(%q<rspec-mocks>.freeze, ["~> 3.5.0"])
      s.add_dependency(%q<rspec>.freeze, ["~> 3.5.0"])
      s.add_dependency(%q<rdoc>.freeze, ["~> 2.3.0"])
      s.add_dependency(%q<jeweler>.freeze, ["~> 2.3.9"])
      s.add_dependency(%q<coveralls>.freeze, ["= 0.8.5"])
      s.add_dependency(%q<simplecov>.freeze, ["~> 0.10.0"])
      s.add_dependency(%q<puts_debuggerer>.freeze, ["~> 0.8.1"])
    end
  else
    s.add_dependency(%q<facets>.freeze, ["= 3.1.0"])
    s.add_dependency(%q<os>.freeze, ["= 1.0.0"])
    s.add_dependency(%q<rspec-mocks>.freeze, ["~> 3.5.0"])
    s.add_dependency(%q<rspec>.freeze, ["~> 3.5.0"])
    s.add_dependency(%q<rdoc>.freeze, ["~> 2.3.0"])
    s.add_dependency(%q<jeweler>.freeze, ["~> 2.3.9"])
    s.add_dependency(%q<coveralls>.freeze, ["= 0.8.5"])
    s.add_dependency(%q<simplecov>.freeze, ["~> 0.10.0"])
    s.add_dependency(%q<puts_debuggerer>.freeze, ["~> 0.8.1"])
  end
end

