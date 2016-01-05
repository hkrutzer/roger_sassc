require "sassc"
require "digest"

module RogerSassc
  module SassC
    # Defintion of asset functions
    module AssetFunctions
      # The asset_path method will search for
      # the file and if it exists will append a fingerprint
      # hexdigest to the output url (?v=DIGEST)
      def asset_path(path)
        file = find_file(path)

        if File.exist?(file)
          digest = Digest::SHA256.file(file).hexdigest
          finger_printed_path = "#{path}?v=#{digest}"
        else
          finger_printed_path = path.value
        end

        ::SassC::Script::String.new("url(#{finger_printed_path})", :identifier)
      end

      private

      # Translate the given path to a path on disk
      def find_file(path)
        # Absolute url, starting with /
        if path.value.match(%r{^\/[^\/]})
          File.join(@options[:roger_html_path], path.value)
        else
          # Relative url - we can join from .scss position
          File.join(File.dirname(@options[:filename]), path.value)
        end
      end
    end
  end
end

# SassC includes ruby functions for us
module ::SassC::Script::Functions
  include ::RogerSassc::SassC::AssetFunctions
end
