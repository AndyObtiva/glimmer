  VERSION = "0.1.4"
  
  lib_files = %w[lib/command_handler.rb lib/command_handlers/bind_command_handler.rb lib/command_handlers/combo_selection_data_binding_command_handler.rb lib/command_handlers/data_binding_command_handler.rb lib/command_handlers/list_selection_data_binding_command_handler.rb lib/command_handlers/models/list_observer.rb lib/command_handlers/models/model_observer.rb lib/command_handlers/models/observable_array.rb lib/command_handlers/models/observable_model.rb lib/command_handlers/models/r_runnable.rb lib/command_handlers/models/r_shell.rb lib/command_handlers/models/r_tab_item_composite.rb lib/command_handlers/models/r_widget.rb lib/command_handlers/models/r_widget_listener.rb lib/command_handlers/models/r_widget_packages.rb lib/command_handlers/models/table_items_updater.rb lib/command_handlers/models/widget_observer.rb lib/command_handlers/shell_command_handler.rb lib/command_handlers/swt_constant_command_handler.rb lib/command_handlers/table_column_properties_data_binding_command_handler.rb lib/command_handlers/table_items_data_binding_command_handler.rb lib/command_handlers/tab_item_command_handler.rb lib/command_handlers/widget_command_handler.rb lib/command_handlers/widget_listener_command_handler.rb lib/command_handlers/widget_method_command_handler.rb lib/command_handlers.rb lib/command_handler_chain_factory.rb lib/command_handler_chain_link.rb lib/glimmer.rb lib/parent.rb lib/shine.rb lib/swt.rb lib/xml.rb lib/xml_command_handlers/html_command_handler.rb lib/xml_command_handlers/models/depth_first_search_iterator.rb lib/xml_command_handlers/models/name_space_visitor.rb lib/xml_command_handlers/models/node.rb lib/xml_command_handlers/models/node_visitor.rb lib/xml_command_handlers/models/xml_visitor.rb lib/xml_command_handlers/xml_command_handler.rb lib/xml_command_handlers/xml_name_space_command_handler.rb lib/xml_command_handlers/xml_tag_command_handler.rb lib/xml_command_handlers/xml_text_command_handler.rb lib/xml_command_handlers.rb]
  test_files = %w[test/glimmer_combo_data_binding_test.rb test/glimmer_constant_test.rb test/glimmer_data_binding_test.rb test/glimmer_listeners_test.rb test/glimmer_list_data_binding_test.rb test/glimmer_shine_data_binding_test.rb test/glimmer_table_data_binding_test.rb test/glimmer_tab_item_test.rb test/glimmer_test.rb test/observable_model_test.rb test/r_widget_test.rb test/samples/contactmanager/contact_manager_presenter_test.rb test/samples/tictactoe/tic_tac_toe_test.rb test/xml/glimmer_xml_test.rb]
  sample_files = %w[samples/contactmanager/contact.rb samples/contactmanager/contact_manager.rb samples/contactmanager/contact_manager_presenter.rb samples/contactmanager/contact_repository.rb samples/hello_world.rb samples/login.rb samples/tictactoe/tic_tac_toe.rb samples/tictactoe/tic_tac_toe_board.rb]
  
  Gem::Specification.new do |s|
    s.name = "glimmer"
    s.version = VERSION
    s.date = "2008-12-06"
    s.summary = "JRuby DSL that enables easy and efficient authoring of user-interfaces 
  using the robust platform-independent Eclipse SWT library"
    s.email = "soleone@gmail.com"
    s.homepage = "http://github.com/AndyObtiva/glimmer"
    s.description = "Ruby library for fetching information about games from www.gamefaqs.com using Hpricot"
    s.has_rdoc = true
    s.authors = ["Andy Maleh"]
    s.require_path = "lib"
    s.autorequire = "swt"
    s.files = lib_files + sample_files
    s.test_files = test_files
    #s.rdoc_options = ["--main", "README"]
    s.extra_rdoc_files = ["README"]
    s.add_dependency("facets", ["> 2.2.0"])
  end

