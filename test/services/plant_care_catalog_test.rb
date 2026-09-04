require "test_helper"

class PlantCareCatalogTest < ActiveSupport::TestCase
  test "contains fifteen common houseplants" do
    assert_equal 15, PlantCareCatalog.profiles.size
    assert_equal 15, PlantCareCatalog.options.size
  end

  test "formats choices with botanical and common names" do
    assert_includes PlantCareCatalog.options,
                    ["Monstera deliciosa - Swiss cheese plant", "Monstera deliciosa"]
  end

  test "finds care instructions using a common name" do
    profile = PlantCareCatalog.find("Boston fern")

    assert_equal "Nephrolepis exaltata", profile.fetch("latin_name")
    assert_match(/moist/, profile.fetch("water"))
  end
end
