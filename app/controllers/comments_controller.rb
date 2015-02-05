class CommentsController < ApplicationController
  before_action :set_product, except: [:index]
  before_action :set_comment, only: [:show, :edit, :update, :destroy, :approve]
  before_action :admin_only, only: [:approve, :index]
  before_action :allow_new_comment, only: [:new, :create]
  before_action :allow_edit_comment, only: [:edit, :update]
  before_action :allow_delete_comment, only: [:destroy]

  # GET /comments
  # GET /comments.json
  def index
    session[:comments_index] = true
    @comments = Comment.order('updated_at DESC')
  end

  # GET /comments/1
  # GET /comments/1.json
  def show
  end

  # GET /comments/new
  def new
    @comment = Comment.new
  end

  # GET /comments/1/edit
  def edit
  end

  # POST /comments
  # POST /comments.json
  def create
    @comment = @product.comments.new(comment_params)
    @comment.user_id = current_user.id
    respond_to do |format|
      if @comment.save
        format.html { redirect_to @product, notice: t('comments.create') }  # "Comment was successfully created."
        format.json { render action: 'show', status: :created, location: @product }
      else
        format.html { render action: 'new' }
        format.json { render json: @comment.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /comments/1
  # PATCH/PUT /comments/1.json
  def update
    respond_to do |format|
      if @comment.update(comment_params)
        @comment.update_attributes(active: false)
        if session[:comments_index]
          format.html { redirect_to product_comments_path('#'), notice: t('comments.update') }  # "Comment was successfully updated."
          format.json { head :no_content }
        else
          format.html { redirect_to @product, notice: t('comments.update') }  # "Comment was successfully updated."
          format.json { head :no_content }
        end
      else
        format.html { render action: 'edit' }
        format.json { render json: @comment.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /comments/1
  # DELETE /comments/1.json
  def destroy
    @comment.destroy
    respond_to do |format|
      if session[:comments_index]
        format.html { redirect_to product_comments_path('#') }
        format.json { head :no_content }
      else
        format.html { redirect_to @product }
        format.json { head :no_content }
      end
    end
  end

  # GET /products/1/comments/1/approve
  # Action to mark a comment as approved
  def approve
    respond_to do |format|
      if @comment.update_attributes(active: true)
        format.html { redirect_to product_comments_path('#'), notice: t('comments.approve') }  # "Comment was successfully approved."
        format.json { head :no_content }
      else
        format.html { redirect_to product_comments_path('#'), notice: t('comments.approve_error') }  # "Error approving comment."
        format.json { render json: @comment.errors, status: :unprocessable_entity }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_product
      @product = Product.find(params[:product_id])
    end

    def set_comment
      @comment = @product.comments.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def comment_params
      params.require(:comment).permit(:summary, :detail, :rating, :active, :product_id)
    end
end
