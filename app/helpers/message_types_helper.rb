module MessageTypesHelper

  # Helper that allows user to submit form or cancel
  # form; cancel returns the user to message_types#index
  # Accepts a reference to the form button/link are on
  # cancel_name: name for the cancel link; default is Cancel
  def submit_or_return_to_message_types_index(form, cancel_name = t('application.cancel'))  # "Cancel"
    form.submit + " " + t('application.or') + " " + link_to(cancel_name, message_types_path, :class => "cancel")  # "or"
  end

end
