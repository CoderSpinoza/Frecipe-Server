class RecipesController < ApplicationController
  before_filter :authenticate_user!, :only => [:show, :new, :edit]
  layout "frecipe"
  # GET /recipes
  # GET /recipes.json
  def index
    # @recipes = Recipe.all

    # cached_recipes = Rails.cache.read('all_recipes')

    # if cached_recipes
    #   @recipes = cached_recipes
    #   respond_to do |format|
    #     format.html #index.html.erb
    #     format.json { render json: @recipes}
    #   end
    # else
      @recipes = []
      # @recipes = Recipe.includes(:user, :ingredients, :likers)
      # recipes.each do |recipe|
      #   @recipes << { :id => recipe.id, :recipe_name => recipe.name, :recipe_image => recipe.recipe_image.url, :user => recipe.user, :likes => recipe.likers.count, :ingredients => recipe.ingredients }
      # end
      user = UserSession.user_by_authentication_token(params[:authentication_token])
      @recipes = Recipe.fetch_all
      # Rails.cache.write('all_recipes', @recipes)
      respond_to do |format|
        format.html # index.html.erb
        format.json { render :json => { :recipes => @recipes, :ingredients => user.ingredients.select('name').map { |ingredient| ingredient.name } } }
      end
    end
    
  # end

  # GET /recipes/1
  # GET /recipes/1.json
  def show
    @recipe = Recipe.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @recipe }
    end
  end

  # GET /recipes/new
  # GET /recipes/new.json
  def new
    @recipe = Recipe.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @recipe }
    end
  end

  # GET /recipes/1/edit
  def edit
    @recipe = Recipe.find(params[:id])
  end

  # POST /recipes
  # POST /recipes.json
  def create

    @session = UserSession.find_by_authentication_token(params[:authentication_token])
    @user = @session.user
    @recipe = Recipe.new(:name => params[:recipe_name].downcase.titleize)
    ingredients = params[:ingredients].split(',')
    directions = params[:steps]
    @recipe.recipe_image = params[:recipe_image]
    @recipe.user = @user
    @recipe.ingredients_string = params[:ingredients]
    for ingredient in ingredients
      temp = Ingredient.find_or_create_by_name(ingredient.downcase.titleize)
      @recipe.ingredients << temp
    end

    if directions
      @recipe.steps = directions
    end

    respond_to do |format|
      if @recipe.save
        @user.give_points(80)
        @user.upload_notification(@recipe)
        format.json { render :json => @recipe.ingredients }
      else
        format.json { render json: @recipe.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /recipes/1
  # PUT /recipes/1.json
  def update
    session = UserSession.find_by_authentication_token(params[:authentication_token])
    user = session.user
    respond_to do |format|
      if user
        @recipe = Recipe.find_by_id(params[:recipe_id])
        ingredients = params[:ingredients].split(',')
        steps = params[:steps]
        @recipe.name = params[:recipe_name].downcase.titleize
        @recipe.recipe_image = params[:recipe_image]
        @recipe.ingredients_string = params[:ingredients]
        @recipe.ingredients = []
        for ingredient in ingredients
          temp = Ingredient.find_or_create_by_name(ingredient.downcase.titleize)
          @recipe.ingredients << temp
        end

        if steps
          @recipe.steps = steps
        end

        if @recipe.save
          format.json { render :json => @recipe }
        else
          format.json { render :json => { :message => "There was an error updating"}}
        end
      format.json { render :json => { :message => "Invalid authentication token" }}
      else
        format.json { render :json => { :message => "Invalid authentication token" }}
      end
    end


  end

  # DELETE /recipes/1
  # DELETE /recipes/1.json
  def destroy
    @recipe = Recipe.find_by_id(params[:id])
    session = UserSession.find_by_authentication_token(params[:authentication_token])
    user = session.user
    respond_to do |format|
      if user
        if @recipe
          @recipe.destroy
          user.give_points(-80)
        end
        # format.html { redirect_to recipes_url }
        format.json { render :json => { :message => "success"}}
      else
        format.json { render :json => { :message => "Invalid authentication token" }}
      end
    end
  end

  # custom methods

  def user
    session = UserSession.find_by_authentication_token(params[:authentication_token])
    user = session.user
    recipes = user.recipes

    json = []
    for recipe in recipes
      user_ingredients_set = Set.new(user.ingredients)
      recipe_ingredients_set = Set.new(recipe.ingredients)
      set_difference = recipe_ingredients_set - user_ingredients_set
      json << { :id => recipe.id, :recipe_name => recipe.name, :recipe_image => recipe.recipe_image.url, :missing_ingredients => set_difference, :user => recipe.user, :likes => recipe.likers.length, :uid => recipe.user.uid, :provider => recipe.user.provider }
    end

    respond_to do |format|
      format.json { render :json => json }
    end
  end

  def possible

    session = UserSession.find_by_authentication_token(params[:authentication_token])
    user = session.user
    json = []

    user_ingredients_set = Set.new(user.ingredients)

    Recipe.find_each do |recipe|
      recipe_ingredients_set = Set.new(recipe.ingredients)
      set_difference = recipe_ingredients_set - user_ingredients_set
      # if set_difference.length <= 2
      json << { :id => recipe.id, :recipe_name => recipe.name, :recipe_image => recipe.recipe_image.url, :missing_ingredients => set_difference, :user => recipe.user, :missing => set_difference.length, :likes => recipe.likers.length, :uid => recipe.user.uid, :provider => recipe.user.provider, :ingredients => recipe.ingredients }
    end

    json = json.sort_by! { |k| k[:missing]}
    respond_to do |format|
      format.json { render :json => json}
    end
  end

  def detail
    recipe = Recipe.find(params[:id])
    session = UserSession.find_by_authentication_token(params[:authentication_token])
    user = session.user

    isOwner = 0
    if recipe.user == user
      isOwner = 1
    end

    @comments = recipe.fetch_comments

    user_rating = user.rate_value(recipe)

    set_difference = Set.new(recipe.ingredients) - Set.new(user.ingredients)
    @recipe = { :recipe => recipe, :user => recipe.user, :user_image => recipe.user.profile_picture.url, :recipe_image => recipe.recipe_image.url, :ingredients => recipe.ingredients, :missing_ingredients => set_difference, :liked => user.liked?(recipe.id), :likes => recipe.likers.count, :followers => recipe.user.followers.count, :isOwner => isOwner, :comments => @comments, :steps => recipe.steps, :rating => recipe.reputation_for(:rating), :user_rating => user_rating }
    respond_to do |format|
      format.json { render :json => @recipe }
    end
  end

  def rate
    session = UserSession.find_by_authentication_token(params[:authentication_token])
    user = session.user

    respond_to do |format|
      if user
        rating = params[:rating]
        @recipe = Recipe.find_by_id(params[:id])
        if @recipe
          @recipe.add_or_update_evaluation(:rating, rating, user)
          format.json { render :json =>  { :message => "success", :rating => @recipe.reputation_for(:rating) }}
        else
          format.json { render :json => { :message => "No such recipe"}}
        end
      else
        format.json { render :json => { :message => "Invalid authentication token"}}
      end
    end
  end
end
