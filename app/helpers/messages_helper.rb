module MessagesHelper

  # Helper that allows user to submit form or cancel
  # form; cancel returns the user to messages#index
  # Accepts a reference to the form button/link are on
  # cancel_name: name for the cancel link; default is Cancel
  def submit_or_return_to_messages_index(form, cancel_name = t('application.cancel'))  # "Cancel"
    if session[:parent_message_id]
      form.submit(t('messages.send')) + " " + t('application.or') + " " + link_to(cancel_name, message_path(session[:parent_message_id].to_i), :class => "cancel")  # "Send", "or"
    elsif session[:messaging_context] == :index
      form.submit(t('messages.send')) + " " + t('application.or') + " " + link_to(cancel_name, messages_path, :class => "cancel")  # "Send", "or"
    elsif session[:messaging_context] == :mailbox_out
      form.submit(t('messages.send')) + " " + t('application.or') + " " + link_to(cancel_name, mailbox_out_messages_path, :class => "cancel")  # "Send", "or"
    else
      form.submit(t('messages.send')) + " " + t('application.or') + " " + link_to(cancel_name, mailbox_in_messages_path, :class => "cancel")  # "Send", "or"
    end
  end

  # Helper that allows user to submit form or cancel
  # form; cancel returns the user to messages#show
  # Accepts a reference to the form button/link are on
  # cancel_name: name for the cancel link; default is Cancel
  def submit_or_return_to_show(form, cancel_name = t('application.cancel'))  # "Cancel"
    form.submit(t('messages.send')) + " " + t('application.or') + " " + link_to(cancel_name, @message, :class => "cancel")  # "Send", "or"
  end

end
