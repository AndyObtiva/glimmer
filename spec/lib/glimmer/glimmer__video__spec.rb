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

    it "autoplays video by default" do
      @target = shell
      add_contents(@target) {
        @video = video(file: video_file) {
          on_completed {
            expect(@video.widget.evaluate("return document.getElementById('video').autoplay")).to eq(true)
            @target.widget.close
          }
        }
      }
    end

    it "displays video controls by default" do
      @target = shell
      add_contents(@target) {
        @video = video(file: video_file) {
          on_completed {
            expect(@video.widget.evaluate("return document.getElementById('video').controls")).to eq(true)
            @target.widget.close
          }
        }
      }
    end

    it "does not display video controls when specified as an option argument" do
      @target = shell
      add_contents(@target) {
        @video = video(file: video_file, controls: false) {
          on_completed {
            expect(@video.widget.evaluate("return document.getElementById('video').controls")).to eq(false)
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
            expect(@video.widget.evaluate("return document.getElementById('video').loop")).to eq(false)
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
            expect(@video.widget.evaluate("return document.getElementById('video').loop")).to eq(true)
            @target.widget.close
          }
        }
      }
    end

    it 'sets background to white by default' do
      @target = shell
      add_contents(@target) {
        @video = video(file: video_file) {
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
        @video = video(file: video_file, background: :black) {
          on_completed {
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

    xit 'fit to height'
  end
end
