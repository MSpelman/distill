require 'test_helper'

class MessageTypeTest < ActiveSupport::TestCase

  test "should create message type" do
    message_type = MessageType.new
    message_type.name = "New Message Type"
    message_type.description = "New Message Type description"
    message_type.active = true
    assert message_type.save
  end

  test "should find message type" do
    message_type_id = message_types(:customer_inquiry).id
    assert_nothing_raised { MessageType.find(message_type_id) }
  end

  test "should update message type" do
    message_type = message_types(:customer_inquiry)
    assert message_type.update_attributes(description: "Changed Message Type description")
  end

  test "should not create message type with no name" do
    message_type = MessageType.new
    message_type.description = "New Message Type description"
    message_type.active = true
    assert !message_type.valid?
    assert message_type.errors[:name].any?
    assert_equal ["can't be blank*"], message_type.errors[:name]
    assert !message_type.save
  end

  test "should only return active message types with active_only scope" do
    scope_count = MessageType.active_only.count  # Fixture has one active and one inactive
    expected_count = MessageType.where(active: true).load.count
    assert_equal expected_count, scope_count
  end

end
