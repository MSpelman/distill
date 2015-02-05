require 'test_helper'

class CommentsHelperTest < ActionView::TestCase

  test "approve_allowed? should return true" do
    # Create inactive comment
    comment = Comment.new
    comment.summary = "Comment Summary"
    comment.rating = 5
    comment.product_id = products(:whiskey).id
    comment.user_id = users(:user).id
    assert comment.save
    # Login as admin
    login_as(:admin)
    # Call helper method
    assert approve_allowed?(comment)
  end

  test "approve_allowed? should return false" do
    # Create active comment
    comment = Comment.new
    comment.summary = "Comment Summary"
    comment.rating = 5
    comment.product_id = products(:whiskey).id
    comment.user_id = users(:user).id
    comment.active = true
    assert comment.save
    # Login as admin
    login_as(:admin)
    # Call helper method for active comment
    assert !(approve_allowed?(comment))
    # Change comment to inactive
    comment.update_attributes(active: false)
    # Login as regular user
    login_as(:user)
    # Call helper method for non-admin user
    assert !(approve_allowed?(comment))
  end

end
