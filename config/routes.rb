Frecipe::Application.routes.draw do

  resources :events


  get "metrics" => "metrics#index"
  get "metrics/show"

  # metrics page
  resources :feedbacks
  resources :rankings do
    collection do
      get 'facebook'
    end
  end

  resources :grocery_recipes do
    collection do
      post 'multiple_delete'
    end
  end
  devise_for :user_sessions

  resources :notifications do
    collection do
      post 'user'
      post 'check'
    end
  end

  resources :comments

  match 'groceries/list' => "groceries#list"
  match 'groceries/multiple_delete' => "groceries#multiple_delete"
  resources :groceries do 
    collection do
      post 'fridge'
      post 'recover'
    end
  end

  resources :likes

  resources :follows

  resources :user_ingredients
  match 'user_ingredients/multiple_delete' => "user_ingredients#multiple_delete"
  resources :recipe_ingredients

  match 'recipes/user' => "recipes#user"
  match 'recipes/detail' => "recipes#detail"
  match 'recipes/possible' => "recipes#possible"
  post 'recipes/rate' => "recipes#rate"
  resources :recipes

  resources :ingredients


  # match 'users/auth/:provider/callback', to: "omniauth#create"
  match 'users/auth/failure', to: redirect('/')
  devise_for :users, :controllers => { :registrations => "registrations" }


  # match 'tokens/picture' => "tokens#picture"
  match 'tokens/show' => "tokens#show"
  match 'tokens/detail' => "tokens#detail"

  resources :tokens do
    collection do
      post 'profile'
      post 'reset'
      post 'password'
      post 'facebook_check'
      put 'update'
      post 'picture'
      get 'facebookAccounts'
      get 'search'
      get 'liked/:id' => "tokens#liked"
      get 'likes/:id' => "tokens#likes"
      get 'followers/:id' => "tokens#followers"
      get 'following/:id' => "tokens#following"
      get 'tokens/:id' => "tokens#check"

    end
  end


  
  # match 'users/remember' => "sessions#remember"
  root :to => "user_sessions#index"
  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
