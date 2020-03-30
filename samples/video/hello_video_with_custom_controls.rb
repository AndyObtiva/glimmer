include Glimmer

class VideoPlayer
  attr_reader :web_url
  attr_accessor :video_widget

  def initialize(web_url)
    @web_url = web_url
  end

  def video_widget=(new_video_widget)
    pd new_video_widget, header: true, announcer: '[VIDEO_WIDGET_SET]'
    @video_widget = new_video_widget
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
          text "Play"
          enabled bind(self, 'video_widget.paused')
          on_widget_selected {
            video_widget.play
          }
        }
        button {
          text "Pause"
          enabled bind(self, 'video_widget.playing')
          on_widget_selected {
            video_widget.pause
          }
        }
        # button {
        #   text "Rewind"
        #   enabled bind(@video, :started)
        #   on_widget_selected {
        #     @video.rewind
        #   }
        # }
      }
      self.video_widget = video(url: web_url) {
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

web_url = "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4"
VideoPlayer.new(web_url).launch
