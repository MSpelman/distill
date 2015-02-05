require 'test_helper'

class CommentTest < ActiveSupport::TestCase

  test "should create comment" do
    comment = Comment.new
    comment.summary = "Comment Summary"
    comment.detail = "This is the details of the comment."
    comment.rating = 5
    comment.active = true
    comment.product_id = products(:whiskey).id
    comment.user_id = users(:user).id
    assert comment.save
  end

  test "should find comment" do
    comment = Comment.new
    comment.summary = "Comment Summary"
    comment.rating = 5
    comment.product_id = products(:whiskey).id
    comment.user_id = users(:user).id
    assert comment.save
    comment_id = comment.id
    assert_nothing_raised { Comment.find(comment_id) }
  end

  test "should update comment" do
    # Create new comment
    comment = Comment.new
    comment.summary = "Comment Summary"
    comment.rating = 5
    comment.product_id = products(:whiskey).id
    comment.user_id = users(:user).id
    assert comment.save
    comment_id = comment.id
    # Update comment
    comment.rating = 3
    assert comment.save
    updated_comment = Comment.find(comment_id)
    assert_equal 3, updated_comment.rating
  end

  test "should not create comment with no summary" do
    comment = Comment.new
    comment.rating = 5
    comment.product_id = products(:whiskey).id
    comment.user_id = users(:user).id
    assert !comment.valid?
    assert comment.errors[:summary].any?
    assert_equal ["can't be blank*"], comment.errors[:summary]
    assert !comment.save
  end

  test "should not create comment with no rating" do
    comment = Comment.new
    comment.summary = "Comment Summary"
    comment.product_id = products(:whiskey).id
    comment.user_id = users(:user).id
    assert !comment.valid?
    assert comment.errors[:rating].any?
    assert_equal ["can't be blank*"], comment.errors[:rating]
    assert !comment.save
  end

  test "should only return active comments with active_only scope" do
    # Create active comment
    comment = Comment.new
    comment.summary = "Comment Summary"
    comment.rating = 5
    comment.product_id = products(:whiskey).id
    comment.user_id = users(:user).id
    comment.active = true
    assert comment.save
    # Create inactive comment
    comment = Comment.new
    comment.summary = "Comment Summary"
    comment.rating = 5
    comment.product_id = products(:whiskey).id
    comment.user_id = users(:user).id
    assert comment.save
    # Test active_only scope
    scope_comments = Comment.active_only
    found_comments = Comment.where(active: true).load
    assert_equal scope_comments.count, found_comments.count
    assert_equal 1, scope_comments.count
  end

end
