require 'puts_debuggerer'
require 'yaml'

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
      @selected_child&.path
    end

    alias filtered_path selected_child_path
    alias filtered_path= selected_child_path=

    def to_s
      path
    end
  end

  class File
    include Glimmer

    attr_accessor :dirty_content, :caret_position, :line_number
    attr_reader :path

    def initialize(path)
      raise "Not a file path: #{path}" unless ::File.file?(path)
      @path = path
      self.dirty_content = ::File.read(path)
      observe(self, :caret_position) do
        self.line_number = line_index_for_caret_position(caret_position) + 1
      end
      observe(self, :line_number) do
        new_caret_position = dirty_content.split("\n")[0...(line_number.to_i - 1)].map(&:size).sum + line_number.to_i - 1
        self.caret_position = new_caret_position unless line_index_for_caret_position(new_caret_position) == line_index_for_caret_position(caret_position)
      end
    end

    def write_dirty_content
      ::File.write(path, dirty_content) if ::File.exists?(path)
    end

    def comment_line!(caret_position)
      new_lines = lines
      the_line_for_caret_position = line_for_caret_position(caret_position)
      delta = 0
      if the_line_for_caret_position.strip.start_with?('# ')
        new_lines[line_index_for_caret_position(caret_position)] = line_for_caret_position(caret_position).sub(/# /, '')
        delta -= 2
      elsif the_line_for_caret_position.strip.start_with?('#')
        new_lines[line_index_for_caret_position(caret_position)] = line_for_caret_position(caret_position).sub(/#/, '')
        delta -= 2
      else
        new_lines[line_index_for_caret_position(caret_position)] = "# #{line_for_caret_position(caret_position)}"
        delta += 2
      end
      old_caret_position = self.caret_position
      self.dirty_content = new_lines.join("\n")   
      self.caret_position = old_caret_position + delta
    end

    def kill_line!(caret_position)
      new_lines = lines
      delta = line_for_caret_position(caret_position).size
      new_lines.delete_at(line_index_for_caret_position(caret_position))
      old_caret_position = self.caret_position
      self.dirty_content = new_lines.join("\n")
      self.caret_position = old_caret_position - delta
    end

    def duplicate_line!(caret_position)
      new_lines = lines
      new_lines.insert(line_index_for_caret_position(caret_position) + 1, line_for_caret_position(caret_position))
      self.dirty_content = new_lines.join("\n")
    end

    def lines
      dirty_content.split("\n")
    end

    def line_for_caret_position(caret_position)
      lines[line_index_for_caret_position(caret_position)]
    end

    def line_index_for_caret_position(caret_position)
      count = dirty_content[0..caret_position].count("\n")
      count -= 1 if dirty_content[caret_position] == "\n"
      count
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
    load_config
    observe(RubyEditor::Dir.local_dir, 'selected_child.caret_position') do
      save_config
    end
  end

  def load_config
    if ::File.exists?(@config_file_path)
      config_yaml = ::File.read(@config_file_path)
      config = YAML.load(config_yaml)
      RubyEditor::Dir.local_dir.selected_child = RubyEditor::File.new(config[:selected_child_path])
      RubyEditor::Dir.local_dir.selected_child.caret_position = config[:caret_position]
    end
  end

  def save_config
    child = RubyEditor::Dir.local_dir.selected_child
    config = {
      selected_child_path: child.path,
      caret_position: child.caret_position
    }
    config_yaml = YAML.dump(config)
    ::File.write(@config_file_path, config_yaml)
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
            if key_event.keyCode == swt(:tab) || 
                key_event.keyCode == swt(:cr) || 
                key_event.keyCode == swt(:lf) ||
                key_event.keyCode == swt(:arrow_down)
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
        composite {
          grid_layout 1, false
          @label = label {
            layout_data :fill, :fill, true, false
            text bind(RubyEditor::Dir.local_dir, 'selected_child.path')
          }
          @line_number_text = text {
            layout_data :fill, :fill, true, false
            text bind(RubyEditor::Dir.local_dir, 'selected_child.line_number', on_read: :to_s, on_write: :to_i)
    	     on_key_pressed { |key_event|
              if Glimmer::SWT::SWTProxy.include?(key_event.keyCode, :cr) || Glimmer::SWT::SWTProxy.include?(key_event.keyCode, :lf)
                @text.swt_widget.setFocus
              end
            }
          }
        }
        @text = text(:multi, :h_scroll, :v_scroll) {
          layout_data :fill, :fill, true, true
          font name: 'Consolas', height: 15
          foreground rgb(75, 75, 75)
          text bind(RubyEditor::Dir.local_dir, 'selected_child.dirty_content')
          focus true
          caret_position bind(RubyEditor::Dir.local_dir, 'selected_child.caret_position')
          on_focus_lost {
            RubyEditor::Dir.local_dir.selected_child&.write_dirty_content
          }
          on_event_close {
            RubyEditor::Dir.local_dir.selected_child&.write_dirty_content
          }
          on_widget_disposed {
            RubyEditor::Dir.local_dir.selected_child&.write_dirty_content
          }
    	   on_key_pressed { |key_event|
            if Glimmer::SWT::SWTProxy.include?(key_event.stateMask, :command) && key_event.character.chr.downcase == '/'
              RubyEditor::Dir.local_dir.selected_child.comment_line!(@text.swt_widget.getCaretPosition())
            elsif Glimmer::SWT::SWTProxy.include?(key_event.stateMask, :command) && key_event.character.chr.downcase == 'k'
              RubyEditor::Dir.local_dir.selected_child.kill_line!(@text.swt_widget.getCaretPosition())
            elsif Glimmer::SWT::SWTProxy.include?(key_event.stateMask, :command) && key_event.character.chr.downcase == 'd'
              RubyEditor::Dir.local_dir.selected_child.duplicate_line!(@text.swt_widget.getCaretPosition())
            elsif Glimmer::SWT::SWTProxy.include?(key_event.stateMask, :command) && key_event.character.chr.downcase == 'r'
              @filter_text.swt_widget.setFocus
            elsif Glimmer::SWT::SWTProxy.include?(key_event.stateMask, :command) && key_event.character.chr.downcase == 'l'
              @line_number_text.swt_widget.selectAll
              @line_number_text.swt_widget.setFocus
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
