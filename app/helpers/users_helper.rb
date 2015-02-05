module UsersHelper

  # Helper that allows user to submit form or cancel
  # form; cancel returns the user to users#search
  # Accepts a reference to the form button/link are on
  # cancel_name: name for the cancel link; default is Cancel
  def submit_or_return_to_user_search(form, cancel_name = t('application.cancel'))  # "Cancel"
    form.submit + " " + t('application.or') + " " + link_to(cancel_name, search_users_path, :class => "cancel")  # "or"
  end

  # Helper that allows user to submit form or cancel
  # form; cancel returns un-logged in user to login_path.  User editing self is returned to the page
  # they were previously on.
  # Accepts a reference to the form button/link are on
  # cancel_name: name for the cancel link; default is Cancel
  def submit_or_cancel_for_users(form, cancel_name = t('application.cancel'))  # "Cancel"
    if logged_in?
      form.submit + " " + t('application.or') + " " + link_to(cancel_name, "javascript:history.go(-1);", :class => "cancel")  # "or"
    else
      form.submit + " " + t('application.or') + " " + link_to(cancel_name, login_path, :class => "cancel")  # "or"
    end
  end

end
