require 'puts_debuggerer'

class RubyEditor
  include Glimmer

  class Dir
    class << self
      def local_children
        new('.')
      end
    end
    
    attr_reader :path

    def initialize(path)
      @path = path
    end

    def children
      ::Dir.glob(::File.join(@path, '*')).map {|p| ::File.file?(p) ? RubyEditor::File.new(p) : RubyEditor::Dir.new(p)}
    end
  end

  class File
    attr_reader :path

    def initialize(path)
      @path = path
    end

    def children
      []
    end
  end

  def initialize
    @config_file_path = ::File.expand_path('../ruby_editor.config', __FILE__)
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
        items bind(RubyEditor::Dir, :local_children), tree_properties(children: :children, text: :path)
        on_widget_selected {
          selected_path = @tree.swt_widget.getSelection.first.getText
          last_selected_path = @label.swt_widget.getText
          if ::File.file?(selected_path)
            ::File.write(last_selected_path, @text.swt_widget.getText) unless last_selected_path.to_s.empty?
            @label.swt_widget.setText selected_path
            @text.swt_widget.setText ::File.read(selected_path)
            ::File.write(@config_file_path, selected_path)
          end
        }
      }
      composite {
        grid_layout 1, false
        layout_data :fill, :fill, true, true
        @label = label {
          layout_data :fill, :center, true, false
          text ::File.read(@config_file_path) if ::File.exists?(@config_file_path)
        }
        @text = text(:multi, :h_scroll, :v_scroll) {
          layout_data :fill, :fill, true, true
          font name: 'Consolas', height: 15
          foreground rgb(75, 75, 75)
          text ::File.read(::File.read(@config_file_path)) unless @label.swt_widget.getText.to_s.empty?
          on_focus_lost {
            ::File.write(@label.swt_widget.getText, @text.swt_widget.getText) unless @label.swt_widget.getText.to_s.empty? || !::File.file?(@label.swt_widget.getText)
          }
        }
      }
    }
    @shell.open
  end
end

RubyEditor.new.launch
