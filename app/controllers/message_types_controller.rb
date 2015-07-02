class MessageTypesController < ApplicationController
  before_action :set_message_type, only: [:show, :edit, :update]
  before_action :admin_only

  # GET /message_types
  # GET /message_types.json
  def index
    @message_types = MessageType.all
  end

  # GET /message_types/1
  # GET /message_types/1.json
  #def show
  #end

  # GET /message_types/new
  def new
    @message_type = MessageType.new
  end

  # GET /message_types/1/edit
  def edit
  end

  # POST /message_types
  # POST /message_types.json
  def create
    @message_type = MessageType.new(message_type_params)

    respond_to do |format|
      if @message_type.save
        format.html { redirect_to message_types_path, notice: t('message_types.create') }  # "Message Type was successfully created."
        format.json { render action: 'index', status: :created, location: @message_type }
      else
        format.html { render action: 'new' }
        format.json { render json: @message_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /message_types/1
  # PATCH/PUT /message_types/1.json
  def update
    respond_to do |format|
      if @message_type.update(message_type_params)
        format.html { redirect_to message_types_path, notice: t('message_types.update') }  # "Message Type was successfully updated."
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @message_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /message_types/1
  # DELETE /message_types/1.json
  # Deleting a message type could cause data integrity issues; mark as active: false
  #def destroy
  #  @message_type.destroy
  #  respond_to do |format|
  #    format.html { redirect_to message_types_url }
  #    format.json { head :no_content }
  #  end
  #end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_message_type
      @message_type = MessageType.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def message_type_params
      params.require(:message_type).permit(:name, :description, :active)
    end
end
