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
      all_children_files.select {|child| child.path.include?(filter) }
    end

    def all_children
      @all_children ||= ::Dir.glob(::File.join(@path, '**', '*')).map {|p| ::File.file?(p) ? RubyEditor::File.new(p) : RubyEditor::Dir.new(p)}
    end

    def all_children_files
      @all_children_files ||= all_children.select {|child| child.is_a?(RubyEditor::File) }
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

    attr_accessor :dirty_content, :caret_position, :selection_count, :line_number, :find_text
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

    def comment_line!
      old_lines = lines
      old_selection_count = self.selection_count
      old_caret_position = self.caret_position
      old_caret_position_line_index = line_index_for_caret_position(old_caret_position)
      old_caret_position_line_caret_position = caret_position_for_line_index(old_caret_position_line_index)
      old_end_caret_line_index = end_caret_position_line_index(caret_position, selection_count)
      new_lines = lines
      delta = 0
      line_indices_for_selection(caret_position, selection_count).reverse.each do | the_line_index |
        delta = 0
        the_line = old_lines[the_line_index]
        if the_line.strip.start_with?('# ')
          new_lines[the_line_index] = the_line.sub(/# /, '')
          delta -= 2
        elsif the_line.strip.start_with?('#')
          new_lines[the_line_index] = the_line.sub(/#/, '')
          delta -= 1
        else
          new_lines[the_line_index] = "# #{the_line}"
          delta += 2
        end
      end
      self.dirty_content = new_lines.join("\n")   
      if old_selection_count > 0
        self.caret_position = caret_position_for_line_index(old_caret_position_line_index)
        self.selection_count = (caret_position_for_line_index(old_end_caret_line_index + 1) - self.caret_position)
      else
        new_caret_position = old_caret_position + delta
        new_caret_position = [new_caret_position, old_caret_position_line_caret_position].max
        self.caret_position = new_caret_position
      end
    end

    def indent!
      old_lines = lines
      old_selection_count = self.selection_count
      old_caret_position = self.caret_position
      old_caret_position_line_index = line_index_for_caret_position(old_caret_position)
      old_caret_position_line_caret_position = caret_position_for_line_index(old_caret_position_line_index)
      old_end_caret_line_index = end_caret_position_line_index(caret_position, selection_count)
      new_lines = lines
      delta = 2
      line_indices_for_selection(caret_position, selection_count).each do |the_line_index|
        the_line = old_lines[the_line_index]
        new_lines[the_line_index] = "  #{the_line}"
      end
      old_caret_position = self.caret_position
      self.dirty_content = new_lines.join("\n")   
      if old_selection_count > 0
        self.caret_position = caret_position_for_line_index(old_caret_position_line_index)
        self.selection_count = (caret_position_for_line_index(old_end_caret_line_index + 1) - self.caret_position)
      else
        self.caret_position = old_caret_position + delta
      end
    end

    def outdent!
      old_lines = lines
      old_selection_count = self.selection_count
      old_caret_position = self.caret_position
      old_caret_position_line_index = line_index_for_caret_position(old_caret_position)
      old_caret_position_line_caret_position = caret_position_for_line_index(old_caret_position_line_index)
      old_end_caret_line_index = end_caret_position_line_index(caret_position, selection_count)
      new_lines = lines
      delta = 0
      line_indices_for_selection(caret_position, selection_count).each do |the_line_index|
        the_line = old_lines[the_line_index]
        if the_line.start_with?('  ')
          new_lines[the_line_index] = the_line.sub(/  /, '')
          delta = -2
        elsif the_line.start_with?(' ')
          new_lines[the_line_index] = the_line.sub(/ /, '')
          delta = -1
        end
      end
      self.dirty_content = new_lines.join("\n")   
      if old_selection_count > 0
        self.caret_position = caret_position_for_line_index(old_caret_position_line_index)
        self.selection_count = (caret_position_for_line_index(old_end_caret_line_index + 1) - self.caret_position)
      else
        new_caret_position = old_caret_position + delta
        new_caret_position = [new_caret_position, old_caret_position_line_caret_position].max
        self.caret_position = new_caret_position
      end
    end

    def kill_line!
      new_lines = lines
      line_indices = line_indices_for_selection(caret_position, selection_count)
      new_lines = new_lines[0...line_indices.first] + new_lines[(line_indices.last+1)...new_lines.size]
      old_caret_position = self.caret_position
      self.dirty_content = new_lines.join("\n")
      self.caret_position = old_caret_position
    end

    def duplicate_line!
      old_lines = lines
      old_selection_count = self.selection_count
      old_caret_position = self.caret_position
      old_caret_position_line_index = line_index_for_caret_position(old_caret_position)
      old_caret_position_line_caret_position = caret_position_for_line_index(old_caret_position_line_index)
      old_end_caret_line_index = end_caret_position_line_index(caret_position, selection_count)
      new_lines = lines
      the_line_indices = line_indices_for_selection(caret_position, selection_count)
      the_lines = lines_for_selection(caret_position, selection_count)
      delta = the_lines.join("\n").size + 1
      the_lines.each_with_index do |the_line, i|
        new_lines.insert(the_line_indices.first + i, the_line)
      end
      self.dirty_content = new_lines.join("\n")
      if old_selection_count > 0
        self.caret_position = caret_position_for_line_index(old_caret_position_line_index)
        self.selection_count = (caret_position_for_line_index(old_end_caret_line_index + 1) - self.caret_position)
      else
        self.caret_position = old_caret_position + delta
      end
    end

    def find_next
      all_lines = lines
      the_line_index = line_index_for_caret_position(caret_position)
      all_lines.rotate(the_line_index + 1).each_with_index do |the_line, the_index|
        the_index = (the_index + the_line_index + 1)%all_lines.size
        if the_line.downcase.include?(find_text.to_s.downcase)
          self.caret_position = the_line.downcase.index(find_text.to_s.downcase) + caret_position_for_line_index(the_index)
          self.selection_count = find_text.to_s.size
          return
        end
      end
    end

    def find_previous
      all_lines = lines
      the_line_index = line_index_for_caret_position(caret_position)
      all_lines.rotate(the_line_index).each_with_index.map do |the_line, the_index|
        the_index = (the_index + the_line_index)%all_lines.size
        [the_line, the_index]
      end.reverse.each do |the_line, the_index|
        if the_line.downcase.include?(find_text.to_s.downcase)
          self.caret_position = the_line.downcase.index(find_text.to_s.downcase) + caret_position_for_line_index(the_index)
          self.selection_count = find_text.to_s.size
          return
        end
      end
    end

    def page_up
      self.line_number = [(self.line_number - 15), 1].max
    end

    def page_down
      self.line_number = [(self.line_number + 15), lines.size].min
    end

    def home
      self.line_number = 1
    end

    def end
      self.line_number = lines.size
    end

    def lines
      dirty_content.split("\n")
    end

    def line_for_caret_position(caret_position)
      lines[line_index_for_caret_position(caret_position)]
    end

    def line_index_for_caret_position(caret_position)
      dirty_content[0...caret_position].count("\n")
    end

    def caret_position_for_line_index(line_index)
      lines[0...line_index].join("\n").size + 1
    end

    def line_caret_positions_for_selection(caret_position, selection_count)
      line_indices = line_indices_for_selection(caret_position, selection_count)
      line_caret_positions = line_indices.map { |line_index| caret_position_for_line_index(line_index) }.to_a
    end

    def end_caret_position_line_index(caret_position, selection_count)
      end_caret_position = caret_position + selection_count.to_i
      end_caret_position -= 1 if dirty_content[end_caret_position - 1] == "\n"
      end_line_index = line_index_for_caret_position(end_caret_position)
    end

    def lines_for_selection(caret_position, selection_count)
      line_indices = line_indices_for_selection(caret_position, selection_count)
      lines[line_indices.first..line_indices.last]
    end

    def line_indices_for_selection(caret_position, selection_count)
      start_line_index = line_index_for_caret_position(caret_position)
      if selection_count.to_i > 0
        end_line_index = end_caret_position_line_index(caret_position, selection_count)
      else
        end_line_index = start_line_index
      end
      (start_line_index..end_line_index).to_a
    end

    def children
      []
    end

    def to_s
      path
    end
  end

  def initialize
    Display.setAppName('Glimmer Editor')
    @config_file_path = '.glimmer_editor'
    RubyEditor::Dir.local_dir.all_children # pre-caches children
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
      text 'Glimmer Editor'
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
            elsif key_event.keyCode == swt(:esc)
              @text.swt_widget.setFocus
            end
          }    
        }
        composite {
          layout_data(:fill, :fill, true, true)
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
              if key_event.keyCode == swt(:cr)
                @text.swt_widget.setFocus
              end
            }
          }
          @find_text = text {
            layout_data :fill, :fill, true, false
            text bind(RubyEditor::Dir.local_dir, 'selected_child.find_text')
    	     on_key_pressed { |key_event|
              if key_event.keyCode == swt(:cr)
                RubyEditor::Dir.local_dir.selected_child.find_next
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
        	selection_count bind(RubyEditor::Dir.local_dir, 'selected_child.selection_count')
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
              RubyEditor::Dir.local_dir.selected_child.comment_line!
            elsif Glimmer::SWT::SWTProxy.include?(key_event.stateMask, :command) && key_event.character.chr.downcase == 'k'
              RubyEditor::Dir.local_dir.selected_child.kill_line!
            elsif Glimmer::SWT::SWTProxy.include?(key_event.stateMask, :command) && key_event.character.chr.downcase == 'd'
              RubyEditor::Dir.local_dir.selected_child.duplicate_line!
            elsif Glimmer::SWT::SWTProxy.include?(key_event.stateMask, :command) && key_event.character.chr.downcase == '['
              RubyEditor::Dir.local_dir.selected_child.outdent!
            elsif Glimmer::SWT::SWTProxy.include?(key_event.stateMask, :command) && key_event.character.chr.downcase == ']'
              RubyEditor::Dir.local_dir.selected_child.indent!
            elsif Glimmer::SWT::SWTProxy.include?(key_event.stateMask, :command) && key_event.character.chr.downcase == 'r'
              @filter_text.swt_widget.setFocus
            elsif Glimmer::SWT::SWTProxy.include?(key_event.stateMask, :command, :shift) && key_event.character.chr.downcase == 'g'
              RubyEditor::Dir.local_dir.selected_child.find_previous
            elsif Glimmer::SWT::SWTProxy.include?(key_event.stateMask, :command) && key_event.character.chr.downcase == 'g'
              RubyEditor::Dir.local_dir.selected_child.find_next
            elsif Glimmer::SWT::SWTProxy.include?(key_event.stateMask, :command) && key_event.character.chr.downcase == 'f'
              @find_text.swt_widget.selectAll
              @find_text.swt_widget.setFocus
            elsif Glimmer::SWT::SWTProxy.include?(key_event.stateMask, :command) && key_event.character.chr.downcase == 'l'
              @line_number_text.swt_widget.selectAll
              @line_number_text.swt_widget.setFocus
            elsif key_event.keyCode == swt(:page_up)
              RubyEditor::Dir.local_dir.selected_child.page_up
              key_event.doit = false
            elsif key_event.keyCode == swt(:page_down)
              RubyEditor::Dir.local_dir.selected_child.page_down
              key_event.doit = false
            elsif key_event.keyCode == swt(:home)
              RubyEditor::Dir.local_dir.selected_child.home
              key_event.doit = false
            elsif key_event.keyCode == swt(:end)
              RubyEditor::Dir.local_dir.selected_child.end
              key_event.doit = false
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