class UsersController < ApplicationController
  before_action :user_only, only: [:edit_self, :update]
  before_action :admin_only, only: [:index, :show, :new, :edit, :search, :search_result]
  before_action :not_logged_in_only, only: [:new_self]
  before_action :set_user, only: [:show, :edit]

  # GET /users
  # GET /users.json
  def index
    session[:showing_user] = nil
    @users = User.admin_only  # Showing all users would overwhelm display
  end

  # GET /users/1
  # GET /users/1.json
  def show
    session[:showing_user] = true
  end

  # GET /users/new
  def new
    @user = User.new
  end

  # GET /users/new
  # This action allows people without a user profile to create one for themselves
  def new_self
    @user = User.new
  end

  # GET /users/1/edit
  def edit
  end

  # GET /users/1/edit_self
  # This action allows non-admin users to update their own profile
  def edit_self
    @user = current_user
  end

  # POST /users
  # POST /users.json
  def create
    @user = User.new(user_params)

    respond_to do |format|
      if @user.save
        if admin_user?  # Admin user; return to users index after save
          format.html { redirect_to search_users_path, notice: t('users.admin_create') }  # "User was successfully created."
          format.json { render action: 'search', status: :created, location: @user }
        else  # New non-admin user; return them to home page after create
          @user.update_attributes(:active => true)  # User create profile for self; default to active
          session[:user_id] = @user.id  # Create "session"
          format.html { redirect_to root_path, notice: t('users.self_create') }  # "User profile successfully created!"
          format.json { head :no_content }
        end
      else
        if admin_user?
          format.html { render action: 'new' }
          format.json { render json: @user.errors, status: :unprocessable_entity }
        else
          format.html { render action: 'new_self' }
          format.json { render json: @user.errors, status: :unprocessable_entity }
        end
      end
    end
  end

  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
  def update
    if admin_user?
      @user = User.find(params[:id])  # set user admin selected
    else
      @user = current_user  # non-admin users only allowed to update own profile
    end

    respond_to do |format|
      if @user.update(user_params)
        if admin_user?  # Admin user; return to users index after save
          format.html { redirect_to search_users_path, notice: t('users.admin_update') }  # "User was successfully updated."
          format.json { head :no_content }
        else  # Non-admin user; return them to home page after update
          format.html { redirect_to root_path, notice: t('users.self_update') }  # "Your profile was successfully updated."
          format.json { head :no_content }
        end
      else
        format.html { render action: 'edit' }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # GET /users/search
  def search
    session[:showing_user] = nil
    @users = User.admin_only  # Showing all users would overwhelm display
  end

  # POST /users/search
  def search_result
    email = params[:email]
    redirect_to(search_users_path, notice: t('users.no_email')) and return if (email.nil? || (email == ''))  # "Please enter an email address to search on."
    @user = User.find_by_email(email)
    redirect_to(search_users_path, notice: t('users.no_user')) and return if @user.nil?  # "No user has this email address."
    redirect_to @user
  end

  # DELETE /users/1
  # DELETE /users/1.json
  # Deleting a user associated with an order or comment would cause data corruption.
  # Mark users that should not be used as inactive
  #def destroy
  #  @user.destroy
  #  respond_to do |format|
  #    format.html { redirect_to users_url }
  #    format.json { head :no_content }
  #  end
  #end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_params
      if admin_user?
        params.require(:user).permit(:email, :password, :password_confirmation, :name, :address_1, :address_2, :apt_number, :city, :state, :zip_code, :newsletter, :active, :admin)
      else
        # Don't allow non-admin users to hack the parameters and give themselves admin security; self created records automatically set to active
        params.require(:user).permit(:email, :password, :password_confirmation, :name, :address_1, :address_2, :apt_number, :city, :state, :zip_code, :newsletter)
      end
    end

end
