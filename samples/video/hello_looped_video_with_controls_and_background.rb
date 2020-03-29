include Glimmer

video_file = File.expand_path('../Blackpool_Timelapse.mp4', __FILE__)

shell {
  grid_layout
  video(file: video_file, looped: true, controls: true, background: :black) {
    layout_data {
      width_hint 1024
      height_hint 640
    }
  }
}.open
