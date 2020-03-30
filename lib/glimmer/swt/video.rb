require_relative 'custom_widget'
require_relative 'g_color'

#TODO display progress wheel while loading video

module Glimmer
  module SWT
    class Video
      PROPERTIES_OBSERVED = [
        'playing',
        'paused',
        'ended',
        'started',
        'remaining',
        'current_time',
      ]

      include_package 'org.eclipse.swt.browser'

      include Glimmer::SWT::CustomWidget

      options :file, :url
      option :controls, true
      option :looped, false
      option :background, :white

      alias controls? controls
      alias looped? looped

      def body
        browser {
          text <<~HTML
            <html>
              <head>
                <style id="style">
                  body {
                    margin: 0;
                    padding: 0;
                  }
                </style>
                <style id="style-body-background">
                  body {
                    background: #{browser_body_background};
                  }
                </style>
              </head>
              <body>
                <video id="video" width="100%" height="100%" #{browser_video_loop} #{browser_video_controls} #{browser_video_autoplay}>
                  <source id="source" src="#{source}" type="video/mp4">
                Your browser does not support the video tag.
                </video>
              </body>
            </html>
          HTML
        }
      end

      def source
        file ? "file://#{file}" : url
      end

      private

      def browser_video_autoplay
        'autoplay'
      end

      def browser_video_controls
        'controls' if controls?
      end

      def browser_video_loop
        'loop' if looped?
      end

      def browser_body_background
        color = background
        if color.is_a?(Symbol) || color.is_a?(String)
          color = GColor.color_for(parent.widget.getDisplay, color)
        elsif color.is_a?(GColor)
          color = color.color
        end
        "rgba(#{color.getRed}, #{color.getGreen}, #{color.getBlue}, #{color.getAlpha})"
      end
    end
  end
end
