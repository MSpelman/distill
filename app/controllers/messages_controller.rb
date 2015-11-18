class MessagesController < ApplicationController
  # respond_to :html, :json
  before_action :set_message, only: [:show, :edit, :update, :destroy]
  before_action :user_only, except: [:edit, :update, :user_lookup]
  before_action :admin_only, only: [:edit, :update, :user_lookup]

  # GET /messages
  # GET /messages.json
  def index
    @messages = current_user.all_messages.not_deleted
    session[:messaging_context] = :index
  end

  # GET /messages/1
  # GET /messages/1.json
  def show
    @message.update_attributes(read: true)
  end

  # GET /messages/new
  def new
    @message = Message.new
    session[:parent_message_id] = nil
  end

  # GET /messages/reply
  def reply
    @message = Message.new
    parent_message = current_user.all_messages.find(params[:message_id].to_i)
    session[:parent_message_id] = parent_message.id
    @message.parent_id = parent_message.id
    @message.recipient_user_id = parent_message.from_user_id
    @message.message_type_id = parent_message.message_type_id
    @message.subject = parent_message.subject
    @message.subject += t('messages.reply_postfix') if (@message.subject.scan(t('messages.reply_postfix')).empty?)  # " (Reply)"
  end

  # GET /messages/1/edit
  def edit
  end

  # POST /messages
  # POST /messages.json
  def create
    @message = Message.new(message_params)

    unless (session[:parent_message_id] || !(admin_user?))
      @message.require_recipient = true
      @message.require_type = true
    end
    @message.require_subject = true unless (session[:parent_message_id])

    respond_to do |format|
      if @message.save
        if session[:parent_message_id]  # Reply message
          parent_message = current_user.all_messages.find(session[:parent_message_id].to_i)
          message_subject = parent_message.subject
          message_subject += t('messages.reply_postfix') if (message_subject.scan(t('messages.reply_postfix')).empty?)  # " (Reply)"
          @message.update_attributes(from_user_id: current_user.id,
                                     parent_id: session[:parent_message_id].to_i,
                                     message_type_id: parent_message.message_type_id,
                                     subject: message_subject)
          recipient_user_id = parent_message.from_user_id
        else  # New message
          if admin_user?
            @message.update_attributes(from_user_id: current_user.id)
            recipient_user_id = @message.recipient_user_id
          else  # logged in non-admin user (know logged in because of callback)
            @message.update_attributes(from_user_id: current_user.id, message_type_id: 1)
            recipient_user_id = admin_for_customer_inquiries.id
          end
        end
        session[:parent_message_id] = nil
        @message.recipient_users.create(user_id: recipient_user_id)
        recipient_copy = @message.dup
        if recipient_copy.save
          recipient_copy.update_attributes(owner_user_id: recipient_user_id, copied_message_id: @message.id)
          recipient_copy.recipient_users.create(user_id: recipient_user_id)
        end
        if session[:messaging_context] == :index
          format.html { redirect_to messages_path, notice: t('messages.create') }  # "Message was successfully sent."
          format.json { render action: 'index', status: :created, location: @message }
        elsif session[:messaging_context] == :mailbox_out
          format.html { redirect_to mailbox_out_messages_path, notice: t('messages.create') }  # "Message was successfully sent."
        else
          format.html { redirect_to mailbox_in_messages_path, notice: t('messages.create') }  # "Message was successfully sent."
        end
      else
        format.html { render action: 'new' }
        format.json { render json: @message.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /messages/1
  # PATCH/PUT /messages/1.json
  def update
    @message.require_recipient = true
    respond_to do |format|
      if @message.update(message_params)
        recipient_user_id = @message.recipient_user_id
        forward_note = @message.fwd_note
        forward_note = t('messages.default_forward_note') if ((forward_note.nil?) || (forward_note == ''))  # "Forwarded message"
        new_message = @message.dup
        if new_message.save
          new_message.update_attributes(owner_user_id: recipient_user_id,
                                                       forwarded_message_id: @message.id,
                                                       read: false,
                                                       forward_note: forward_note,
                                                       copied_message_id: @message.id)
          new_message.recipient_users.create(user_id: recipient_user_id)
        end
        if session[:messaging_context] == :index
          format.html { redirect_to messages_path, notice: t('messages.update') }  # "Message was successfully forwarded."
          format.json { head :no_content }
        elsif session[:messaging_context] == :mailbox_out
          format.html { redirect_to mailbox_out_messages_path, notice: t('messages.update') }  # "Message was successfully forwarded."
          format.json { head :no_content }
        else
          format.html { redirect_to mailbox_in_messages_path, notice: t('messages.update') }  # "Message was successfully forwarded."
          format.json { head :no_content }
        end
      else
        format.html { render action: 'edit' }
        format.json { render json: @message.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /messages/1
  # DELETE /messages/1.json
  def destroy
    @message.update_attributes(deleted: true)
    respond_to do |format|
      if session[:messaging_context] == :index
        format.html { redirect_to messages_path }
        format.js
      elsif session[:messaging_context] == :mailbox_out
        format.html { redirect_to mailbox_out_messages_path }
        format.js
      else
        format.html { redirect_to mailbox_in_messages_path }
        format.js
      end
    end
  end

  # GET /messages/mailbox_in
  def mailbox_in
    @messages = current_user.inbox
    session[:messaging_context] = :mailbox_in
  end

  # GET /messages/mailbox_out
  def mailbox_out
    @messages = current_user.sent_messages
    session[:messaging_context] = :mailbox_out
  end

  # GET /messages/user_lookup
  def user_lookup
    lookup_string = params[:user_lookup] + '%'  # % is wildcard for where method/SQL

    # User hit Search without entering a lookup string
    return if (lookup_string == '%')

    # Lookup based on email or name
    @users = User.where("(email LIKE ?) OR (name LIKE ?)", lookup_string, lookup_string)

    # No matching users found
    return if (@users.size < 1)

    # Respond with _user_lookup partial with users found (@users)
    respond_to do |format|
      format.js { }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_message
      @message = current_user.all_messages.find(params[:id])  # Can only access own msgs
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def message_params
      params.require(:message).permit(:subject, :body, :deleted, :read, :took_ownership_at, :message_type_id, :recipient_user_id, :fwd_note)
    end

    # Returns admin that customer inquiries should be sent to
    def admin_for_customer_inquiries
      admin_user = User.where("receive_customer_inquiry = ?", true)
      admin_user = User.where("((admin = ?) AND (active = ?))", true, true) if admin_user.empty?
      return admin_user.first
    end

end
