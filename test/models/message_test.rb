require 'test_helper'

class MessageTest < ActiveSupport::TestCase

  # The Message and RecipientUser models are being tested together because RecipientUser
  # is nested within Message and is modified by the messages controller
  test "should create message and recipient user" do
    message = Message.new
    message.subject = "Subject"
    message.body = "This is the body of a message"
    message.deleted = false
    message.read = true
    message.took_ownership_at = Time.now
    message.message_type_id = message_types(:customer_inquiry).id
    message.from_user_id = users(:user).id
    message.owner_user_id = users(:admin).id
    assert message.save
    recipient_user = message.recipient_users.new
    recipient_user.user_id = users(:admin).id
    assert recipient_user.save
    assert !recipient_user.id.nil? # Presence of id means recipient record saved
  end

  test "should find message and recipient user" do
    message_hash = create_message()
    message = message_hash[:in]
    message_id = message.id
    recipient_user_id = message.recipient_users.first.id
    assert_nothing_raised { Message.find(message_id) }
    assert_nothing_raised { message.recipient_users.find(recipient_user_id) }
  end

  test "should update message" do
    message_hash = create_message()
    message = message_hash[:in]
    message.subject = "New subject"
    message_id = message.id
    assert message.save
    updated_message = Message.find(message_id)
    assert_equal "New subject", updated_message.subject
  end

  test "should not create message without recipient if required" do
    message = Message.new
    message.subject = "Subject"
    message.body = "This is the body of a message"
    message.deleted = false
    message.read = true
    message.took_ownership_at = Time.now
    message.message_type_id = message_types(:customer_inquiry).id
    message.from_user_id = users(:user).id
    message.owner_user_id = users(:admin).id
    message.require_recipient = true
    assert !message.valid?
    assert message.errors[:recipient_user_id].any?
    assert_equal ["can't be blank*"], message.errors[:recipient_user_id]
    assert !message.save
  end

  test "should not create message without type if required" do
    message = Message.new
    message.subject = "Subject"
    message.body = "This is the body of a message"
    message.deleted = false
    message.read = true
    message.took_ownership_at = Time.now
    message.from_user_id = users(:user).id
    message.owner_user_id = users(:admin).id
    message.require_type = true
    assert !message.valid?
    assert message.errors[:message_type_id].any?
    assert_equal ["can't be blank*"], message.errors[:message_type_id]
    assert !message.save
  end

  test "should not create message without subject if required" do
    message = Message.new
    message.body = "This is the body of a message"
    message.deleted = false
    message.read = true
    message.took_ownership_at = Time.now
    message.message_type_id = message_types(:customer_inquiry).id
    message.from_user_id = users(:user).id
    message.owner_user_id = users(:admin).id
    message.require_subject = true
    assert !message.valid?
    assert message.errors[:subject].any?
    assert_equal ["can't be blank*"], message.errors[:subject]
    assert !message.save
  end

  test "should not create recipient user without user_id" do
    message = Message.new
    message.subject = "Subject"
    message.body = "This is the body of a message"
    message.deleted = false
    message.read = true
    message.took_ownership_at = Time.now
    message.message_type_id = message_types(:customer_inquiry).id
    message.from_user_id = users(:user).id
    message.owner_user_id = users(:admin).id
    recipient_user = message.recipient_users.new
    assert !recipient_user.valid?
    assert recipient_user.errors[:user_id].any?
    assert_equal ["can't be blank*"], recipient_user.errors[:user_id]
    assert !recipient_user.save
  end

  test "should only return non-deleted messages with not_deleted scope" do
    message_hash = create_message()  # remember this actually creates two records
    message = message_hash[:in]
    message.update_attributes(deleted: true)
    scope_message_count = Message.not_deleted.count
    expected_message_count = Message.where("(deleted IS NULL) OR (deleted <> ?)", true).count
    assert_equal expected_message_count, scope_message_count
  end

end
