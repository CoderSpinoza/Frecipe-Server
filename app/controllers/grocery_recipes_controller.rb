class GroceryRecipesController < ApplicationController
  # GET /grocery_recipes
  # GET /grocery_recipes.json
  def index
    @grocery_recipes = GroceryRecipe.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @grocery_recipes }
    end
  end

  # GET /grocery_recipes/1
  # GET /grocery_recipes/1.json
  def show
    @grocery_recipe = GroceryRecipe.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @grocery_recipe }
    end
  end

  # GET /grocery_recipes/new
  # GET /grocery_recipes/new.json
  def new
    @grocery_recipe = GroceryRecipe.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @grocery_recipe }
    end
  end

  # GET /grocery_recipes/1/edit
  def edit
    @grocery_recipe = GroceryRecipe.find(params[:id])
  end

  # POST /grocery_recipes
  # POST /grocery_recipes.json
  def create
    user = UserSession.user_by_authentication_token(params[:authentication_token])
    groceryRecipe = GroceryRecipe.find_or_create_by_user_id_and_recipe_id(user.id, params[:recipe_id])
    groceryRecipe.recipe_groceries.destroy_all
    @groceries = []

    if params[:groceries]
      names = params[:groceries].split(',')
      for name in names
        ingredient = Ingredient.find_or_create_by_name(name.downcase.titleize)
        grocery = RecipeGrocery.new(:grocery_recipe => groceryRecipe, :ingredient => ingredient)
        if grocery.save
          @groceries << grocery
        end
      end
    end
    respond_to do |format|
      if @groceries.length > 0
        format.json { render :json => { :groceries => @groceries}}
      else
        format.json { render :json => { :message => "Nothing to add"}}
      end
    end
  end

  # PUT /grocery_recipes/1
  # PUT /grocery_recipes/1.json
  def update
    @grocery_recipe = GroceryRecipe.find(params[:id])

    respond_to do |format|
      if @grocery_recipe.update_attributes(params[:grocery_recipe])
        format.html { redirect_to @grocery_recipe, notice: 'Grocery recipe was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @grocery_recipe.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /grocery_recipes/1
  # DELETE /grocery_recipes/1.json
  def destroy
    user = UserSession.user_by_authentication_token(params[:authentication_token])
    @grocery_recipe = GroceryRecipe.find(params[:id])

    message = "failure"
    if user == @grocery_recipe.user
      @grocery_recipe.destroy
      message =  "success"
    end
    
    respond_to do |format|
      format.json { render :json => { :message => message, :grocery_list => user.grocery_list }}
    end
  end

  # custom methods
  def multiple_delete
    user = UserSession.user_by_authentication_token(params[:authentication_token])
    respond_to do |format|
      if user
        ids = params[:ids]
        if ids
          user.grocery_recipes.where(:id => ids).destroy_all
          format.json { render :json => { :message => "succcess", :grocery_list => user.grocery_list }}
        end

      else
        format.json { render :json => { :message => "failure"}, :status => 404}
      end
    end 

  end
end
