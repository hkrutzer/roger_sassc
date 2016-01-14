require "roger_sassc/version"

# The RogerSassc namespace
module RogerSassc
  # Loading default bower_components here,
  # just as a little reward for using the default
  # but you can overwrite or append any path you like
  DEFAULT_LOAD_PATHS = ["bower_components"]

  class << self
    attr_accessor :load_paths

    # Add one or more paths to the array,
    # that will be given to libsass
    # in general load paths are only required
    # once a file is hard or impossible to reach by a relative path
    def append_path(*paths)
      @load_paths.push(*(paths.flatten))
    end

    alias_method :append_paths, :append_path
  end
end

# Add some sensible paths, convention over configuration
RogerSassc.load_paths = RogerSassc::DEFAULT_LOAD_PATHS.dup

# Legacy Sass load_paths copy, this is mainly used in gems that
# supply assets such as bourbon and neat
RogerSassc.append_path(Sass.load_paths) if defined?(Sass.load_paths)

# Load our custom SASSC functions
require "roger_sassc/sassc/asset_functions"

# The middleware and processor
require "roger_sassc/middleware"
require "roger_sassc/processor"
