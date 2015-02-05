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
    user.state = "WI"
    user.zip_code = "53715"
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

  test "should not create user with no name" do
    user = User.new
    user.email = "no_name@example.com"
    user.password = "c0ntr0!!3r"
    assert !user.valid?
    assert user.errors[:name].any?
    assert_equal ["can't be blank*"], user.errors[:name]
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

end
