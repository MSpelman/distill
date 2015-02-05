class SessionsController < ApplicationController

  # New session; this method technically is not necessary, but I prefer each action 
  # to at least have a stub tag in the controller.
  def new
  end

  # Action to create a new session
  def create
    user = User.authenticate(params[:email], params[:password])
    if user.is_a? User
      session[:user_id] = user.id
      if session[:checking_out]
        session[:checking_out] = nil
        redirect_to new_order_path, notice: t('sessions.successful_login')  # "Log in successful!"
      else
        redirect_to root_path, notice: t('sessions.successful_login')  # "Log in successful!"
      end
    else
      flash.now[:alert] = t('sessions.incorrect_login')  # "Incorrect login and/or password"
      render action: "new"
    end
  end

  # Action to log user out
  def destroy
    reset_session
    redirect_to root_path, notice: t('sessions.successful_logout')  # "You have successfully logged out."
  end

end
