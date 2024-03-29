class UserIngredientsController < ApplicationController
  # GET /user_ingredients
  # GET /user_ingredients.json
  def index
    @user_ingredients = UserIngredient.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @user_ingredients }
    end
  end

  # GET /user_ingredients/1
  # GET /user_ingredients/1.json
  def show
    # @user_ingredient = UserIngredient.find(params[:id])

    # respond_to do |format|
    #   format.html # show.html.erb
    #   format.json { render json: @user_ingredient }
    # end
    user = UserSession.user_by_authentication_token(params[:id])
    @ingredients = user.ingredients.map { |ingredient| { :id => ingredient.id, :name => ingredient.name, :image => ingredient.image.url }}.compact
    
    respond_to do |format|
      format.json { render :json => @ingredients }
    end
  end

  # GET /user_ingredients/new
  # GET /user_ingredients/new.json
  def new
    @user_ingredient = UserIngredient.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @user_ingredient }
    end
  end

  # GET /user_ingredients/1/edit
  def edit
    @user_ingredient = UserIngredient.find(params[:id])
  end

  # POST /user_ingredients
  # POST /user_ingredients.json
  def create

    user = UserSession.user_by_authentication_token(params[:id])
    names = params[:ingredients].split(",")
    @user_ingredients = []
    for name in names
      name = name.strip
      ingredient = Ingredient.find_or_create_by_name(name.downcase.titleize)
      user_ingredient =UserIngredient.new(:user_id => user.id, :ingredient_id => ingredient.id )

      if user_ingredient.save
        @user_ingredients << user_ingredient
        grocery_recipes = user.grocery_recipes
        for grocery_recipe in grocery_recipes
          grocery_recipe.groceries.each { |grocery|
            if grocery.ingredient_id == ingredient.id
              grocery.fridge = 0; grocery.save!
            end
          }
        end
      end
    end
    respond_to do |format|
      format.json { render :json => @user_ingredients }
    end

  end

  # PUT /user_ingredients/1
  # PUT /user_ingredients/1.json
  def update
    @user_ingredient = UserIngredient.find(params[:id])

    respond_to do |format|
      if @user_ingredient.update_attributes(params[:user_ingredient])
        format.html { redirect_to @user_ingredient, notice: 'User ingredient was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @user_ingredient.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /user_ingredients/1
  # DELETE /user_ingredients/1.json
  def destroy
    # if UserIngredient.where(:id => params[:id])
    #   @user_ingredient = UserIngredient.find(params[:id])
    #   @user_ingredient.destroy

    #   respond_to do |format|
    #     format.json { render :json => @user_ingredient }
    #   end
    # else
    #   respond_to do |format|
    #     format.json { render :json => ["failure"]}
    #   end
    # end
    user = UserSession.user_by_authentication_token(params[:authentication_token])

    if @user_ingredient = UserIngredient.where(:user_id => user.id, :ingredient_id => params[:id])
      @user_ingredient[0].destroy
    end
    respond_to do |format|
      format.json { render :json => @user_ingredient }
    end
  end

  # custom methods

  def multiple_delete
    user = UserSession.user_by_authentication_token(params[:authentication_token])
    ingredient_array = params[:ids]
    @output_array = []
    if ingredient_array
      for i in ingredient_array
        if user_ingredient = UserIngredient.where(:user_id => user.id, :ingredient_id => i)
          user_ingredient[0].destroy
          @output_array << user_ingredient[0]
        end
      end
    end
    user.grocery_recipes.each { |gr|
      gr.groceries.each { |grocery|
        if ingredient_array.include? grocery.ingredient_id.to_s
          grocery.fridge = 1
          grocery.save!
        else
          # grocery.fridge = 1
          # grocery.save!
        end
        
      }
    }
    respond_to do |format|
      format.json { render :json => ingredient_array }
    end
  end
end
