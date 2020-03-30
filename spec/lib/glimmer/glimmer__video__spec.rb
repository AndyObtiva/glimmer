require "spec_helper"

module Glimmer
  describe "Glimmer Video" do
    include Glimmer

    before do
      @rspec_display_method = method(:display)
      self.class.send(:undef_method, :display)
      dsl :swt
    end

    after do
      self.class.send(:define_method, :display, @rspec_display_method)
      @target&.start_event_loop
    end

    let(:video_file) { File.expand_path('../../../fixtures/videos/Pepa-creativeCommonsMp4956_512kb.mp4', __FILE__) }
    let(:video_url) { "http://www.youtube.com/fdajiew" }
    let(:video_url_truncated) { "www.youtube.com/fdajiew" }

    it "sets video source by file option property" do
      @target = shell
      add_contents(@target) {
        @video = video {
          file video_file
          on_completed {
            expect(@video.widget.evaluate("return document.getElementById('source').src")).to eq("file://#{video_file}")
            @target.widget.close
          }
        }
      }
    end

    it "sets video source by file option setter method" do
      @target = shell
      add_contents(@target) {
        @video = video {
          on_completed {
            @video.file = video_file
            expect(@video.widget.evaluate("return document.getElementById('source').src")).to eq("file://#{video_file}")
            @target.widget.close
          }
        }
      }
    end

    it "sets video source by url option property" do
      @target = shell
      add_contents(@target) {
        @video = video {
          url video_url
          on_completed {
            expect(@video.widget.evaluate("return document.getElementById('source').src")).to eq(video_url)
            @target.widget.close
          }
        }
      }
    end

    it "sets video source by url option setter method" do
      @target = shell
      add_contents(@target) {
        @video = video {
          on_completed {
            @video.url = video_url
            expect(@video.widget.evaluate("return document.getElementById('source').src")).to eq(video_url)
            @target.widget.close
          }
        }
      }
    end

    it "sets video source by url option property missing http://" do
      @target = shell
      add_contents(@target) {
        @video = video {
          url video_url_truncated
          on_completed {
            expect(@video.widget.evaluate("return document.getElementById('source').src")).to eq(video_url)
            @target.widget.close
          }
        }
      }
    end

    it "autoplays video by default" do
      @target = shell
      add_contents(@target) {
        @video = video {
          file video_file
          on_completed {
            expect(@video.video_property('autoplay')).to eq(true)
            @target.widget.close
          }
        }
      }
    end

    it "displays video controls by default" do
      @target = shell
      add_contents(@target) {
        @video = video {
          file video_file
          on_completed {
            expect(@video.video_property('controls')).to eq(true)
            @target.widget.close
          }
        }
      }
    end

    it "does not display video controls when specified as an option argument" do
      @target = shell
      add_contents(@target) {
        @video = video(controls: false) {
          file video_file
          on_completed {
            expect(@video.video_property('controls')).to eq(false)
            @target.widget.close
          }
        }
      }
    end

    it "does not loop video by default" do
      @target = shell
      add_contents(@target) {
        @video = video {
          file video_file
          on_completed {
            expect(@video.video_property('loop')).to eq(false)
            @target.widget.close
          }
        }
      }
    end

    it "loops video when specified as an option argument" do
      @target = shell
      add_contents(@target) {
        @video = video(looped: true) {
          file video_file
          on_completed {
            expect(@video.video_property('loop')).to eq(true)
            @target.widget.close
          }
        }
      }
    end

    it "loops video when specified as an option property" do
      @target = shell
      add_contents(@target) {
        @video = video {
          file video_file
          looped true
          on_completed {
            expect(@video.video_property('loop')).to eq(true)
            @target.widget.close
          }
        }
      }
    end

    it "loops video when specified as an option setter method" do
      @target = shell
      add_contents(@target) {
        @video = video {
          file video_file
          on_completed {
            @video.looped = true
            expect(@video.video_property('loop')).to eq(true)
            @target.widget.close
          }
        }
      }
    end

    it 'returns current time as zero when autoplay is false' do
      @target = shell
      add_contents(@target) {
        @video = video(autoplay: false) {
          file video_file
          on_completed {
            expect(@video.video_property('autoplay')).to eq(false)
            expect(@video.current_time).to eq(0)
            @target.widget.close
          }
        }
      }
    end

    it 'reloads video' do
      @target = shell
      add_contents(@target) {
        @video = video(autoplay: false) {
          file video_file
          on_completed {
            @video.current_time = 1.5
            expect(@video.current_time).to eq(1.5)
            @video.reload
            expect(@video.current_time).to eq(0)
            @target.widget.close
          }
        }
      }
    end

    it 'plays video' do
      @target = shell
      add_contents(@target) {
        @video = video(autoplay: false) {
          file video_file
          on_completed {
            expect(@video.paused?).to eq(true)
            @video.play
            expect(@video.paused?).to eq(false)
            @target.widget.close
          }
        }
      }
    end

    it 'pauses video' do
      @target = shell
      add_contents(@target) {
        @video = video(autoplay: false) {
          file video_file
          on_completed {
            @video.play
            expect(@video.paused?).to eq(false)
            @video.pause
            expect(@video.paused?).to eq(true)
            @target.widget.close
          }
        }
      }
    end

    it 'returns duration of video' do
      @target = shell
      add_contents(@target) {
        @video = video(autoplay: false) {
          file video_file
        }
      }
      @video.on_initialized { #TODO revisit making on_loaded ensure loading of video and removing on_initialized if not needed
        @video.register_observer('loadeddata') do
          expect(@video.duration).to eq(2.269)
          @target.widget.close
        end
      }
    end

    it 'returns initialized status' do
      @target = shell
      add_contents(@target) {
        @video = video {
          file video_file
          on_completed {
            expect(@video.initialized?).to eq(true)
            @target.widget.close
          }
        }
      }
      expect(@video.initialized?).to eq(false)
    end

    it 'returns ended status with playback and restart' do
      @target = shell
      add_contents(@target) {
        @video = video {
          file video_file
          on_completed {
            expect(@video.ended?).to eq(false)
            @video.current_time = @video.duration
            expect(@video.ended?).to eq(true)
            @video.restart
            expect(@video.ended?).to eq(false)
            @target.widget.close
          }
        }
      }
    end

    it 'sets background to white by default' do
      @target = shell
      add_contents(@target) {
        @video = video {
          file video_file
          on_completed {
            expect(@video.widget.evaluate("return document.getElementById('style-body-background').innerHTML")).to include("rgba(255, 255, 255, 255)")
            @target.widget.close
          }
        }
      }
    end

    it 'sets background to black with option argument' do
      @target = shell
      add_contents(@target) {
        @video = video(background: :black) {
          file video_file
          on_completed {
            expect(@video.widget.evaluate("return document.getElementById('style-body-background').innerHTML")).to include("rgba(0, 0, 0, 255)")
            @target.widget.close
          }
        }
      }
    end

    it 'sets background to black with option property' do
      @target = shell
      add_contents(@target) {
        @video = video {
          file video_file
          background :black
          on_completed {
            expect(@video.widget.evaluate("return document.getElementById('style-body-background').innerHTML")).to include("rgba(0, 0, 0, 255)")
            @target.widget.close
          }
        }
      }
    end

    it 'sets background to black with option setter method' do
      @target = shell
      add_contents(@target) {
        @video = video {
          file video_file
          on_completed {
            @video.background = :black
            expect(@video.widget.evaluate("return document.getElementById('style-body-background').innerHTML")).to include("rgba(0, 0, 0, 255)")
            @target.widget.close
          }
        }
      }
    end

    xit 'fits video to width by default' do
    end

    xit 'does not fit video to width when specified by option argument' do
    end

    xit 'does not set current_time past duration'
    xit 'does not set current_time before 0'
    #TODO handle 100% values in width and height
    xit 'fit to height'
    xit 'paused'
    xit 'ended'
    xit 'playing?'
    xit 'started?'
    xit 'binding video listeners for paused, ended, current_time, etc....'
  end
end
