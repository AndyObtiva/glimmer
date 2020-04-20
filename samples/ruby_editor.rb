require 'puts_debuggerer'
  
class RubyEditor
  include Glimmer

  class Dir
    class << self
      def local_dir
        @local_dir ||= new('.')
      end
    end

    attr_accessor :selected_child, :filter, :children, :filtered_path_options
    attr_reader :path

    def initialize(path)
      @path = path
      self.filtered_path_options = []
    end

    def children
      ::Dir.glob(::File.join(@path, '*')).map {|p| ::File.file?(p) ? RubyEditor::File.new(p) : RubyEditor::Dir.new(p)}
    end

    def filter=(value)
      if value.to_s.empty?
        @filter = nil 
      else
        @filter = value
      end
      self.filtered_path_options = filtered.to_a.map(&:path)   
    end

    def filtered
      return if filter.nil?
      ::Dir.glob(::File.join(@path, '**', '*')).map {|p| RubyEditor::File.new(p) if p.include?(filter) && ::File.file?(p) }.compact
    end

    def selected_child_path=(selected_path)
      if selected_path && ::File.file?(selected_path)
        @selected_child&.write_dirty_content
        self.selected_child = RubyEditor::File.new(selected_path)
      end
    end
    
    def selected_child_path
      @selected_child.path
    end

    alias filtered_path selected_child_path
    alias filtered_path= selected_child_path=

    def to_s
      path
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

    def comment_line!(caret_position)
      new_lines = lines
      the_line_for_caret_position = line_for_caret_position(caret_position)
      if the_line_for_caret_position.strip.start_with?('# ')
        new_lines[line_index_for_caret_position(caret_position)] = line_for_caret_position(caret_position).sub(/# /, '')
      elsif the_line_for_caret_position.strip.start_with?('#')
        new_lines[line_index_for_caret_position(caret_position)] = line_for_caret_position(caret_position).sub(/#/, '')
      else
        new_lines[line_index_for_caret_position(caret_position)] = "# #{line_for_caret_position(caret_position)}"
      end
      self.dirty_content = new_lines.join("\n")
    end

    def lines
      dirty_content.split("\n")
    end

    def line_for_caret_position(caret_position)
      lines[line_index_for_caret_position(caret_position)]
    end

    def line_index_for_caret_position(caret_position)
      dirty_content[0..caret_position].count("\n")
    end

    def children
      []
    end

    def to_s
      path
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
      composite {
        grid_layout 1, false
        layout_data(:fill, :fill, false, true) {
          width_hint 300
        }
        @filter_text = text {
          layout_data :fill, :center, true, false
          text bind(RubyEditor::Dir.local_dir, 'filter')
    	   on_key_pressed { |key_event|
            if key_event.keyCode == swt(:tab) || key_event.keyCode == swt(:cr) || key_event.keyCode == swt(:lf)
              @list.swt_widget.setFocus
            end
          }    
        }
        @list = list(:h_scroll, :v_scroll) {
          layout_data(:fill, :fill, true, true) {
            #exclude bind(RubyEditor::Dir.local_dir, :filter) {|f| !f}
          }
          visible bind(RubyEditor::Dir, 'local_dir.filter') {|f| !!f}
          selection bind(RubyEditor::Dir.local_dir, :filtered_path)
          on_widget_selected {
            RubyEditor::Dir.local_dir.selected_child_path = @list.swt_widget.getSelection.first
          }
    	   on_key_pressed { |key_event|
            if Glimmer::SWT::SWTProxy.include?(key_event.keyCode, :cr) || Glimmer::SWT::SWTProxy.include?(key_event.keyCode, :lf)
              RubyEditor::Dir.local_dir.selected_child_path = @list.swt_widget.getSelection.first
              @text.swt_widget.setFocus
            end
          }
        }
        @tree = tree(:virtual, :border, :h_scroll, :v_scroll) {
          layout_data(:fill, :fill, true, true) {
            #exclude bind(RubyEditor::Dir.local_dir, :filter) {|f| !!f}
          }
          visible bind(RubyEditor::Dir, 'local_dir.filter') {|f| !f}
          items bind(RubyEditor::Dir, :local_dir), tree_properties(children: :children, text: :path)
          on_widget_selected {
            RubyEditor::Dir.local_dir.selected_child_path = @tree.swt_widget.getSelection.first.getText
          }
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
            if Glimmer::SWT::SWTProxy.include?(key_event.stateMask, :command) && key_event.character.chr.downcase == '/'
              RubyEditor::Dir.local_dir.selected_child.comment_line!(@text.swt_widget.getCaretPosition())
            end
            if Glimmer::SWT::SWTProxy.include?(key_event.stateMask, :command) && key_event.character.chr.downcase == 'r'
              @filter_text.swt_widget.setFocus
            end
          }    
          on_verify_text { |verify_event|
            key_code = verify_event.keyCode
            case key_code
            when swt(:tab)
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