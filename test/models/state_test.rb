require 'test_helper'

class StateTest < ActiveSupport::TestCase

  test "should find state" do
    state_id = states(:wi).id
    assert_nothing_raised { State.find(state_id) }
  end

  test "should only return active states with active_only scope" do
    scope_states = State.active_only
    found_states = State.where(active: true).load
    assert_equal  found_states.count, scope_states.count
    assert_equal 5, scope_states.count  # 5 active and 1 inactive states in fixture
  end

end
