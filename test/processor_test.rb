require "test_helper"
require "fileutils"
require "roger/testing/mock_release"
require "./lib/roger_sassc/processor"

module RogerSassc
  # Test the processor
  class TestProcessor < ::Test::Unit::TestCase
    include FixtureHelper

    def setup
      @release = Roger::Testing::MockRelease.new
      @release.project.construct.directory "build" do |dir|
        @test_output = dir.directory "test/fixtures/"
        FileUtils.cp_r fixture_path("."), @test_output
      end

      @processor = Processor.new
    end

    def teardown
      @release.destroy
    end

    def test_processor_can_be_called
      assert_respond_to(@processor, :call)
    end

    def test_call_processor
      files = [
        (@test_output + "general.scss").to_s,
        (@test_output + "src/_variables.scss").to_s
      ]

      stub_get_files(files)

      expected_css = fixture "output.css"
      @processor.call @release

      # File is created
      assert_path_exist @test_output + "general.css"

      # And matches earlier output
      assert_equal File.read(@test_output + "general.css"), expected_css

      # Check clean up
      assert_path_not_exist files[0]
      assert_path_not_exist files[1]
    end

    def test_processor_raises_on_compilation_errors
      files = [
        (@test_output + "raise.scss").to_s
      ]

      stub_get_files(files)

      assert_raise ::SassC::SyntaxError do
        @processor.call @release
      end
    end

    private

    # Stub is used so we can controll what files
    # are ran through the processor.
    def stub_get_files(files)
      @release.stubs(:get_files).returns(files)
    end
  end
end
