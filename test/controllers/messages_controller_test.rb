require 'test_helper'

class MessagesControllerTest < ActionController::TestCase
  setup do
  end

  test "should get index with user's messages" do
    # Create 3 messages (6 message records), with only 2 that should show in index
    create_message(users(:user), users(:admin))
    create_message(users(:admin), users(:admin_2))
    create_message(users(:admin_2), users(:user))
    login_as(:user)
    get :index
    assert_response :success
    assert_template "index"
    assert_not_nil assigns(:messages)
    assert_equal users(:user).all_messages.not_deleted.count, assigns(:messages).count
    assert_equal 2, assigns(:messages).count
    assert_equal :index, @request.session[:messaging_context]
  end

  test "should not get index" do
    # Create 3 messages (6 message records)
    create_message(users(:user), users(:admin))
    create_message(users(:admin), users(:admin_2))
    create_message(users(:admin_2), users(:user))
    get :index
    assert_response :redirect
    assert_nil assigns(:messages)
  end

  test "should get new" do
    login_as(:user)
    get :new
    assert_response :success
    assert_template "new"
  end

  test "should not get new" do
    get :new
    assert_response :redirect
  end

  test "should get reply" do
    message_hash = create_message(users(:admin), users(:user))
    message = message_hash[:in]  # Message record that appears in user's inbox
    login_as(:user)
    get :reply, message_id: message.id
    assert_response :success
    assert_template "reply"
    assert_equal message.id, @request.session[:parent_message_id]
    reply_message = assigns(:message)
    assert_equal message.id, reply_message.parent_id
    assert_equal message.from_user_id, reply_message.recipient_user_id
    assert_equal message.message_type_id, reply_message.message_type_id
    assert_equal message.subject + " (Reply)*", reply_message.subject
  end

  test "should not get reply" do
    message_hash = create_message(users(:admin), users(:user))
    message = message_hash[:in]  # Message record that appears in user's inbox
    get :reply, message_id: message.id
    assert_response :redirect
  end

  test "should create message from user" do
    login_as(:user)
    @request.session[:messaging_context] = :index
    assert_difference('Message.count', 2) do
      post :create, message: { subject: "Test Subject",
                               body: "Message body" }
    end
    out_message = assigns(:message)  # outgoing message record
    in_message = out_message.copies.first  # recipient's message record
    assert_equal 1, out_message.message_type_id
    assert_equal @request.session[:user_id], out_message.from_user_id
    assert_equal users(:admin_2).id, out_message.recipient_users.first.user_id
    assert_equal users(:admin_2).id, in_message.owner_user_id
    assert_equal users(:admin_2).id, in_message.recipient_users.first.user_id
    assert_redirected_to messages_path
  end

  test "should not create message from user if no subject" do
    login_as(:user)
    @request.session[:messaging_context] = :index
    assert_no_difference('Message.count') do
      post :create, message: { body: "Message body" }
    end
    assert_template 'new'
  end

  test "should create message from admin" do
    login_as(:admin)
    @request.session[:messaging_context] = :mailbox_out
    assert_difference('Message.count', 2) do
      post :create, message: { recipient_user_id: users(:admin_2).id,
                               message_type_id: message_types(:admin).id,
                               subject: "Test Subject",
                               body: "Message body" }
    end
    out_message = assigns(:message)  # outgoing message record
    in_message = out_message.copies.first  # recipient's message record
    assert_equal message_types(:admin).id, out_message.message_type_id
    assert_equal @request.session[:user_id], out_message.from_user_id
    assert_equal users(:admin_2).id, out_message.recipient_users.first.user_id
    assert_equal users(:admin_2).id, in_message.owner_user_id
    assert_equal users(:admin_2).id, in_message.recipient_users.first.user_id
    assert_redirected_to mailbox_out_messages_path
  end

  test "should not create message from admin if no recipient" do
    login_as(:admin)
    @request.session[:messaging_context] = :mailbox_out
    assert_no_difference('Message.count') do
      post :create, message: { message_type_id: message_types(:admin).id,
                               subject: "Test Subject",
                               body: "Message body" }
    end
    assert_template 'new'
  end

  test "should not create message from admin if no type" do
    login_as(:admin)
    @request.session[:messaging_context] = :mailbox_out
    assert_no_difference('Message.count') do
      post :create, message: { recipient_user_id: users(:admin_2).id,
                               subject: "Test Subject",
                               body: "Message body" }
    end
    assert_template 'new'
  end

  test "should not create message if not logged in" do
    @request.session[:messaging_context] = :mailbox_out
    assert_no_difference('Message.count') do
      post :create, message: { recipient_user_id: users(:admin_2).id,
                               message_type_id: message_types(:admin).id,
                               subject: "Test Subject",
                               body: "Message body" }
    end
    assert_response :redirect
  end

  test "should create reply message" do
    message_hash = create_message(users(:user), users(:admin))
    original_message = message_hash[:in]  # Message record that appears in admin's inbox
    login_as(:admin)
    @request.session[:messaging_context] = :mailbox_in
    @request.session[:parent_message_id] = original_message.id
    assert_difference('Message.count', 2) do
      post :create, message: { body: "Message body" }
    end
    out_message = assigns(:message)  # outgoing message record for reply
    in_message = out_message.copies.first  # recipient message record for reply
    expected_subject = original_message.subject + " (Reply)*"
    assert_equal expected_subject, out_message.subject
    assert_equal @request.session[:user_id], out_message.from_user_id
    assert_equal original_message.id, out_message.parent_id
    assert_equal original_message.message_type_id, out_message.message_type_id
    assert_equal original_message.from_user_id, out_message.recipient_users.first.user_id
    assert_equal original_message.from_user_id, in_message.owner_user_id
    assert_equal original_message.from_user_id, in_message.recipient_users.first.user_id
    assert_redirected_to mailbox_in_messages_path
  end

  test "should show message" do
    message_hash = create_message(users(:admin), users(:user))
    message = message_hash[:in]  # Message record that appears in user's inbox
    login_as(:user)
    assert_nil message.read
    get :show, id: message.to_param
    assert_response :success
    assert_template "show"
    @message = assigns(:message)
    assert_not_nil @message
    assert @message.valid?
    assert_equal true, @message.read
  end

  test "should not show message" do
    message_hash = create_message(users(:admin), users(:user))
    message = message_hash[:in]  # Message record that appears in user's inbox
    # User not logged in
    assert_raise(NoMethodError) do
      get :show, id: message.to_param
    end
    # User trying to show a different user's message
    login_as(:admin_2)
    assert_raise(ActiveRecord::RecordNotFound) do
      get :show, id: message.to_param
    end
    assert_nil assigns(:message)
  end

  test "should get edit (forward)" do
    message_hash = create_message(users(:user), users(:admin_2))
    @message = message_hash[:in]  # Message record that appears in admin_2's inbox
    login_as(:admin_2)
    @request.session[:messaging_context] = :mailbox_in
    get :edit, id: @message.to_param
    assert_response :success
    assert_template "edit"
  end

  test "should not get edit (forward)" do
    message_hash = create_message(users(:user), users(:admin_2))
    @message = message_hash[:in]  # Message record that appears in admin_2's inbox
    @request.session[:messaging_context] = :mailbox_in
    # Not logged in
    assert_raise(NoMethodError) do
      get :edit, id: @message.to_param
    end
    # Wrong user
    login_as(:admin)
    assert_raise(ActiveRecord::RecordNotFound) do
      get :edit, id: @message.to_param
    end
  end

  test "should not get edit (forward) if not admin" do
    message_hash = create_message(users(:admin_2), users(:user))
    @message = message_hash[:in]  # Message record that appears in user's inbox
    @request.session[:messaging_context] = :mailbox_in
    login_as(:user)
    get :edit, id: @message.to_param
    assert_response :redirect
  end

  test "should update (forward) message" do
    message_hash = create_message(users(:user), users(:admin_2))
    @message = message_hash[:in]  # Message record that appears in admin_2's inbox
    login_as(:admin_2)
    @request.session[:messaging_context] = :mailbox_in
    patch :update, id: @message.to_param, message: { recipient_user_id: users(:admin),
                                                     fwd_note: "Where is this user's order?" }
    original_message = assigns(:message)  # message being forwarded
    new_message = original_message.copies.first  # message created by forward
    assert_equal users(:admin).id, new_message.owner_user_id
    assert_equal original_message.id, new_message.forwarded_message_id
    assert !(new_message.read)
    assert_equal "Where is this user's order?", new_message.forward_note
    assert_equal original_message.id, new_message.copied_message_id
    assert_equal users(:admin).id, new_message.recipient_users.first.user_id
    assert_redirected_to mailbox_in_messages_path
  end

  test "should update (forward) message and default forward note" do
    message_hash = create_message(users(:user), users(:admin_2))
    @message = message_hash[:in]  # Message record that appears in admin_2's inbox
    login_as(:admin_2)
    @request.session[:messaging_context] = :index
    patch :update, id: @message.to_param, message: { recipient_user_id: users(:admin) }
    original_message = assigns(:message)  # message being forwarded
    new_message = original_message.copies.first  # message created by forward
    assert_equal users(:admin).id, new_message.owner_user_id
    assert_equal original_message.id, new_message.forwarded_message_id
    assert !(new_message.read)
    assert_equal "Forwarded message*", new_message.forward_note
    assert_equal original_message.id, new_message.copied_message_id
    assert_equal users(:admin).id, new_message.recipient_users.first.user_id
    assert_redirected_to messages_path
  end

  test "should not update (forward) message if not admin" do
    message_hash = create_message(users(:admin_2), users(:user))
    @message = message_hash[:in]  # Message record that appears in user's inbox
    @request.session[:messaging_context] = :mailbox_in
    login_as(:user)
    patch :update, id: @message.to_param, message: { recipient_user_id: users(:admin),
                                                     fwd_note: "Where is this user's order?" }
    assert_redirected_to login_path
  end

  test "should not update (forward) message if no recipient" do
    message_hash = create_message(users(:user), users(:admin_2))
    @message = message_hash[:in]  # Message record that appears in admin_2's inbox
    @request.session[:messaging_context] = :mailbox_in
    login_as(:admin_2)
    patch :update, id: @message.to_param, message: { fwd_note: "Where is this user's order?" }
    assert_template 'edit'
  end

  test "should destroy message and return to index" do
    message_hash = create_message(users(:admin), users(:user))
    @message = message_hash[:in]  # Message record that appears in user's inbox
    @request.session[:messaging_context] = :index
    login_as(:user)
    delete :destroy, id: @message.to_param
    assert_redirected_to messages_path
    assert_equal true, assigns(:message).deleted
  end

  test "should destroy message and return to mailbox_out" do
    message_hash = create_message(users(:admin), users(:user))
    @message = message_hash[:in]  # Message record that appears in user's inbox
    @request.session[:messaging_context] = :mailbox_out
    login_as(:user)
    delete :destroy, id: @message.to_param
    assert_redirected_to mailbox_out_messages_path
    assert_equal true, assigns(:message).deleted
  end

  test "should destroy message and return to mailbox_in" do
    message_hash = create_message(users(:admin), users(:user))
    @message = message_hash[:in]  # Message record that appears in user's inbox
    @request.session[:messaging_context] = :mailbox_in
    login_as(:user)
    delete :destroy, id: @message.to_param
    assert_redirected_to mailbox_in_messages_path
    assert_equal true, assigns(:message).deleted
  end

  test "should not destroy message if not logged in" do
    message_hash = create_message(users(:admin), users(:user))
    @message = message_hash[:in]  # Message record that appears in user's inbox
    @request.session[:messaging_context] = :mailbox_in
    assert_raise(NoMethodError) do
      delete :destroy, id: @message.to_param
    end
  end

  test "should get mailbox_in with user's messages" do
    # Create 3 messages (6 message records), with only 1 that should show in inbox
    create_message(users(:user), users(:admin))
    create_message(users(:admin), users(:admin_2))
    create_message(users(:admin_2), users(:user))
    login_as(:user)
    get :mailbox_in
    assert_response :success
    assert_template "mailbox_in"
    assert_not_nil assigns(:messages)
    assert_equal users(:user).inbox.count, assigns(:messages).count
    assert_equal 1, assigns(:messages).count
    assert_equal :mailbox_in, @request.session[:messaging_context]
  end

  test "should not get mailbox_in" do
    # Create 3 messages (6 message records)
    create_message(users(:user), users(:admin))
    create_message(users(:admin), users(:admin_2))
    create_message(users(:admin_2), users(:user))
    get :mailbox_in
    assert_response :redirect
    assert_nil assigns(:messages)
  end

  test "should get mailbox_out with user's messages" do
    # Create 3 messages (6 message records), with only 1 that should show in inbox
    create_message(users(:user), users(:admin))
    create_message(users(:admin), users(:admin_2))
    create_message(users(:admin_2), users(:user))
    login_as(:user)
    get :mailbox_out
    assert_response :success
    assert_template "mailbox_out"
    assert_not_nil assigns(:messages)
    assert_equal users(:user).sent_messages.count, assigns(:messages).count
    assert_equal 1, assigns(:messages).count
    assert_equal :mailbox_out, @request.session[:messaging_context]
  end

  test "should not get mailbox_out" do
    # Create 3 messages (6 message records)
    create_message(users(:user), users(:admin))
    create_message(users(:admin), users(:admin_2))
    create_message(users(:admin_2), users(:user))
    get :mailbox_out
    assert_response :redirect
    assert_nil assigns(:messages)
  end

  test "should get user_lookup" do
    login_as(:admin)
    # Start out at new since it is the only view that uses user_lookup
    get :new
    assert_response :success
    assert_template "new"
    # Case where nothing entered
    get :user_lookup, user_lookup: "", format: :js
    assert_response :success
    assert_nil assigns(:users)
    # Case where no user found
    get :user_lookup, user_lookup: "James", format: :js
    assert_response :success
    assert_equal 0, assigns(:users).length
    # Case where one or more users found
    get :user_lookup, user_lookup: "admin", format: :js
    assert_response :success
    assert_equal 2, assigns(:users).length
  end

  test "should not get user_lookup" do
    login_as(:user)
    get :user_lookup, user_lookup: "admin"
    assert_response :redirect
    assert_nil assigns(:users)
  end

end
