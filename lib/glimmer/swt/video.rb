require_relative 'custom_widget'
require_relative 'g_color'

module Glimmer
  module SWT
    class Video
      include_package 'org.eclipse.swt.browser'

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
            register_observers
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

      # TODO rename to initialized
      def loaded
        !!@loaded
      end
      alias loaded? loaded

      def ended
        video_property('ended')
      end
      alias ended? ended

      def started
        current_time > 0
      end
      alias started? started

      def paused
        video_property('paused')
      end
      alias paused? paused

      def playing
        !paused
      end
      alias playing? playing

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
        widget.evaluate("return document && document.getElementById('video') && document.getElementById('video').#{property}")
      end

      def video_property_set(property, value)
        on_loaded do
          value = "'#{value}'" if value.is_a?(String) || value.is_a?(Symbol)
          widget.execute("document.getElementById('video').#{property}=#{value}")
        end
      end

      #TODO rename to on_initialized to avoid confusiong with on_loaded for video oncanplay event listener
      def on_loaded(&block)
        if loaded?
          block.call
        else
          add_contents(body_root) {
            on_completed {
              block.call
              # TODO unregister listener?
            }
          }
        end
      end

      private

      class VideoEventHandler < BrowserFunction
        PROPERTIES_OBSERVED = [
          'playing',
          'paused',
          'ended',
        ]

        attr_reader :video, :event

        def initialize(video, event)
          @video = video
          @event = event
          function_name = "notify_#{event}"
          browser = video.widget
          super(browser, function_name)
        end

        def function(arguments)
          # pd event
          # property_name = MAPPING_EVENTS_TO_PROPERTIES[event]
          # pd property_name
          # pd send(property_name)
          PROPERTIES_OBSERVED.each do |property|
            @video.notify_observers(property)
          end
          # @video.notify_observers(property_name)
          true
        rescue => e
          Glimmer.logger.error "#{e.message}\n#{e.backtrace.join("\n")}"
          false
        end
      end

      def register_observers
        require 'puts_debuggerer'
        register_observer('play')
        register_observer('pause')
        register_observer('ended')
      end

      def register_observer(event)
        video_event_handler = VideoEventHandler.new(self, event)
        widget.execute("document.getElementById('video').on#{event} = function() {#{video_event_handler.getName}()}")
      end

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
