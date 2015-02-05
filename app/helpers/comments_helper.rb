module CommentsHelper

  # Helper that allows user to submit form or cancel
  # form; cancel returns the user to products#show or the comments#index
  # Accepts a reference to the form button/link are on
  # cancel_name: name for the cancel link; default is Cancel
  def submit_with_cancel_comments(form, cancel_name = t('application.cancel'))  # "Cancel"
    if session[:comments_index]
      form.submit + " " + t('application.or') + " " + link_to(cancel_name, product_comments_path('#'), class: "cancel")  # "or"
    else
      form.submit + " " + t('application.or') + " " + link_to(cancel_name, @product, class: "cancel")  # "or"
    end
  end

  # Helper to determine if the user should get a link to approve a comment
  def approve_allowed?(comment = @comment)
    # Only Admin can approve, active flag not set to true
    return true if (admin_user? && !(comment.active == true))
    return false
  end

end
