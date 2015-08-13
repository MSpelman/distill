require 'test_helper'

class UserTest < ActiveSupport::TestCase

  test "should create user" do
    user = User.new
    user.email = "create@example.com"
    user.password = "c0ntr0!!3r"
    user.name = "Create User"
    user.address_1 = "1234 Douglas St"
    user.address_2 = "line 2"
    user.apt_number = "409"
    user.city = "Madison"
    user.state_id = states(:wi).id
    user.zip_code = "53715-1234"
    user.newsletter = true
    user.active = true
    user.admin = false
    assert user.save
  end

  test "should find user" do
    user_id = users(:admin).id
    assert_nothing_raised { User.find(user_id) }
  end

  test "should update user" do
    user = users(:user)
    assert user.update_attributes(:newsletter => false)
  end

  test "should not create user with duplicate email" do
    user = User.new
    user.email = "admin@example.com"
    user.password = "c0ntr0!!3r"
    user.name = "Duplicate User"
    assert !user.valid?
    assert user.errors[:email].any?
    assert_equal ["has already been taken*"], user.errors[:email]
    assert !user.save
  end

  test "should not create user with too_short email" do
    user = User.new
    user.email = "a@.z"
    user.password = "c0ntr0!!3r"
    user.name = "Short Email"
    assert !user.valid?
    assert user.errors[:email].any?
    assert_equal ["is too short (minimum is 5 characters)*", "is invalid*"], user.errors[:email]
    assert !user.save
  end

  test "should not create user with no email" do
    user = User.new
    user.password = "c0ntr0!!3r"
    user.name = "No Email"
    assert !user.valid?
    assert user.errors[:email].any?
    assert_equal ["is too short (minimum is 5 characters)*", "is invalid*"], user.errors[:email]
    assert !user.save
  end

  test "should not create user with incorrectly formatted email" do
    user = User.new
    user.email = "a@@@@!!!r.zsdty"
    user.password = "c0ntr0!!3r"
    user.name = "Bad Email"
    assert !user.valid?
    assert user.errors[:email].any?
    assert_equal ["is invalid*"], user.errors[:email]
    assert !user.save
  end

  test "should not create user with too_short password" do
    user = User.new
    user.email = "short_password@example.com"
    user.password = "q"
    user.name = "Short Password"
    assert !user.valid?
    assert user.errors[:password].any?
    assert_equal ["is too short (minimum is 6 characters)*"], user.errors[:password]
    assert !user.save
  end

  test "should not create user with no password" do
    user = User.new
    user.email = "no_password@example.com"
    user.name = "No Password"
    assert !user.valid?
    assert user.errors[:password].any?
    assert_equal ["is too short (minimum is 6 characters)*"], user.errors[:password]
    assert !user.save
  end

  test "should not create user with incorrectly formatted password" do
    user = User.new
    user.email = "bad_password@example.com"
    user.name = "Bad Password"
    # Does not have at least one letter
    user.password = "101230!!31"
    assert !user.valid?
    assert user.errors.any?
    assert_equal :"Password Format Error*", user.errors.first[0]
    assert !user.save
    # Does not have at least one number
    user.password = "contro!!er"
    assert !user.valid?
    assert user.errors.any?
    assert_equal :"Password Format Error*", user.errors.first[0]
    assert !user.save
    # Does not have at least one punctuation mark
    user.password = "c0ntr0ll3r"
    assert !user.valid?
    assert user.errors.any?
    assert_equal :"Password Format Error*", user.errors.first[0]
    assert !user.save
    # No whitespace allowed
    user.password = "c0nt 0!!3r"
    assert !user.valid?
    assert user.errors.any?
    assert_equal :"Password Format Error*", user.errors.first[0]
    assert !user.save
  end

  test "should not create user with no name" do
    user = User.new
    user.email = "no_name@example.com"
    user.password = "c0ntr0!!3r"
    assert !user.valid?
    assert user.errors[:name].any?
    assert_equal ["can't be blank*"], user.errors[:name]
    assert !user.save
  end

  test "should not create user with incorrectly formatted name" do
    user = User.new
    user.email = "bad_name@example.com"
    user.password = "c0ntr0!!3r"
    # Does not start with a capital
    user.name = "bad Name"
    assert !user.valid?
    assert user.errors.any?
    assert_equal :"Name Format Error*", user.errors.first[0]
    assert !user.save
    # Does not only contain letters
    user.name = "Bad Name1"
    assert !user.valid?
    assert user.errors.any?
    assert_equal :"Name Format Error*", user.errors.first[0]
    assert !user.save
    # No last name
    user.name = "Bad"
    assert !user.valid?
    assert user.errors.any?
    assert_equal :"Name Format Error*", user.errors.first[0]
    assert !user.save
  end

  test "should not create user if another user is already set up to receive customer inquires" do
    # Fixture already has admin user that is set up to receive customer inquiries
    user = User.new
    user.email = "create_admin@example.com"
    user.password = "c0ntr0!!3r"
    user.name = "Create Admin User"
    user.active = true
    user.admin = true
    user.receive_customer_inquiry = true
    assert !user.valid?
    assert user.errors[:receive_customer_inquiry].any?
    assert_equal ["has already been taken*"], user.errors[:receive_customer_inquiry]
    assert !user.save
  end

  test "should allow correctly formatted zip" do
    user = users(:user)
    # Should allow alphas in first 5 characters to support Mexican and Canadian post codes
    assert user.update_attributes(newsletter: "A1B2C")
    # Should allow for a "plus 4" zip
    assert user.update_attributes(newsletter: "53715-1234")
  end

  test "should not create user with incorrectly formatted zip" do
    user = User.new
    user.email = "bad_zip@example.com"
    user.password = "c0ntr0!!3r"
    user.name = "Bad Zip"
    # Not in ##### or #####-#### format
    user.zip_code = "123456"
    assert !user.valid?
    assert user.errors.any?
    assert_equal :"Postal Code Format Error*", user.errors.first[0]
    assert !user.save
    # If in #####-#### format, the plus 4 should be numbers
    user.zip_code = "12345-ABCD"
    assert !user.valid?
    assert user.errors.any?
    assert_equal :"Postal Code Format Error*", user.errors.first[0]
    assert !user.save
  end

  test "should only return admin users with admin_only scope" do
    scope_users = User.admin_only
    found_users = User.where(admin: true).load
    assert_equal scope_users.count, found_users.count
  end

  test "should encrypt new password" do
    user = User.new
    user.email = "encrypt@example.com"
    user.password = "c0ntr0!!3r"
    user.name = "Encrypt User"
    user.active = true
    user.admin = false
    user.save
    assert_equal user.hashed_password, "ea362246eaa6a99bfe18d72a07babcc728fd7e30"
  end

  test "should authenticate user" do
    user = User.authenticate("admin@example.com", "c0ntr0!!3r")
    assert user.is_a? User  
  end

  test "should not authenticate user" do
    user = User.authenticate("admin@example.com", "badpassword")
    assert !(user.is_a? User)
  end

  test "should return all_messages" do
    # Create 3 messages (6 message records), with only 2 that should be returned
    create_message(users(:user), users(:admin))
    create_message(users(:admin), users(:admin_2))
    create_message(users(:admin_2), users(:user))
    user = users(:user)
    assert_equal 2, user.all_messages.count
    # Message in user's inbox (since messages returned in reverse chronological order)
    in_message = user.all_messages.first
    assert_equal user.id, in_message.owner_user_id
    # Message in user's sent mail
    out_message = user.all_messages.last
    assert_equal user.id, out_message.from_user_id
    assert_nil out_message.copied_message_id
  end

  test "should return messages that should display in user's inbox" do
    # Create 3 messages (6 message records), with only 1 that should be returned
    create_message(users(:user), users(:admin))
    create_message(users(:admin), users(:admin_2))
    create_message(users(:admin_2), users(:user))
    user = users(:user)
    assert_equal 1, user.inbox.count
    in_message = user.inbox.first  # Message in user's inbox
    assert_equal user.id, in_message.owner_user_id
    assert !(in_message.deleted)
    in_message.update_attributes(deleted: true)  # Delete the message
    assert_equal 0, user.inbox.count
  end

  test "should return messages that should display as user's sent_messages" do
    # Create 3 messages (6 message records), with only 1 that should be returned
    create_message(users(:user), users(:admin))
    create_message(users(:admin), users(:admin_2))
    create_message(users(:admin_2), users(:user))
    user = users(:user)
    assert_equal 1, user.sent_messages.count
    out_message = user.sent_messages.first
    assert_equal user.id, out_message.from_user_id
    assert_nil out_message.copied_message_id
    assert !(out_message.deleted)
    out_message.update_attributes(deleted: true)  # Delete the message
    assert_equal 0, user.sent_messages.count
  end

end
