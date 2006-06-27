require File.dirname(__FILE__) + '/../test_helper'

class CountryTest < Test::Unit::TestCase
  fixtures :countries

  # Replace this with your real tests.
  def test_truth
    assert_kind_of Country, countries(:first)
  end
end
