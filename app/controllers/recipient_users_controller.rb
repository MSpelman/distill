class RecipientUsersController < ApplicationController
  before_action :set_recipient_user, only: [:show, :edit, :update, :destroy]

  # GET /recipient_users
  # GET /recipient_users.json
  #def index
  #  @recipient_users = RecipientUser.all
  #end

  # GET /recipient_users/1
  # GET /recipient_users/1.json
  #def show
  #end

  # GET /recipient_users/new
  #def new
  #  @recipient_user = RecipientUser.new
  #end

  # GET /recipient_users/1/edit
  #def edit
  #end

  # POST /recipient_users
  # POST /recipient_users.json
  #def create
  #  @recipient_user = RecipientUser.new(recipient_user_params)

  #  respond_to do |format|
  #    if @recipient_user.save
  #      format.html { redirect_to @recipient_user, notice: 'Recipient user was successfully created.' }
  #      format.json { render action: 'show', status: :created, location: @recipient_user }
  #    else
  #      format.html { render action: 'new' }
  #      format.json { render json: @recipient_user.errors, status: :unprocessable_entity }
  #    end
  #  end
  #end

  # PATCH/PUT /recipient_users/1
  # PATCH/PUT /recipient_users/1.json
  #def update
  #  respond_to do |format|
  #    if @recipient_user.update(recipient_user_params)
  #      format.html { redirect_to @recipient_user, notice: 'Recipient user was successfully updated.' }
  #      format.json { head :no_content }
  #    else
  #      format.html { render action: 'edit' }
  #      format.json { render json: @recipient_user.errors, status: :unprocessable_entity }
  #    end
  #  end
  #end

  # DELETE /recipient_users/1
  # DELETE /recipient_users/1.json
  #def destroy
  #  @recipient_user.destroy
  #  respond_to do |format|
  #    format.html { redirect_to recipient_users_url }
  #    format.json { head :no_content }
  #  end
  #end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_recipient_user
      @recipient_user = RecipientUser.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def recipient_user_params
      params.require(:recipient_user).permit(:message_id, :user_id)
    end
end
