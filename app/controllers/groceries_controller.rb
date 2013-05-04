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
    user = User.find_by_authentication_token(params[:authentication_token])
    names = params[:groceries].split(',')
    @groceries = []
    for name in names
      ingredient = Ingredient.find_or_create_by_name(name.downcase.titleize)
      grocery = Grocery.new(:user => user, :ingredient => ingredient)
      if grocery.save
        @groceries << grocery
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

    user = User.find_by_authentication_token(params[:authentication_token])
    respond_to do |format|
      if user
        format.json { render :json => user.groceries }
      else
        format.json { render :json => { :message => "Invalide authentication token"}}
      end
    end
  end

  def multiple_delete
    user = User.find_by_authentication_token(params[:authentication_token])
    respond_to do |format|
      if user
        ingredients_array = params[:ids]
        @output_array = []
        if ingredients_array
          for i in ingredients_array
            if grocery = Grocery.find_by_user_id_and_ingredient_id(user.id, i)
              grocery.destroy
              @output_array << grocery
            end
          end
        end
        format.json { render :json => { :message => "success", :groceries => @output_array }}
      else
        format.json { render :json => { :message => "Invalid authentication token"}}
      end
    end
  end

  def fridge
    user = User.find_by_authentication_token(params[:authentication_token])
    respond_to do |format|
      if user
        ingredients_array = params[:ids]
        @groceries_array = []
        @fridge_array = []
        if ingredients_array
          for i in ingredients_array
            if grocery = Grocery.find_by_user_id_and_ingredient_id(user.id, i)
              grocery.destroy
              user_ingredient = UserIngredient.new(:user_id => user.id, :ingredient_id => i)

              if user_ingredient.save
                @fridge_array << Ingredient.find_by_id(i)
              end
              @groceries_array << Ingredient.find_by_id(i)
            end
          end
        end
        format.json { render :json => { :message => "success", :groceries => @groceries_array, :fridge => @fridge_array }}
      else
        format.json { render :json => { :message => "Invalid authentication token"}}
      end
    end
  end
end
