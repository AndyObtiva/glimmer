require "spec_helper"

module GlimmerSpec
  describe "Glimmer Video" do
    include Glimmer

    before do
      @original_temp = ENV['temp']
      @target = shell {
        alpha 0 # keep invisible while running specs
      }
      @timeout = Thread.new {
        timeout_duration = 6
        sleep(timeout_duration)
        async_exec {
          @target&.dispose
          fail("Time out after #{timeout_duration} seconds!")
        }
      }
    end

    after do
      if @target && !@target.swt_widget.isDisposed
        @target.open
      end
      @timeout.kill
      ENV['temp'] = @original_temp
    end

    let(:video_file) { File.expand_path('../../fixtures/videos/Pepa-creativeCommonsMp4956_512kb.mp4', __FILE__) }
    let(:video_url) { "http://www.youtube.com/fdajiew" }
    let(:video_url_truncated) { "www.youtube.com/fdajiew" }

    it "sets video source by file option argument" do
      @target.content {
        @video = video(file: video_file) {
          on_completed {
            expect(@video.swt_widget.evaluate("return document.getElementById('source').src")).to eq("file://#{video_file}")
            @target.dispose
          }
        }
      }
      expect(@video.source).to eq("file://#{video_file}")
    end

    it "sets video source by url option argument" do
      @target.content {
        @video = video(url: video_url) {
          on_completed {
            expect(@video.swt_widget.evaluate("return document.getElementById('source').src")).to eq(video_url)
            @target.dispose
          }
        }
      }
      expect(@video.source).to eq(video_url)
    end

    it 'sets video source by uri:classloader file (JAR file path)' do
      expected_source = "file:///tmp/glimmer/lib/glimmer/ui/video/#{File.basename(video_file)}"
      @target.content {
        @video = video(file: "uri:classloader://#{video_file}") {
          on_completed {
            expect(@video.swt_widget.evaluate("return document.getElementById('source').src")).to eq(expected_source)
            expect(Dir['/tmp/glimmer/lib/glimmer/ui/video/*'].to_a.size).to be > 0
            @target.dispose
          }
        }
      }
      expect(@video.source).to eq(expected_source)
    end

    it 'sets video source by uri:classloader file (JAR file path) with ENV["temp"] set for windows' do
      ENV['temp'] = '/tmp/tmp'
      expected_source = "file:///tmp/tmp/glimmer/lib/glimmer/ui/video/#{File.basename(video_file)}"
      @target.content {
        @video = video(file: "uri:classloader://#{video_file}") {
          on_completed {
            expect(@video.swt_widget.evaluate("return document.getElementById('source').src")).to eq(expected_source)
            expect(Dir['/tmp/tmp/glimmer/lib/glimmer/ui/video/*'].to_a.size).to be > 0
            @target.dispose
          }
        }
      }
      expect(@video.source).to eq(expected_source)
    end

    it "autoplays video by default" do
      @target.content {
        @video = video(file: video_file) {
          on_completed {
            expect(@video.swt_widget.evaluate("return document.getElementById('video').autoplay")).to eq(true)
            @target.dispose
          }
        }
      }
      expect(@video.autoplay).to eq(true)
    end

    it "does not autoplay video when specified with autoplay option argument" do
      @target.content {
        @video = video(file: video_file, autoplay: false) {
          on_completed {
            expect(@video.swt_widget.evaluate("return document.getElementById('video').autoplay")).to eq(false)
            @target.dispose
          }
        }
      }
    end

    it "displays video controls by default" do
      @target.content {
        @video = video(file: video_file) {
          on_completed {
            expect(@video.swt_widget.evaluate("return document.getElementById('video').controls")).to eq(true)
            @target.dispose
          }
        }
      }
      expect(@video.controls).to eq(true)
    end

    it "does not display video controls when specified as an option argument" do
      @target.content {
        @video = video(file: video_file, controls: false) {
          on_completed {
            expect(@video.swt_widget.evaluate("return document.getElementById('video').controls")).to eq(false)
            @target.dispose
          }
        }
      }
    end

    it "does not loop video by default" do
      @target.content {
        @video = video(file: video_file) {
          on_completed {
            expect(@video.swt_widget.evaluate("return document.getElementById('video').loop")).to eq(false)
            @target.dispose
          }
        }
      }
      expect(@video.looped).to eq(false)
    end

    it "loops video when specified as an option argument" do
      @target.content {
        @video = video(file: video_file, looped: true) {
          on_completed {
            expect(@video.swt_widget.evaluate("return document.getElementById('video').loop")).to eq(true)
            @target.dispose
          }
        }
      }
    end

    it 'sets background to white by default' do
      @target.content {
        @video = video(file: video_file) {
          on_completed {
            expect(@video.swt_widget.evaluate("return document.getElementById('style-body-background').innerHTML")).to include("rgba(255, 255, 255, 255)")
            @target.dispose
          }
        }
      }
      expect(@video.background).to eq(:white)
    end

    it 'sets background to black with option argument' do
      @target.content {
        @video = video(file: video_file, background: :black) {
          on_completed {
            expect(@video.swt_widget.evaluate("return document.getElementById('style-body-background').innerHTML")).to include("rgba(0, 0, 0, 255)")
            @target.dispose
          }
        }
      }
    end

    it 'fits video to width by default' do
      @target.content {
        @video = video(file: video_file) {
          on_completed {
            expect(@video.swt_widget.evaluate("return document.getElementById('video').width")).to eq(100.0)
            @target.dispose
          }
        }
      }
      expect(@video.fit_to_width).to eq(true)
    end

    it 'does not fit video to width when specified with fit_to_width option argument' do
      @target.content {
        @video = video(file: video_file, fit_to_width: false) {
          on_completed {
            expect(@video.swt_widget.evaluate("return document.getElementById('video').width")).to eq(0.0)
            @target.dispose
          }
        }
      }
    end

    it 'fits video to height by default' do
      @target.content {
        @video = video(file: video_file) {
          on_completed {
            expect(@video.swt_widget.evaluate("return document.getElementById('video').height")).to eq(100.0)
            @target.dispose
          }
        }
      }
      expect(@video.fit_to_height).to eq(true)
    end

    it 'does not fit video to height when specified with fit_to_height option argument' do
      @target.content {
        @video = video(file: video_file, fit_to_height: false) {
          on_completed {
            expect(@video.swt_widget.evaluate("return document.getElementById('video').height")).to eq(0.0)
            @target.dispose
          }
        }
      }
    end

    it "plays/stops video manually" do
      @target.content {
        @video = video(file: video_file, autoplay: false) {
          on_completed {
            expect(@video.playing?).to eq(false)
            expect(@video.paused?).to eq(true)
            @video.play
            expect(@video.swt_widget.evaluate("return document.getElementById('video').paused")).to eq(false)
            expect(@video.playing?).to eq(true)
            expect(@video.paused?).to eq(false)
            @video.pause
            expect(@video.playing?).to eq(false)
            expect(@video.paused?).to eq(true)
            expect(@video.swt_widget.evaluate("return document.getElementById('video').paused")).to eq(true)
            @target.dispose
          }
        }
      }
    end

    it 'sets offset_x to 0 by default' do
      @target.content {
        @video = video(file: video_file) {
          on_completed {
            expect(@video.swt_widget.evaluate("return document.getElementById('style-body-offset-x').innerHTML")).to include("margin-left: 0px;")
            @target.dispose
          }
        }
      }
      expect(@video.offset_x).to eq(0)
    end

    it 'sets offset_x to value specified by offset_x option argument' do
      @target.content {
        @video = video(file: video_file, offset_x: -150) {
          on_completed {
            expect(@video.swt_widget.evaluate("return document.getElementById('style-body-offset-x').innerHTML")).to include("margin-left: -150px;")
            @target.dispose
          }
        }
      }
    end

    it 'sets offset_y to 0 by default' do
      @target.content {
        @video = video(file: video_file) {
          on_completed {
            expect(@video.swt_widget.evaluate("return document.getElementById('style-body-offset-y').innerHTML")).to include("margin-top: 0px;")
            @target.dispose
          }
        }
      }
      expect(@video.offset_y).to eq(0)
    end

    it 'sets offset_y to value specified by offset_y option argument' do
      @target.content {
        @video = video(file: video_file, offset_y: -150) {
          on_completed {
            expect(@video.swt_widget.evaluate("return document.getElementById('style-body-offset-y').innerHTML")).to include("margin-top: -150px;")
            @target.dispose
          }
        }
      }
    end

    it 'listens to video loaded event' do
      @target.content {
        @video = video(file: video_file) {
          on_loaded {
            expect(@video.loaded?).to eq(true)
            @target.dispose
          }
        }
      }
      expect(@video.loaded?).to eq(false)
    end

    it 'listens to video ended event and ensures position == duration at the end, then reloads' do
      @target.content {
        @video = video(file: video_file) {
          on_ended {
            expect(@video.ended?).to eq(true)
            expect(@video.position).to eq(@video.duration)
            @video.on_loaded {
              @target.dispose
            }
            @video.reload
          }
        }
      }
    end

    it 'listens to video play event' do
      @target.content {
        @video = video(file: video_file, autoplay: false) {
          on_playing {
            expect(@video.playing?).to eq(true)
            @target.dispose
          }
          on_completed {
            @video.play
          }
        }
      }
    end

    it 'listens to video pause event' do
      @target.content {
        @video = video(file: video_file) {
          on_paused {
            expect(@video.paused?).to eq(true)
            @target.dispose
          }
          on_completed {
            @video.pause
          }
        }
      }
    end

    it 'changes position' do
      @target.content {
        @video = video(file: video_file) {
          on_completed {
            @video.position = @video.duration
            expect(@video.ended?).to be(true)
            @target.dispose
          }
        }
      }
    end
  end
end
