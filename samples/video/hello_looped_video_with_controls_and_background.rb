include Glimmer

video_file = File.expand_path('../Blackpool_Timelapse.mp4', __FILE__)

shell {
  minimum_size 1024, 640
  video(file: video_file, looped: true, controls: true, background: :black)
}.open
