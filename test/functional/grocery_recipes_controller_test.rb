require 'test_helper'

class GroceryRecipesControllerTest < ActionController::TestCase
  setup do
    @grocery_recipe = grocery_recipes(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:grocery_recipes)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create grocery_recipe" do
    assert_difference('GroceryRecipe.count') do
      post :create, grocery_recipe: {  }
    end

    assert_redirected_to grocery_recipe_path(assigns(:grocery_recipe))
  end

  test "should show grocery_recipe" do
    get :show, id: @grocery_recipe
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @grocery_recipe
    assert_response :success
  end

  test "should update grocery_recipe" do
    put :update, id: @grocery_recipe, grocery_recipe: {  }
    assert_redirected_to grocery_recipe_path(assigns(:grocery_recipe))
  end

  test "should destroy grocery_recipe" do
    assert_difference('GroceryRecipe.count', -1) do
      delete :destroy, id: @grocery_recipe
    end

    assert_redirected_to grocery_recipes_path
  end
end
