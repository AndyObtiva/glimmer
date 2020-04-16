require 'glimmer/ui/custom_widget'
require 'glimmer/swt/color_proxy'

#TODO display progress wheel while loading video

module Glimmer
  module UI
    class Video
      include Glimmer::UI::CustomWidget

      include_package 'org.eclipse.swt.browser'

      PROPERTIES_OBSERVED = [
        'playing',
        'paused',
        'ended',
        'started',
        'remaining',
        'current_time',
      ]

      options :file, :url
      option :autoplay, true
      option :controls, true
      option :looped, false
      option :background, :white
      option :fit_to_width, true
      option :fit_to_height, true
      option :offset_x, 0
      option :offset_y, 0

      alias autoplay? autoplay
      alias controls? controls
      alias looped? looped
      alias fit_to_width? fit_to_width
      alias fit_to_height? fit_to_height

      body {
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
                <style id="style-body-offset-x">
                  body {
                    margin-left: #{browser_body_offset_x}px;
                  }
                </style>
                <style id="style-body-offset-y">
                  body {
                    margin-top: #{browser_body_offset_y}px;
                  }
                </style>
              </head>
              <body>
                <video id="video" #{browser_video_width} #{browser_video_height} #{browser_video_loop} #{browser_video_controls} #{browser_video_autoplay}>
                  <source id="source" src="#{source}" type="video/mp4">
                Your browser does not support the video tag.
                </video>
              </body>
            </html>
          HTML
          on_completed {
            @completed = true
          }
        }
      }

      def source
        file_source = file
        if file_source
          if file_source.start_with?('uri:classloader')
            file_path = file_source.split(/\/\//).last
            file_name = File.basename(file_source)
            # supporting windows ENV['temp'] or mac/unix /tmp
            tmp_dir = ENV['temp'] ? File.expand_path(ENV['temp']) : '/tmp'
            tmp_dir += '/glimmer/lib/glimmer/ui/video'
            FileUtils.mkdir_p(tmp_dir)
            tmp_file = File.join(tmp_dir, file_name)
            file_content = File.binread(file_source) rescue File.binread(file_path)
            File.binwrite(tmp_file, file_content)
            "file://#{tmp_file}"
          else
            "file://#{file_source}"
          end
        else
          url
        end
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

      def paused?
        video_attribute('paused')
      end

      def playing?
        !paused?
      end

      def ended?
        video_attribute('ended')
      end

      # Video fully loaded and ready for playback
      def canplay?
        video_attribute('canplay')
      end

      def position
        video_attribute('currentTime')
      end

      def position=(new_position)
        video_attribute_set('currentTime', new_position)
      end

      def duration
        video_attribute('duration')
      end

      def can_handle_observation_request?(observation_request)
        result = false
        if observation_request.start_with?('on_video_')
          attribute = observation_request.sub(/^on_video_/, '')
          result = can_add_observer?(attribute)
        end
        result || super
      end

      def handle_observation_request(observation_request, &block)
        if observation_request.start_with?('on_video_')
          attribute = observation_request.sub(/^on_video_/, '')
          add_video_observer(block, attribute) if can_add_observer?(attribute)
        else
          super
        end
      end

      private

      class VideoObserverBrowserFunction < BrowserFunction
        def initialize(video, observer_proc, attribute)
          @observer_proc = observer_proc
          @attribute = attribute
          name = self.class.generate_name(@attribute)
          super(video.swt_widget, name)
        end

        def function(arguments)
          @observer_proc.call
        rescue => e
          Glimmer.logger.error "#{e.message}\n#{e.backtrace.join("\n")}"
        ensure
          nil
        end

        private

        class << self
          def generate_name(attribute)
            "video#{attribute}#{generate_attribute_id(attribute)}"
          end

          def generate_attribute_id(attribute)
            attribute_max_ids[attribute] = attribute_max_id(attribute) + 1
          end

          def attribute_max_id(attribute)
            attribute_max_ids[attribute] ||= 0
          end

          def attribute_max_ids
            @attribute_max_ids ||= {}
          end
        end
      end

      def video_action(action)
        run_on_completed do
          swt_widget.execute("document.getElementById('video').#{action}()")
        end
      end

      def video_attribute(attribute)
        swt_widget.evaluate("return document.getElementById('video').#{attribute}") if @completed
      end

      def video_attribute_set(attribute, value)
        value = "'#{value}'" if value.is_a?(String) || value.is_a?(Symbol)
        run_on_completed do
          swt_widget.execute("document.getElementById('video').#{attribute} = #{value}")
        end
      end

      def add_video_observer(observer_proc, attribute)
        run_on_completed do
          video_observer_browser_function = VideoObserverBrowserFunction.new(self, observer_proc, attribute)
          swt_widget.execute("document.getElementById('video').addEventListener('#{attribute}', function() {#{video_observer_browser_function.getName}()})")
        end
      end

      def run_on_completed(&block)
        if @completed
          block.call
        else
          on_completed(&block)
        end
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

      def browser_video_width
        "width='100%'" if fit_to_width
      end

      def browser_video_height
        "height='100%'" if fit_to_height
      end

      def browser_body_background
        color = background
        if color.is_a?(Symbol) || color.is_a?(String)
          color = SWT::ColorProxy.new(color).swt_color
        elsif color.is_a?(SWT::ColorProxy)
          color = color.swt_color
        end
        "rgba(#{color.getRed}, #{color.getGreen}, #{color.getBlue}, #{color.getAlpha})"
      end

      def browser_body_offset_x
        offset_x
      end

      def browser_body_offset_y
        offset_y
      end
    end
  end
end