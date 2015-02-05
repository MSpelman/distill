module OrdersHelper

  # Helper that allows user to submit form or cancel
  # form; cancel returns the user to orders#index or users#show, depending on where
  # the user was before they edited the order
  # Accepts a reference to the form button/link are on
  # cancel_name: name for the cancel link; default is Cancel
  def submit_or_return_to_orders_index(form, cancel_name = t('application.cancel'))  # "Cancel"
    if session[:showing_user]
      form.submit + " " + t('application.or') + " " + link_to(cancel_name, @order.user, :class => "cancel")  # "or"
    else
      form.submit + " " + t('application.or') + " " + link_to(cancel_name, orders_path, :class => "cancel")  # "or"
    end
  end

  # Helper that allows user to submit form or cancel
  # form.  The submit button is labeled "Check Out", since it checks out the shopping
  # cart and creates a new order.  The cancel link is labeled "Return" since it simply
  # exits the shopping cart and returns the user to whatever view they were previously on
  # Accepts a reference to the form button/link are on
  def check_out_or_return(form)
    form.submit(t('orders.check_out')) + " " + t('application.or') + " " + link_to(t('orders.return'), "javascript:history.go(-1);", :class => "cancel")  # "Check Out", "or", "Return"
  end

end
