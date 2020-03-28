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

    it "sets video source by file option argument" do
      @target = shell
      add_contents(@target) {
        @video = video(file: video_file) {
          on_completed {
            expect(@video.widget.evaluate("return document.getElementById('source').src")).to eq("file://#{video_file}")
            @target.widget.close
          }
        }
      }
    end

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

    it "sets video source by url option argument" do
      @target = shell
      add_contents(@target) {
        @video = video(url: video_url) {
          on_completed {
            expect(@video.widget.evaluate("return document.getElementById('source').src")).to eq(video_url)
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
        @video = video(file: video_file) {
          on_completed {
            expect(@video.video_property('autoplay')).to eq(true)
            @target.widget.close
          }
        }
      }
    end

    it "does not display video controls by default" do
      @target = shell
      add_contents(@target) {
        @video = video(file: video_file) {
          on_completed {
            expect(@video.video_property('controls')).to eq(false)
            @target.widget.close
          }
        }
      }
    end

    it "displays video controls when specified as an option argument" do
      @target = shell
      add_contents(@target) {
        @video = video(file: video_file, controls: true) {
          on_completed {
            expect(@video.video_property('controls')).to eq(true)
            @target.widget.close
          }
        }
      }
    end

    it "does not loop video by default" do
      @target = shell
      add_contents(@target) {
        @video = video(file: video_file) {
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
        @video = video(file: video_file, looped: true) {
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
        @video = video(file: video_file) {
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
        @video = video(file: video_file) {
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
        @video = video(file: video_file, autoplay: false) {
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
        @video = video(file: video_file, autoplay: false) {
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
        @video = video(file: video_file, autoplay: false) {
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
        @video = video(file: video_file, autoplay: false) {
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
        @video = video(file: video_file, autoplay: false) {
          on_completed {
            expect(@video.duration).to eq(2.269)
            @target.widget.close
          }
        }
      }
    end

    it 'returns loaded status' do
      @target = shell
      add_contents(@target) {
        @video = video(file: video_file) {
          on_completed {
            expect(@video.loaded?).to eq(true)
            @target.widget.close
          }
        }
      }
      expect(@video.loaded?).to eq(false)
    end

    it 'returns ended status with playback and rewind' do
      @target = shell
      add_contents(@target) {
        @video = video(file: video_file) {
          on_completed {
            expect(@video.ended?).to eq(false)
            @video.current_time = @video.duration
            expect(@video.ended?).to eq(true)
            @video.rewind
            expect(@video.ended?).to eq(false)
            @target.widget.close
          }
        }
      }
    end
  end
end
