require "roger_sassc/version"

# The RogerSassc namespace
module RogerSassc
  DEFAULT_LOAD_PATHS = ["html/stylesheets", "bower_components"]

  class << self
    attr_accessor :load_paths

    # Add one or more paths to the array,
    # that will be given to libsass
    def append_path(*paths)
      @load_paths.push(*(paths.flatten))
    end
  end
end

# Add some sensible paths, convention over configuration
RogerSassc.load_paths = RogerSassc::DEFAULT_LOAD_PATHS.dup

# Legacy Sass load_paths copy
RogerSassc.append_path(Sass.load_paths) if defined?(Sass.load_paths)

require "roger_sassc/middleware"
require "roger_sassc/processor"
