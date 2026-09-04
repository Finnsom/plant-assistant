require "test_helper"

class PlantIdentifierTest < ActiveSupport::TestCase
  test "normalizes a short model answer" do
    assert_equal "Monstera deliciosa - Swiss cheese plant",
                 PlantIdentifier.normalize("**Monstera deliciosa - Swiss cheese plant**\nExtra text")
  end

  test "rejects an answer that cannot identify a plant" do
    error = assert_raises(ArgumentError) { PlantIdentifier.normalize("Unable to identify.") }

    assert_equal "The plant could not be identified", error.message
  end
end
