require "roger_sassc"

module RogerSassc
  # Main module tests
  # Maintaining the load paths
  class TestRogerSassc < ::Test::Unit::TestCase
    def setup
      RogerSassc.load_paths = RogerSassc::DEFAULT_LOAD_PATHS.dup
    end

    def teardown
      # Reset back to default
      RogerSassc.load_paths = RogerSassc::DEFAULT_LOAD_PATHS.dup
    end

    def test_append_load_path
      RogerSassc.append_path("a/b")
      assert_equal ["bower_components", "a/b"],
                   RogerSassc.load_paths
    end

    def test_append_load_path_with_multiple_params
      RogerSassc.append_path("a/b", "b/c")
      assert_equal ["bower_components", "a/b", "b/c"],
                   RogerSassc.load_paths
    end

    def test_append_load_path_with_array
      RogerSassc.append_path(["a/b", "b/c"])
      assert_equal ["bower_components", "a/b", "b/c"],
                   RogerSassc.load_paths
    end

    def test_appends_path_alias
      RogerSassc.append_path("a/b", "b/c")
      assert_equal ["bower_components", "a/b", "b/c"],
                   RogerSassc.load_paths
    end

    def test_default_load_path
      assert_equal ["bower_components"],
                   RogerSassc.load_paths
    end
  end
end
