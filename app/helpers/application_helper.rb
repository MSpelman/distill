module ApplicationHelper

  # Helper that allows user to submit form or cancel
  # form: accepts a reference to the form button/link are on
  # cancel_name: name for the cancel link; default is Cancel
  def submit_with_cancel(form, cancel_name = t('application.cancel'))  # "Cancel"
    form.submit + " " + t('application.or') + " " + link_to(cancel_name, "javascript:history.go(-1);", :class => "cancel")  # "or"
  end

end
