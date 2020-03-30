require 'puts_debuggerer'
# Glimmer.logger.level = Logger::DEBUG

class WebVideoPlayer
  include Glimmer

  attr_reader :web_url
  attr_accessor :video_widget

  def initialize(web_url)
    @web_url = web_url
  end

  def launch
    @shell = shell {
      grid_layout
      minimum_size 1138, 640
      composite {
        grid_layout {
          num_columns 3
        }
        layout_data {
          horizontal_alignment :center
          vertical_alignment :center
          grab_excess_horizontal_space true
          grab_excess_vertical_space false
        }
        button {
          layout_data {
            horizontal_alignment :fill
            vertical_alignment :fill
          }
          text "Play"
          enabled bind(self, 'video_widget.paused')
          on_widget_selected {
            video_widget.play
          }
        }
        button {
          layout_data {
            horizontal_alignment :fill
            vertical_alignment :fill
          }
          text "Pause"
          enabled bind(self, 'video_widget.playing')
          on_widget_selected {
            video_widget.pause
          }
        }
        button {
          layout_data {
            horizontal_alignment :fill
            vertical_alignment :fill
          }
          text "Restart"
          enabled bind(self, 'video_widget.started')
          on_widget_selected {
            video_widget.restart
          }
        }
        button {
          layout_data {
            horizontal_alignment :fill
            vertical_alignment :fill
          }
          text "Backward"
          enabled bind(self, 'video_widget.started')
          on_widget_selected {
            video_widget.current_time = [video_widget.current_time - 15, 0].max
          }
        }
        label {
          layout_data {
            horizontal_alignment :fill
            vertical_alignment :center
          }
          text bind(self, 'video_widget.current_time')
        }
        button {
          layout_data {
            horizontal_alignment :fill
            vertical_alignment :fill
          }
          text "Forward"
          enabled bind(self, 'video_widget.remaining')
          on_widget_selected {
            video_widget.current_time = [video_widget.current_time + 15, video_widget.duration].min
          }
        }
      }
      self.video_widget = video(controls: false) {
        url web_url
        layout_data {
          horizontal_alignment :fill
          vertical_alignment :fill
          grab_excess_horizontal_space true
          grab_excess_vertical_space true
        }
      }
    }
    @shell.open
  end
end

web_url = "https://ia802603.us.archive.org/26/items/scm-140094-snowboardingatthedowntownthro/pii____downtown_throwdown_on_o__filer.mp4"
WebVideoPlayer.new(web_url).launch
