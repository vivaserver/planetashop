require File.dirname(__FILE__) + '/../test_helper'

class StoryTest < Test::Unit::TestCase
  fixtures :stories

  # Replace this with your real tests.
  def test_truth
    assert_kind_of Story, stories(:first)
  end
end
