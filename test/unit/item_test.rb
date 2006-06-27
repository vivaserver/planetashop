require File.dirname(__FILE__) + '/../test_helper'

class ItemTest < Test::Unit::TestCase
  fixtures :items

  # Replace this with your real tests.
  def test_truth
    assert_kind_of Item, items(:first)
  end
end
