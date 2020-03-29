require_relative 'custom_widget'
require_relative 'g_color'

module Glimmer
  module SWT
    class Video
      include Glimmer::SWT::CustomWidget

      options :file, :url
      option :autoplay, true
      option :controls, false
      option :looped, false
      option :background, :white

      alias autoplay? autoplay
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
          on_completed {
            @loaded = true
          }
        }
      end

      def play
        video_action('play')
      end

      def pause
        video_action('pause')
      end

      def reload
        video_action('load')
      end

      def rewind
        self.current_time = 0
      end

      def loaded?
        !!@loaded
      end

      def ended?
        video_property('ended')
      end

      def current_time
        video_property('currentTime')
      end

      def duration
        video_property('duration')
      end

      def current_time=(time)
        video_property_set('currentTime', time)
      end

      def background=(new_background)
        options[:background] = new_background
        on_loaded do
          style_background = "body { background: #{browser_body_background}; }"
          widget.execute("document.getElementById('style-body-background').innerHTML='#{style_background}'")
        end
      end

      def paused?
        video_property('paused')
      end

      def file=(new_file)
        options[:file] = new_file
        options[:url] = nil
        update_source
      end

      def url=(new_url)
        options[:url] = new_url.match(/^https?\:\/\//) ? new_url : "http://#{new_url}"
        options[:file] = nil
        update_source
      end

      def looped=(new_looped)
        options[:looped] = new_looped
        video_property_set('loop', looped)
      end

      def source
        file ? "file://#{options[:file]}" : url
      end

      def video_action(action)
        on_loaded do
          widget.execute("document.getElementById('video').#{action}()")
        end
      end

      def video_property(property)
        on_loaded do
          widget.evaluate("return document.getElementById('video').#{property}")
        end
      end

      def video_property_set(property, value)
        on_loaded do
          value = "'#{value}'" if value.is_a?(String) || value.is_a?(Symbol)
          widget.execute("document.getElementById('video').#{property}=#{value}")
        end
      end

      def on_loaded(&block)
        if loaded?
          block.call
        else
          add_contents(body_root) {
            on_completed {
              block.call
              # TODO unregister listener
            }
          }
        end
      end

      private

      def browser_video_autoplay
        'autoplay' if autoplay?
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

      def update_source
        on_loaded do
          widget.execute("document.getElementById('source').src='#{source}'")
          widget.execute("document.getElementById('video').src='#{source}'")
        end
      end
    end
  end
end
