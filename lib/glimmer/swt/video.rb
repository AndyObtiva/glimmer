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

      option :autoplay, true
      option :controls, true
      option :looped, false
      option :background, :white

      alias autoplay? autoplay
      alias controls? controls
      alias looped? looped

      attr_accessor :file, :url

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
            @initialized = true
            register_observers
          }
        }
      end

      def play
        video_action('play')
        notify_all_property_observers
      end

      def pause
        video_action('pause')
        notify_all_property_observers
      end

      def reload
        video_action('load')
        notify_all_property_observers
      end

      def restart
        self.current_time = 0
      end

      def initialized
        !!@initialized
      end
      alias initialized? initialized

      def ended
        video_property('ended')
      end
      alias ended? ended

      def remaining
        !ended
      end
      alias remaining? remaining

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
        video_property('currentTime').to_f
      end

      def duration
        video_property('duration').to_f
      end

      def current_time=(time)
        video_property_set('currentTime', time)
        notify_all_property_observers
      end

      def background=(new_background)
        options[:background] = new_background
        on_initialized do
          style_background = "body { background: #{browser_body_background}; }"
          widget.execute("document.getElementById('style-body-background').innerHTML='#{style_background}'")
        end
      end

      def file=(new_file)
        @file = new_file
        @url = nil
        update_source
      end

      def url=(new_url)
        @url = new_url.match(/^https?\:\/\//) ? new_url : "http://#{new_url}"
        @file = nil
        update_source
      end

      def looped=(new_looped)
        options[:looped] = new_looped
        video_property_set('loop', looped)
      end

      def source
        file ? "file://#{file}" : url
      end

      def video_action(action)
        on_initialized do
          widget.execute("document.getElementById('video').#{action}()")
        end
      end

      def video_property(property)
        widget.evaluate("return document && document.getElementById('video') && document.getElementById('video').#{property}")
      end

      def video_property_set(property, value)
        on_initialized do
          value = "'#{value}'" if value.is_a?(String) || value.is_a?(Symbol)
          widget.execute("document.getElementById('video').#{property}=#{value}")
        end
      end

      # Runs block once video widget is fully initialized
      def on_initialized(&block)
        # TODO see if we still need this on_completed after we decided to set video after construction
        if initialized?
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

      def notify_all_property_observers
        PROPERTIES_OBSERVED.each do |property|
          notify_observers(property)
        end
      end

      def register_observer(event, &handler)
        video_event_handler = VideoEventHandler.new(self, event, &handler)
        widget.execute("document.getElementById('video').on#{event} = function() {#{video_event_handler.getName}()}")
      end

      private

      class VideoEventHandler < BrowserFunction

        attr_reader :video, :event

        def initialize(video, event, &handler)
          @video = video
          @event = event
          @handler = handler
          function_name = "notify_#{event}"
          browser = video.widget
          super(browser, function_name)
        end

        def function(arguments)
          @handler.call
          nil
        end
      end

      def register_observers
        register_observer('play') {notify_all_property_observers}
        register_observer('pause') {notify_all_property_observers}
        register_observer('ended') {notify_all_property_observers}
        register_observer('timeupdate') {notify_all_property_observers}
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
        on_initialized do
          widget.execute("document.getElementById('source').src='#{source}'")
          widget.execute("document.getElementById('video').src='#{source}'")
        end
      end
    end
  end
end
