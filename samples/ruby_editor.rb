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

  def launch
    @shell = shell {
      text 'Ruby Editor'
      minimum_size 1280, 960
      @tree = tree(:virtual, :border) {
        items bind(RubyEditor::Dir, :local_children), tree_properties(children: :children, text: :path)
        on_widget_selected {
          selected_path = @tree.swt_widget.getSelection.first.getText
          if ::File.file?(selected_path)
            ::File.write(@label.swt_widget.getText, @text.swt_widget.getText) unless @label.swt_widget.getText.to_s.empty?
            @label.swt_widget.setText @tree.swt_widget.getSelection.first.getText
            @text.swt_widget.setText ::File.read(selected_path)
          end
        }
      }
      composite {
        grid_layout 1, false
        @label = label {
          layout_data :fill, :center, true, false
        }
        @text = text(:multi, :h_scroll, :v_scroll) {
          layout_data :fill, :fill, true, true
          font name: 'courier new', height: 13
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
