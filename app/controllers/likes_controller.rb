class LikesController < ApplicationController
  # GET /likes
  # GET /likes.json
  def index
    @likes = Like.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @likes }
    end
  end

  # GET /likes/1
  # GET /likes/1.json
  def show
    @like = Like.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @like }
    end
  end

  # GET /likes/new
  # GET /likes/new.json
  def new
    @like = Like.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @like }
    end
  end

  # GET /likes/1/edit
  def edit
    @like = Like.find(params[:id])
  end

  # POST /likes
  # POST /likes.json
  def create
    # @like = Like.new(params[:like])

    # respond_to do |format|
    #   if @like.save
    #     format.html { redirect_to @like, notice: 'Like was successfully created.' }
    #     format.json { render json: @like, status: :created, location: @like }
    #   else
    #     format.html { render action: "new" }
    #     format.json { render json: @like.errors, status: :unprocessable_entity }
    #   end
    # end
    user = UserSession.user_by_authentication_token(params[:authentication_token])
    recipe = Recipe.find(params[:id])
    @exists = Like.where(:user_id => user, :recipe_id => recipe.id)
    if @exists.empty?
      @like = Like.new(:user=> user, :recipe => recipe)


      respond_to do |format|

        if @like.save
          if user != recipe.user
            recipe.likes_count += 1
            recipe.save
            Notification.create(:source => user, :target => recipe.user, :recipe => recipe, :category => "like", :seen => 0)
          end
          format.json { render :json => { :likes => recipe.likers.count, :message => "like" }}
        else
          format.json { render :json => @like.errors, :status => :unprocessable_entity}
        end

      end
    else
      @exists[0].destroy
      recipe.likes_count -= 1
      recipe.save
      respond_to do |format|
        format.json { render :json => { :likes => recipe.likers.count, :message => "unlike"}}
      end
    end

  end

  # PUT /likes/1
  # PUT /likes/1.json
  def update
    @like = Like.find(params[:id])

    respond_to do |format|
      if @like.update_attributes(params[:like])
        format.html { redirect_to @like, notice: 'Like was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @like.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /likes/1
  # DELETE /likes/1.json
  def destroy
    @like = Like.find(params[:id])
    @like.destroy

    respond_to do |format|
      format.html { redirect_to likes_url }
      format.json { head :no_content }
    end
  end
end
