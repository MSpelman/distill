require 'test_helper'

class CancelReasonTest < ActiveSupport::TestCase

  test "should find cancel reason" do
    cancel_reason_id = cancel_reasons(:customer).id
    assert_nothing_raised { CancelReason.find(cancel_reason_id) }
  end

end
