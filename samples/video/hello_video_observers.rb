include Glimmer

video_file = File.expand_path('../Ants.mp4', __FILE__)

def display_video_status(video, status)
  message_box = MessageBox.new(video.swt_widget.getShell)
  message_box.setText(status)
  message = "Video Position: #{video.position} seconds\n"
  message += "Video Duration: #{video.duration} seconds"
  message_box.setMessage(message)
  message_box.open
end

@shell = shell {
  minimum_size 800, 500
  @video = video(file: video_file, background: :black) {
    on_playing {
      display_video_status(@video, 'Playing')
    }
    on_paused {
      display_video_status(@video, 'Paused')
    }
    on_ended {
      display_video_status(@video, 'Ended')
    }
  }
}
@shell.open
