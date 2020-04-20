require 'puts_debuggerer'

class RubyEditor
  include Glimmer

  class Dir
    class << self
      def local_dir
        @local_dir ||= new('.')
      end
    end

    attr_accessor :selected_child
    attr_reader :path

    def initialize(path)
      @path = path
    end

    def children
      @children ||= ::Dir.glob(::File.join(@path, '*')).map {|p| ::File.file?(p) ? RubyEditor::File.new(p) : RubyEditor::Dir.new(p)}
    end

    def selected_child_path=(selected_path)
      if ::File.file?(selected_path)
        @selected_child&.write_dirty_content
        self.selected_child = RubyEditor::File.new(selected_path)
      end
    end
  end

  class File
    attr_accessor :dirty_content
    attr_reader :path

    def initialize(path)
      raise "Not a file path: #{path}" unless ::File.file?(path)
      @path = path
      self.dirty_content = ::File.read(path)
    end
    
    def write_dirty_content
      ::File.write(path, dirty_content) if ::File.exists?(path)
    end

    def children
      []
    end
  end

  def initialize
    @config_file_path = '.ruby_editor'
    RubyEditor::Dir.local_dir.selected_child = RubyEditor::File.new(::File.read(@config_file_path)) if ::File.exists?(@config_file_path)
    observe(RubyEditor::Dir.local_dir, 'selected_child') do |new_child|
      ::File.write(@config_file_path, new_child.path)
    end
  end

  def launch
    @shell = shell {
      text 'Ruby Editor'
      minimum_size 1280, 960
      grid_layout 2, false
      @tree = tree(:virtual, :border, :h_scroll, :v_scroll) {
        layout_data(:fill, :fill, false, true) {
          width_hint 300
        }
        items bind(RubyEditor::Dir, :local_dir), tree_properties(children: :children, text: :path)
        on_widget_selected {
          RubyEditor::Dir.local_dir.selected_child_path = @tree.swt_widget.getSelection.first.getText
        }
      }
      composite {
        grid_layout 1, false
        layout_data :fill, :fill, true, true
        @label = label {
          layout_data :fill, :center, true, false
          text bind(RubyEditor::Dir.local_dir, 'selected_child.path')
        }
        @text = text(:multi, :h_scroll, :v_scroll) {
          layout_data :fill, :fill, true, true
          font name: 'Consolas', height: 15
          foreground rgb(75, 75, 75)
          text bind(RubyEditor::Dir.local_dir, 'selected_child.dirty_content')
          on_focus_lost {
            RubyEditor::Dir.local_dir.selected_child.write_dirty_content
          }
          on_event_close {
            RubyEditor::Dir.local_dir.selected_child.write_dirty_content
          }
          on_widget_disposed {
            RubyEditor::Dir.local_dir.selected_child.write_dirty_content
          }
    	   on_key_pressed { |key_event|
             #if (key_event.stateMask & swt(:command) == swt(:command)) && key_event.character.chr.downcase == 'k'
            #end
          }    
          on_verify_text { |verify_event|
            key_code = verify_event.keyCode
            if key_code == swt(:tab)
              verify_event.text = '  '
            end
          }
        }
      }
    }
    @shell.open
  end
end

RubyEditor.new.launch
