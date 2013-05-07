Frecipe::Application.routes.draw do

  post 'notifications/user' => "notifications#user"
  resources :notifications


  resources :comments

  match 'groceries/list' => "groceries#list"
  match 'groceries/multiple_delete' => "groceries#multiple_delete"
  post 'groceries/fridge' => "groceries#fridge"
  resources :groceries

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


  match 'tokens/picture' => "tokens#picture"
  match 'tokens/show' => "tokens#show"
  match 'tokens/profile' => "tokens#profile"
  match 'tokens/detail' => "tokens#detail"
  get 'tokens/facebookAccounts' => "tokens#facebookAccounts"
  get 'tokens/:id' => "tokens#check"
  match 'tokens/facebook_check' => "tokens#facebook_check"
  
  resources :tokens, :only => [:create, :destroy]


  
  # match 'users/remember' => "sessions#remember"
  root :to => "home#index"
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
