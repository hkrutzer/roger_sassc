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
    attr_accessor :project

    def initialize(app, options = {})
      @app = app

      defaults = {
        load_paths: RogerSassc.load_paths
      }

      @options = defaults.update(options)
    end

    def call(env)
      @project ||= env["roger.project"]
      @options[:roger_html_path] = @project.html_path

      url = ::Rack::Utils.unescape(env["PATH_INFO"].to_s).sub(%r{^/}, "")

      # Convert the url to an absolute path,
      # which is used to retrieve compile the scss
      if url.end_with?(".css") && scss_path = resolve_url(url)
        env["rack.errors"].puts "Invoking ruby-sassc for #{scss_path}"

        begin
          css = compile_scss(scss_path)
          respond(css)
        rescue SassC::SyntaxError, SassC::NotRenderedError, SassC::InvalidStyleError => sassc_error
          respond(debug_css(sassc_error))
        end
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
      # Supply the filename for load path resolving
      @options[:filename] = scss_path.to_s

      SassC::Engine.new(File.read(scss_path), @options).render
    end

    def debug_css(sassc_error)
      # Replace
      # * regular line-ends with css compat strings
      #     via: http://stackoverflow.com/questions/9062988/newline-character-sequence-in-css-content-property
      # * single quotes with double quotes for escaping
      sassc_error_css_string = sassc_error.to_s.gsub("\n", "\\A").gsub("'", "\"")

      # Build debug string
      debug = "/*\n"
      debug << "#{sassc_error}\n\n"
      debug << "Load paths:\n"
      debug << "#{@options[:load_paths]}\n\n"
      debug << "*/\n"
      debug << "body:before {\n"
      debug << "  white-space: pre;\n"
      debug << "  font-family: monospace;\n"
      debug << "  content: '#{sassc_error_css_string}'; }\n"
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
