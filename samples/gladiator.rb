require 'yaml'
require 'filewatcher'
require 'clipboard'

Clipboard.implementation = Clipboard::Java

# Gladiator (Glimmer Editor)
class Gladiator
  include Glimmer

  class Dir
    class << self
      def local_dir
        @local_dir ||= new(ENV['LOCAL_DIR'] || '.')
      end
    end

    attr_accessor :selected_child, :filter, :children, :filtered_path_options
    attr_reader :path, :display_path

    def initialize(path)
      @path = @display_path = path
      self.filtered_path_options = []
    end

    def children
      ::Dir.glob(::File.join(@path, '*')).map {|p| ::File.file?(p) ? Gladiator::File.new(p) : Gladiator::Dir.new(p)}.sort_by {|c| c.path.to_s.downcase }.sort_by {|c| c.class.name }
    end

    def filter=(value)
      if value.to_s.empty?
        @filter = nil 
      else
        @filter = value
      end
      self.filtered_path_options = filtered.to_a.map(&:display_path)
    end

    def filtered
      return if filter.nil?
      all_children_files.select do |child| 
        child.path.downcase.include?(filter.downcase) ||
          child.path.downcase.gsub('_', '').include?(filter.downcase)
      end.sort_by {|c| c.path.to_s.downcase}
    end

    def all_children
      @all_children ||= ::Dir.glob(::File.join(@path, '**', '*')).map {|p| ::File.file?(p) ? Gladiator::File.new(p) : Gladiator::Dir.new(p)}
    end

    def all_children_files
      @all_children_files ||= all_children.select {|child| child.is_a?(Gladiator::File) }
    end

    def selected_child_path=(selected_path)
      if selected_path && ::File.file?(selected_path)
        @selected_child&.write_dirty_content
        new_child = Gladiator::File.new(selected_path)
        begin
          if new_child.lines.any?
            self.selected_child&.stop_filewatcher
            self.selected_child = new_child
            self.selected_child.start_filewatcher
          end
        rescue
          # no op
        end
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

    attr_accessor :dirty_content, :line_numbers_content, :caret_position, :selection_count, :line_number, :find_text, :replace_text, :top_index
    attr_reader :path, :display_path

    def initialize(path)
      raise "Not a file path: #{path}" unless ::File.file?(path)
      @display_path = path
      @path = ::File.expand_path(path)
      read_dirty_content = ::File.read(path)
      begin
        # test read dirty content
        read_dirty_content.split("\n")
        observe(self, :dirty_content) do
          lines_text_size = lines.size.to_s.size
          self.line_numbers_content = lines.size.times.map {|n| (' ' * (lines_text_size - (n+1).to_s.size)) + (n+1).to_s }.join("\n")
        end
        self.dirty_content = read_dirty_content
        observe(self, :caret_position) do
          self.line_number = line_index_for_caret_position(caret_position) + 1
        end
        observe(self, :line_number) do
          if line_number
            new_caret_position = lines[0...(line_number.to_i - 1)].map(&:size).sum + line_number.to_i - 1
            self.caret_position = new_caret_position unless line_index_for_caret_position(new_caret_position) == line_index_for_caret_position(caret_position)
          end
        end
      rescue
        # no op in case of a binary file
      end
    end

    def start_filewatcher
      @filewatcher = Filewatcher.new(@path)
      @thread = Thread.new(@filewatcher) do |fw| 
        fw.watch do |filename, event|
          begin
            read_dirty_content = ::File.read(path)
            # test read dirty content
            read_dirty_content.split("\n")
            async_exec do
              self.dirty_content = read_dirty_content if read_dirty_content != dirty_content
            end
          rescue
            # no op in case of a binary file
          end
        end
      end
    end
    
    def stop_filewatcher
      @filewatcher&.stop
    end

    def write_dirty_content
      new_dirty_content = "#{dirty_content.gsub("\r\n", "\n").gsub("\r", "\n").sub(/\n+\z/, '')}\n"      
      self.dirty_content = new_dirty_content if new_dirty_content != self.dirty_content
      ::File.write(path, dirty_content) if ::File.exists?(path) && dirty_content.to_s.strip.size > 0
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
      old_caret_position_line_caret_position = caret_position_for_caret_position_start_of_line(old_caret_position_line_index)
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
      return if find_text.to_s.empty?
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
      return if find_text.to_s.empty?
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

    def ensure_find_next
      find_next unless dirty_content[caret_position, find_text.size] == find_text
    end

    def replace_next
      return if find_text.to_s.empty?
      ensure_find_next
      new_dirty_content = dirty_content
      new_dirty_content[caret_position, find_text.size] = replace_text
      self.dirty_content = new_dirty_content
      find_next
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

    def move_up!
      old_lines = lines
      old_selection_count = self.selection_count
      old_caret_position = self.caret_position
      old_caret_position_line_index = line_index_for_caret_position(old_caret_position)
      old_caret_position_line_caret_position = caret_position_for_caret_position_start_of_line(old_caret_position_line_index)
      old_end_caret_line_index = end_caret_position_line_index(caret_position, selection_count)
      new_lines = lines
      the_line_indices = line_indices_for_selection(caret_position, selection_count)
      the_lines = lines_for_selection(caret_position, selection_count)
      new_line_index = [the_line_indices.first - 1, 0].max
      delta = -1 * (new_lines[new_line_index].size + 1)
      new_lines[the_line_indices.first..the_line_indices.last] = []
      new_lines[new_line_index...new_line_index] = the_lines
      self.dirty_content = new_lines.join("\n")
      if old_selection_count > 0
        self.caret_position = caret_position_for_line_index(old_caret_position_line_index) + delta
        self.selection_count = (caret_position_for_line_index(old_end_caret_line_index + 1) - self.caret_position + delta)
      else
        self.caret_position = old_caret_position + delta
      end
    end

    def move_down!
      old_lines = lines
      old_selection_count = self.selection_count
      old_caret_position = self.caret_position
      old_caret_position_line_index = line_index_for_caret_position(old_caret_position)
      old_caret_position_line_caret_position = caret_position_for_caret_position_start_of_line(old_caret_position_line_index)
      old_end_caret_line_index = end_caret_position_line_index(caret_position, selection_count)
      new_lines = lines
      the_line_indices = line_indices_for_selection(caret_position, selection_count)
      the_lines = lines_for_selection(caret_position, selection_count)
      new_line_index = [the_line_indices.first + 1, new_lines.size - 1].min
      delta = new_lines[new_line_index].size + 1
      new_lines[the_line_indices.first..the_line_indices.last] = []
      new_lines[new_line_index...new_line_index] = the_lines
      self.dirty_content = new_lines.join("\n")
      if old_selection_count > 0
        self.caret_position = caret_position_for_line_index(old_caret_position_line_index) + delta
        self.selection_count = (caret_position_for_line_index(old_end_caret_line_index + 1) - self.caret_position + delta)
      else
        self.caret_position = old_caret_position + delta
      end
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

    def caret_position_for_caret_position_start_of_line(caret_position)
      caret_position_for_line_index(line_index_for_caret_position(caret_position))
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
    Display.setAppName('Gladiator')
    @config_file_path = '.gladiator'
    @config = {}
    Gladiator::Dir.local_dir.all_children # pre-caches children
    load_config  
  end

  def load_config
    if ::File.exists?(@config_file_path)
      config_yaml = ::File.read(@config_file_path)
      return if config_yaml.to_s.strip.empty?
      @config = YAML.load(config_yaml)
      Gladiator::Dir.local_dir.selected_child_path = @config[:selected_child_path] if @config[:selected_child_path]
      Gladiator::Dir.local_dir.selected_child.caret_position  = Gladiator::Dir.local_dir.selected_child.caret_position_for_caret_position_start_of_line(@config[:caret_position]) if @config[:caret_position]
      Gladiator::Dir.local_dir.selected_child.top_index = @config[:top_index] if @config[:top_index]
    end
  end

  def save_config
    child = Gladiator::Dir.local_dir.selected_child
    return if child.nil?
    @config = {
      selected_child_path: child.path,
      caret_position: child.caret_position,
      top_index: child.top_index,
    }
    config_yaml = YAML.dump(@config)
    ::File.write(@config_file_path, config_yaml) unless config_yaml.to_s.empty?
  rescue => e
    puts e.full_message
  end

  def launch
    @display = display {
      on_event_keydown { |key_event|
        if Glimmer::SWT::SWTProxy.include?(key_event.stateMask, :command) && key_event.character.chr.downcase == 'f'
          if @text.swt_widget.getSelectionText && @text.swt_widget.getSelectionText.size > 0
            @find_text.swt_widget.setText @text.swt_widget.getSelectionText
          end
          @find_text.swt_widget.selectAll
          @find_text.swt_widget.setFocus
        elsif Glimmer::SWT::SWTProxy.include?(key_event.stateMask, :command, :shift) && key_event.character.chr.downcase == 'c'
          Clipboard.copy(Gladiator::Dir.local_dir.selected_child.path)
        elsif Glimmer::SWT::SWTProxy.include?(key_event.stateMask, :command, :shift) && key_event.character.chr.downcase == 'g'
          Gladiator::Dir.local_dir.selected_child.find_previous
        elsif Glimmer::SWT::SWTProxy.include?(key_event.stateMask, :command) && key_event.character.chr.downcase == 'g'
          Gladiator::Dir.local_dir.selected_child.find_next
        elsif Glimmer::SWT::SWTProxy.include?(key_event.stateMask, :command) && key_event.character.chr.downcase == 'l'
          @line_number_text.swt_widget.selectAll
          @line_number_text.swt_widget.setFocus
        elsif Glimmer::SWT::SWTProxy.include?(key_event.stateMask, :command) && key_event.character.chr.downcase == 'r'
          @filter_text.swt_widget.selectAll
          @filter_text.swt_widget.setFocus
        elsif Glimmer::SWT::SWTProxy.include?(key_event.stateMask, :command) && key_event.character.chr.downcase == 't'
          @tree.swt_widget.setFocus
        end
      }
    }
    @shell = shell {
      text "Gladiator - #{::File.expand_path(Gladiator::Dir.local_dir.path)}"
      minimum_size 720, 450
      size 1440, 900 
      grid_layout 2, false
      on_event_close {
        Gladiator::Dir.local_dir.selected_child&.write_dirty_content
      }
      on_widget_disposed {
        Gladiator::Dir.local_dir.selected_child&.write_dirty_content
      }
      composite {
        grid_layout 1, false
        layout_data(:fill, :fill, false, true) {
          width_hint 300
        }
        @filter_text = text {
          layout_data :fill, :center, true, false
          text bind(Gladiator::Dir.local_dir, 'filter')
    	   on_key_pressed { |key_event|
            if key_event.keyCode == swt(:tab) || 
                key_event.keyCode == swt(:cr) || 
                key_event.keyCode == swt(:lf) ||
                key_event.keyCode == swt(:arrow_up) ||
                key_event.keyCode == swt(:arrow_down)
              @list.swt_widget.setFocus
            elsif key_event.keyCode == swt(:esc)
              @text.swt_widget.setFocus
            end
          }    
        }
        composite {
          layout_data(:fill, :fill, true, true)
          @list = list(:border, :h_scroll, :v_scroll) {
            layout_data(:fill, :fill, true, true) {
              #exclude bind(Gladiator::Dir.local_dir, :filter) {|f| !f}
            }
            #visible bind(Gladiator::Dir, 'local_dir.filter') {|f| !!f}
            selection bind(Gladiator::Dir.local_dir, :filtered_path)
            on_widget_selected {
              Gladiator::Dir.local_dir.selected_child_path = @list.swt_widget.getSelection.first
            }
       	  on_key_pressed { |key_event|
              if Glimmer::SWT::SWTProxy.include?(key_event.keyCode, :cr) || Glimmer::SWT::SWTProxy.include?(key_event.keyCode, :lf)
                Gladiator::Dir.local_dir.selected_child_path = @list.swt_widget.getSelection.first
                @text.swt_widget.setFocus
              end
            }
          }
          @tree = tree(:virtual, :border, :h_scroll, :v_scroll) {
            layout_data(:fill, :fill, true, true) {
              #exclude bind(Gladiator::Dir.local_dir, :filter) {|f| !!f}
            }
            #visible bind(Gladiator::Dir, 'local_dir.filter') {|f| !f}
            items bind(Gladiator::Dir, :local_dir), tree_properties(children: :children, text: :display_path)
            on_widget_selected {
              Gladiator::Dir.local_dir.selected_child_path = @tree.swt_widget.getSelection.first.getText
            }
            on_paint_control {
              root_item = @tree.swt_widget.getItems.first
              if root_item && !root_item.getExpanded
                root_item.setExpanded true
              end
            }
          }
        }
      }
      composite {
        grid_layout 1, false
        layout_data :fill, :fill, true, true
        composite {
          grid_layout 2, false
          @file_path_label = styled_text(:none) {
            layout_data(:fill, :fill, true, false) {
              horizontal_span 2
            }
            background color(:widget_background)
            editable false
            caret nil
            text bind(Gladiator::Dir.local_dir, 'selected_child.path')
            on_mouse_up {
              @file_path_label.swt_widget.selectAll
            }
            on_focus_lost {
              @file_path_label.swt_widget.setSelection(0, 0)
            }
          }
          label {
            text 'Line:'
          }
          @line_number_text = text {
            layout_data(:fill, :fill, true, false) {
              minimum_width 200
            }
            text bind(Gladiator::Dir.local_dir, 'selected_child.line_number', on_read: :to_s, on_write: :to_i)
    	     on_key_pressed { |key_event|
              if key_event.keyCode == swt(:cr)
                @text.swt_widget.setFocus
              end
            }
          }
          label {
            text 'Find:'
          }
          @find_text = text {
            layout_data(:fill, :fill, true, false) {
              minimum_width 200
            }
            text bind(Gladiator::Dir.local_dir, 'selected_child.find_text')
    	     on_key_pressed { |key_event|
              if key_event.keyCode == swt(:cr)
                Gladiator::Dir.local_dir.selected_child.find_next
              elsif key_event.keyCode == swt(:esc)
                @text.swt_widget.setFocus
              end
            }
          }
          label {
            text 'Replace:'
          }
          @replace_text = text {
            layout_data(:fill, :fill, true, false) {
              minimum_width 200
            }
            text bind(Gladiator::Dir.local_dir, 'selected_child.replace_text')
            on_focus_gained {              
              Gladiator::Dir.local_dir.selected_child.ensure_find_next
            }
    	     on_key_pressed { |key_event|
              if key_event.keyCode == swt(:cr)
                Gladiator::Dir.local_dir.selected_child.replace_next
              elsif key_event.keyCode == swt(:esc)
                @text.swt_widget.setFocus
              end
            }
          }
        }
        composite {
          layout_data :fill, :fill, true, true
          grid_layout 2, false  
          @line_numbers_text = text(:multi) {
            layout_data(:right, :fill, false, true)
            font name: 'Consolas', height: 15
            background color(:widget_background)
            foreground rgb(75, 75, 75)
            text bind(Gladiator::Dir.local_dir, 'selected_child.line_numbers_content')
            top_index bind(Gladiator::Dir.local_dir, 'selected_child.top_index')
            on_focus_gained {
              @text&.swt_widget.setFocus
            }
            on_key_pressed {
              @text&.swt_widget.setFocus
            }
            on_mouse_up {
              @text&.swt_widget.setFocus
            }
          }
          @text = text(:multi, :border, :h_scroll, :v_scroll) {
            layout_data :fill, :fill, true, true
            font name: 'Consolas', height: 15
            foreground rgb(75, 75, 75)
            text bind(Gladiator::Dir.local_dir, 'selected_child.dirty_content')
            focus true
            caret_position bind(Gladiator::Dir.local_dir, 'selected_child.caret_position')
            selection_count bind(Gladiator::Dir.local_dir, 'selected_child.selection_count')
            top_index bind(Gladiator::Dir.local_dir, 'selected_child.top_index')
            on_focus_lost {
              Gladiator::Dir.local_dir.selected_child&.write_dirty_content
            }
      	     on_key_pressed { |key_event|
              if Glimmer::SWT::SWTProxy.include?(key_event.stateMask, :command) && key_event.character.chr.downcase == '/'
                Gladiator::Dir.local_dir.selected_child.comment_line!
              elsif Glimmer::SWT::SWTProxy.include?(key_event.stateMask, :command) && key_event.character.chr.downcase == 'k'
                Gladiator::Dir.local_dir.selected_child.kill_line!
              elsif Glimmer::SWT::SWTProxy.include?(key_event.stateMask, :command) && key_event.character.chr.downcase == 'd'
                Gladiator::Dir.local_dir.selected_child.duplicate_line!
              elsif Glimmer::SWT::SWTProxy.include?(key_event.stateMask, :command) && key_event.character.chr.downcase == '['
                Gladiator::Dir.local_dir.selected_child.outdent!
              elsif Glimmer::SWT::SWTProxy.include?(key_event.stateMask, :command) && key_event.character.chr.downcase == ']'
                Gladiator::Dir.local_dir.selected_child.indent!
              elsif key_event.keyCode == swt(:page_up)
                Gladiator::Dir.local_dir.selected_child.page_up
                key_event.doit = false
              elsif key_event.keyCode == swt(:page_down)
                Gladiator::Dir.local_dir.selected_child.page_down
                key_event.doit = false
              elsif key_event.keyCode == swt(:home)
                Gladiator::Dir.local_dir.selected_child.home
                key_event.doit = false
              elsif key_event.keyCode == swt(:end)
                Gladiator::Dir.local_dir.selected_child.end
                key_event.doit = false
              elsif key_event.stateMask == swt(:command) && key_event.keyCode == swt(:arrow_up)
                Gladiator::Dir.local_dir.selected_child.move_up!
                key_event.doit = false
              elsif key_event.stateMask == swt(:command) && key_event.keyCode == swt(:arrow_down)
                Gladiator::Dir.local_dir.selected_child.move_down!
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
    }
    observe(Gladiator::Dir.local_dir, 'selected_child.line_numbers_content') do
      if @last_line_numbers_content != Gladiator::Dir.local_dir.selected_child.line_numbers_content
        @shell.pack_same_size
        @last_line_numbers_content = Gladiator::Dir.local_dir.selected_child.line_numbers_content
      end
    end
    observe(Gladiator::Dir.local_dir, 'selected_child.caret_position') do
      save_config
    end
    observe(Gladiator::Dir.local_dir, 'selected_child.top_index') do
      save_config
    end
    @shell.open
  end
end

Gladiator.new.launch
