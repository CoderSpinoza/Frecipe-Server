class GroceriesController < ApplicationController
  # GET /groceries
  # GET /groceries.json
  def index
    @groceries = Grocery.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @groceries }
    end
  end

  # GET /groceries/1
  # GET /groceries/1.json
  def show
    @grocery = Grocery.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @grocery }
    end
  end

  # GET /groceries/new
  # GET /groceries/new.json
  def new
    @grocery = Grocery.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @grocery }
    end
  end

  # GET /groceries/1/edit
  def edit
    @grocery = Grocery.find(params[:id])
  end

  # POST /groceries
  # POST /groceries.json
  def create
    user = UserSession.user_by_authentication_token(params[:authentication_token])
    
    if params[:recipe_id]
      groceryRecipe = GroceryRecipe.find_or_create_by_user_id_and_recipe_id(user.id, params[:recipe_id])
      @groceries = []

      if params[:groceries]
        names = params[:groceries].split(',')
        in_fridge = params[:in_fridge].split(',')
        # for name in names
        #   ingredient = Ingredient.find_or_create_by_name(name.downcase.titleize)
        #   grocery = Grocery.new(:grocery_recipe => groceryRecipe, :ingredient => ingredient)
        #   if grocery.save
        #     @groceries << grocery
        #   end
        # end
        names.zip(in_fridge) { |element|
          ingredient = Ingredient.find_or_create_by_name(element[0].downcase.titleize)
          grocery = Grocery.find_or_create_by_grocery_recipe_id_and_ingredient_id(groceryRecipe.id, ingredient.id)
          grocery.fridge = element[1].to_i
          if grocery.save
            @groceries << grocery
          end
        }
      end
    else
      @groceries = []
      if params[:groceries]
        names = params[:groceries].split(',')
        for name in names
          ingredient = Ingredient.find_or_create_by_name(name.downcase.titleize)
          grocery_recipe = GroceryRecipe.find_or create_by_user_id_and_recipe_id(user.id, 0)
          if grocery_recipe
            grocery = Grocery.new(:grocery_recipe_id => grocery_recipe.id, :ingredient => ingredient)
            if grocery.save
              @groceries << grocery
            end
          end
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

  # PUT /groceries/1
  # PUT /groceries/1.json
  def update
    @grocery = Grocery.find(params[:id])

    respond_to do |format|
      if @grocery.update_attributes(params[:grocery])
        format.html { redirect_to @grocery, notice: 'Grocery was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @grocery.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /groceries/1
  # DELETE /groceries/1.json
  def destroy
    @grocery = Grocery.find(params[:id])
    @grocery.destroy

    respond_to do |format|
      format.html { redirect_to groceries_url }
      format.json { head :no_content }
    end
  end

  def list

    user = UserSession.user_by_authentication_token(params[:authentication_token])
    
    respond_to do |format|
      if user
        format.json { render :json => { :message => "success", :grocery_list => user.grocery_list }}
      else
        format.json { render :json => { :message => "Invalide authentication token"}, :status => 404 }
      end
    end
  end

  def multiple_delete
    user = UserSession.user_by_authentication_token(params[:authentication_token])
    respond_to do |format|
      if user
        ingredients_array = params[:ids]
        if ingredients_array
          for grocery_recipe in user.grocery_recipes
            grocery_recipe.groceries.each { |grocery| 
              if ingredients_array.include? grocery.ingredient_id.to_s
                grocery.active = 0; grocery.save!
              end 
            }
            if grocery_recipe.recipe_id == 0
              grocery_recipe.ingredients.destroy_all
            end
          end
        end
        format.json { render :json => { :message => "success", :grocery_list => user.grocery_list }}
      else
        format.json { render :json => { :message => "Invalid authentication token"}}
      end
    end
  end

  def fridge
    user = UserSession.user_by_authentication_token(params[:authentication_token])
    respond_to do |format|
      if user
        ingredients_array = params[:ids]
        @groceries_array = []
        @fridge_array = []
        if ingredients_array          
          for grocery_recipe in user.grocery_recipes
            grocery_recipe.groceries.where(:ingredient_id => ingredients_array).each { |grocery| grocery.fridge = 0; grocery.save! }
          end
          fridge_array = ingredients_array.map { |x| { :user_id => user.id, :ingredient_id => x}}.compact
          @fridge_array = UserIngredient.create(fridge_array)
        end
        format.json { render :json => { :message => "success", :grocery_list => user.grocery_list }}
      else
        format.json { render :json => { :message => "Invalid authentication token"}}
      end
    end
  end

  def recover
    user = UserSession.user_by_authentication_token(params[:authentication_token])
    respond_to do |format|
      if user
        grocery = Grocery.find_by_id(params[:grocery_id])
        if grocery
          grocery.active = 1; grocery.save!
        end
        format.json { render :json => { :message => "success", :grocery_list => user.grocery_list }}
      else
        format.json { render :json => { :message => "Invalid authentication token"}, :status => 404 }
      end
    end
  end
end
