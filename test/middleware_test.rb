require "test_helper"
require "./lib/roger_sassc/middleware"

module RogerSassc
  # Testing the middleware functionality
  # which transforms on a request based .scss to .css
  class TestMiddleware < ::Test::Unit::TestCase
    include FixtureHelper

    def setup
      @app =  proc { [200, {}, ["YAM"]] } # Yet another middleware
      @middleware = Middleware.new @app

      @request = Rack::MockRequest.new(@middleware)
    end

    def test_middleware_can_be_called
      assert(@middleware.respond_to?(:call))
    end

    def test_calls_rest_of_stack_when_not_css
      assert_equal @request.get("/my.js").body, "YAM"
    end

    def test_doesn_t_compile_scss_when_no_scss_file
      @middleware.resolver = mock_resolver("not-excisting.scss", nil)
      assert_equal @request.get("/not-excisting.css").body, "YAM"
    end

    def test_respons_with_css
      path = fixture_path "general.scss"
      expected_css = fixture "output.css"
      @middleware.resolver = mock_resolver("test/fixtures/general.scss", path)
      assert_equal @request.get("/test/fixtures/general.css").body, expected_css
    end

    def test_source_maps
      pend "To implement"
    end

    def test_write_to_fs
      pend "To implement"
    end

    private

    def mock_resolver(input_url, file_path)
      resolver = mock
      resolver.expects(:url_to_path).with(equals(input_url), anything).returns(file_path)
      resolver
    end
  end
end
