class CommentsController < ApplicationController
  # GET /comments
  # GET /comments.json
  def index
    @comments = Comment.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @comments }
    end
  end

  # GET /comments/1
  # GET /comments/1.json
  def show
    recipe = Recipe.find_by_id(params[:id])

    respond_to do |format|
      if recipe
        @comments = []
        comments = recipe.comments
        for comment in comments
          comment_user = comment.user
          @comments << { :user => comment_user, :profile_picture => comment_user.profile_picture.url, :comment => comment }
        end

        format.json { render :json => @comments }
      else
        format.json { render :status => 404, :json => { :message => "No such Recipe"}}
      end
    end
  end

  # GET /comments/new
  # GET /comments/new.json
  def new
    @comment = Comment.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @comment }
    end
  end

  # GET /comments/1/edit
  def edit
    @comment = Comment.find(params[:id])
  end

  # POST /comments
  # POST /comments.json
  def create
    user = User.find_by_authentication_token(params[:authentication_token])
    respond_to do |format|
      if user
        @comment = Comment.new(:user_id => user.id, :recipe_id => params[:recipe_id], :text => params[:text])
          
          if @comment.save
            recipe = Recipe.find_by_id([params[:recipe_id]])
            @comments = []
            comments = recipe.comments
            for comment in comments
              comment_user = comment.user
              @comments << { :user => comment_user, :profile_picture => comment_user.profile_picture.url, :comment => comment }
            end
            format.json { render :json => { :comments => @comments, :message => "success"} }
          else
            format.json { render :status => 500, :json => { :message => "There was an error uploading your comment." }}
          end
      else
        format.json { render :json => { :message => "Invalid authentication token"}} 
      end
    end
  end

  # PUT /comments/1
  # PUT /comments/1.json
  def update
    @comment = Comment.find(params[:id])

    respond_to do |format|
      if @comment.update_attributes(params[:comment])
        format.html { redirect_to @comment, notice: 'Comment was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @comment.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /comments/1
  # DELETE /comments/1.json
  def destroy
    @user = User.find_by_authentication_token(params[:authentication_token])
    @recipe = Recipe.find_by_id(params[:recipe_id])

    @comment = Comment.find_by_id(params[:id])

    respond_to do |format|
      if @comment.user == @user and @recipe
        @comment.destroy
        format.json { render :json => { :comments => @recipe.comments, :message => "success" }}
      else
        format.json { render :json => { :message => "failure"}}
      end  
    end
  end
end
