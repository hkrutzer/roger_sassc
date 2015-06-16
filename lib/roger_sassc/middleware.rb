require "sassc"
require "roger/resolver"
require "rack"

module RogerSassc
  # Rack Middleware for Roger Sassc
  #
  # This middleware transforms a given url scss -> css. It does this
  # by checking if the .css can be resolved to .scss file, if so it
  # compiles (with the help of libsass) the scss.
  class Middleware
    attr_writer :resolver

    def initialize(app, options = {})
      @app = app

      defaults = {
        load_paths: RogerSassc.load_paths
      }

      @options = defaults.update(options)
    end

    def call(env)
      @project = env["roger.project"]

      url = ::Rack::Utils.unescape(env["PATH_INFO"].to_s).sub(%r{^/}, "")

      # Convert the url to an absolute path,
      # which is used to retrieve compile the scss
      if url.end_with?(".css") && scss_path = resolve_url(url)
        css = compile_scss(scss_path)
        respond(css)
      else
        @app.call(env)
      end
    end

    private

    def resolve_url(url)
      # A .css file is requested in the browser
      url = url[0..-4] + "scss"

      # Use the resolver to translate urls to file paths
      # returns nill when no file is found via url
      resolver.url_to_path url, exact_match: true
    end

    def compile_scss(scss_path)
      engine = SassC::Engine.new(File.read(scss_path), @options)
      engine.render
    end

    def resolver
      @resolver ||= Roger::Resolver.new(@project.html_path)
    end

    def respond(css)
      resp = ::Rack::Response.new do |res|
        res.status = 200
        res.headers["Content-Type"] = "text/css"
        # last modified header
        res.write css
      end
      resp.finish
    end
  end
end
