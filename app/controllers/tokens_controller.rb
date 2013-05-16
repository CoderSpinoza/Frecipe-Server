class TokensController < ApplicationController
	skip_before_filter :verify_authenticity_token
	respond_to :json

	def create
		email = params[:email]
		password = params[:password]
		if email.nil? or password.nil?
			render :status => 400, :json => { :message => "Email and password cannot be blank"}
		else
			@user = User.find_by_email(email.downcase)
			if @user.nil?
				render :status => 401, :json => { :message => "Invalid email" }
			else 
				@user.ensure_authentication_token!
				if @user.valid_password?(password)
					render :status => 200, :json => { :token => @user.authentication_token, :user => @user, :profile_picture => @user.profile_picture.url }
				else
					render :status => 401, :json => { :user => @user, :message => "Invalid password"}
				end
			end
		end
	end

	def check
		@user = User.find_by_authentication_token(params[:id])

		if @user
			render :status => 200, :json => { :message => "success", :user => @user}
		else
			render :Status => 404, :json => { :message => "Invalid token"}
		end
	end

	# update profile picture
	def picture
		profile_picture = params[:picture]
		@user = User.find_by_authentication_token(params[:authentication_token])

		if profile_picture

			@user.profile_picture = profile_picture
			if @user.save
				respond_to do |format|
					format.json { render :json => [@user.profile_picture.url] }
				end
			else
				respond_to do |format|
					format.json { render :json => ["failed to update profile picture"]}
				end
			end
		else
			if @user.profile_picture
				respond_to do |format|
					format.json { render :json => {:profile_picture => @user.profile_picture.url }}
				end
			else
				respond_to do |format|
					format.json { render :json => ["No picture sent"]}
				end
			end
		end
	end

	def destroy
		@user = User.find_by_authentication_token(params[:id])
		
		if @user.nil?
			render :status => 404, :json => { :message => "Invalid token"}
		else
			@user.reset_authentication_token!
			render :status => 200, :json => { :token => params[:id]}
		end		
	end

	def show
		@user = User.find_by_authentication_token(params[:authentication_token])
		if @user.nil?
			render :status => 404, :json => { :message => params[:authentication_token]}
		else
			render :status => 200, :json => { :user => @user, :image => @user.profile_picture.url }
		end		
	end

	def profile
		user = User.find_by_authentication_token(params[:authentication_token])
		if user
			profile = User.find_by_id(params[:id])

			if profile and user != profile
				recipes = profile.recipes
				numOfLikes = 0
				following = "Follow"
				mostPopularRecipe = nil
				mostPopularRecipeLikes = 0
				@recipes = []
				for recipe in recipes
					user_ingredients_set = Set.new(user.ingredients)
		      recipe_ingredients_set = Set.new(recipe.ingredients)
		      set_difference = recipe_ingredients_set - user_ingredients_set
					@recipes << { :id => recipe.id, :recipe_name => recipe.name, :recipe_image => recipe.recipe_image.url, :user => recipe.user, :missing_ingredients => set_difference, :likes => recipe.likers.length }
					numOfLikes += recipe.likers.count
					if mostPopularRecipe == nil or mostPopularRecipe.likers.count < recipe.likers.count
						mostPopularRecipe = recipe
						mostPopularRecipeLikes = mostPopularRecipe.likers.count
					end
				end

				if profile.followers.include? user
					following = "Following"
				end
				respond_to do |format|
					format.json { render :json => { :user => profile, :profile_image => profile.profile_picture.url, :recipes => @recipes, :followers => profile.followers, :likes => numOfLikes, :most => mostPopularRecipe, :mostLikes => mostPopularRecipeLikes, :follow => following, :rating => profile.average_rating, :liked => profile.liked, :following => profile.following }}
				end

			else
				recipes = user.recipes
				numOfLikes = 0
				following = "You"
				mostPopularRecipe = nil
				mostPopularRecipeLikes = 0
				@recipes = []
				for recipe in recipes
					user_ingredients_set = Set.new(user.ingredients)
		      recipe_ingredients_set = Set.new(recipe.ingredients)
		      set_difference = recipe_ingredients_set - user_ingredients_set
					@recipes << { :id => recipe.id, :recipe_name => recipe.name, :recipe_image => recipe.recipe_image.url, :user => recipe.user, :missing_ingredients => set_difference, :likes => recipe.likers.length }
					numOfLikes += recipe.likers.count
					if mostPopularRecipe == nil or mostPopularRecipe.likers.count < recipe.likers.count
						mostPopularRecipe = recipe
						mostPopularRecipeLikes = mostPopularRecipe.likers.count
					end
				end
				respond_to do |format|
					format.json { render :json => { :user => user, :profile_image => user.profile_picture.url, :recipes => @recipes, :followers => user.followers, :likes => numOfLikes, :most => mostPopularRecipe, :mostLikes => mostPopularRecipeLikes, :follow => following, :rating => user.average_rating, :liked => user.liked, :following => user.following }}
				end
			end
		else

			respond_to do |format|
				format.json { render :json => { :message => "Invalid authentication token"}}
			end
		end

	end

	def facebook_check

		email = params[:email]
		uid = params[:uid]

		@user = User.find_by_provider_and_uid("facebook", uid)

		respond_to do |format|
			if @user
				format.json { render :json => { :message => "currently registered user", :user => @user, :profile_picture => @user.profile_picture.url, :token => @user.authentication_token }}
			else
				@email_user = User.find_by_email(email)
				if @email_user
					@email_user.provider = "facebook"
					@email_user.uid = uid

					if @email_user.save
						format.json { render :json => { :message => "currently registered email", :user => @email_user, :profile_picture => @user.profile_picture.url, :token => @email_user.authentication_token}}
					else
					format.json { render :json => { :message => "There was an error registering"}}
					end
				else
					format.json { render :json => { :message => "needs signup"}}
				end
				
			end
		end
	end

	def facebookAccounts
		users = User.all

		@uids = []

		for user in users
			if user.provider == "facebook" and user.uid
				@uids << user.uid
			end
		end

		respond_to do |format|
			format.json { render :json => @uids }
		end
	end

	def search
    user = User.find_by_authentication_token(params[:authentication_token])
    string = params[:search]
    respond_to do |format|
      if user
        recipes = Recipe.where("name ILIKE ?", string.downcase + "%")
        first = User.where("first_name ILIKE ?", string.downcase + "%")
        last = User.where("last_name ILIKE ?", string.downcase + "%")
        users = first + last

        @recipes = []
        @users = []

        for recipe in recipes
        	@recipes << { :id => recipe.id, :name => recipe.name, :recipe_image => recipe.recipe_image.url }
        end

        for user in users
        	@users << { :id => user.id, :first_name => user.first_name, :last_name => user.last_name, :profile_picture => user.profile_picture.url, :provider => user.provider, :uid => user.uid }
        end

        format.json { render :json => { :message => "success", :recipes => @recipes, :users => @users }}
      else
        format.json { render :json => { :message => "Invalid authentication token"}, :status => 404 }
      end
    end
  end


end
