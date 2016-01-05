require "sassc"
require "roger/release"

require "fileutils"
require "pathname"

module RogerSassc
  # The Roger Processor for LibSass
  class Processor < ::Roger::Release::Processors::Base
    def initialize(options = {})
      @options = {
        match: ["stylesheets/**/*.scss"],
        skip: [%r{/_.*\.scss\Z}],
        load_paths: RogerSassc.load_paths
      }.update(options)
    end

    # @option options [Hash]
    #   :build_files
    def call(release, options = {})
      @options = @options.update(options)
      @options[:roger_html_path] = release.build_path

      match = @options.delete(:match)
      skip = @options.delete(:skip)

      # Sassify SCSS files
      files = release.get_files(match)

      files.each do |f|
        # Doing skip by hand, so that we can clean the skipped ones
        next if skip.detect { |r| r.match(f) }

        release.log(self, "Processing: #{f}")
        # Compile SCSS
        compile_file(f)
      end

      # Remove source file
      clean_files(files)
    end

    private

    def clean_files(files)
      files.each { |f| File.unlink(f) }
    end

    def compile_file(path)
      @options[:filename] = path.to_s
      scss = File.read(path)

      File.open(path.gsub(/\.scss$/, ".css"), "w+") do |file|
        file.write(SassC::Engine.new(scss, @options).render)
      end
    end
  end
end

Roger::Release::Processors.register(:sassc, RogerSassc::Processor)
