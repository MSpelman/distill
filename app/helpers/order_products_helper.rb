module OrderProductsHelper

  # Helper that allows user to submit form or cancel
  # form; cancel returns the user to orders#edit
  # Accepts a reference to the form button/link are on
  # cancel_name: name for the cancel link; default is Cancel
  def submit_with_cancel_order_products(form, cancel_name = t('application.cancel'))  # "Cancel"
    form.submit + " " + t('application.or') + " " + link_to(cancel_name, edit_order_path(@order), class: "cancel")  # "or"
  end

end
