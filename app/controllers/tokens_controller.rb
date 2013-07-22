class TokensController < ApplicationController
	skip_before_filter :verify_authenticity_token
	respond_to :json

	def create
		email = params[:email]
		password = params[:password]
		if email.nil? or password.nil?
			render :status => 400, :json => { :message => "Email and password cannot be blank."}
		else
			@user = User.find_by_email(email.downcase)
			if @user.nil?
				render :status => 401, :json => { :message => "You have entered a wrong email or password." }
			else 
				if @user.valid_password?(password)
					@session = UserSession.new(:user => @user)
					if @session.save
						@session.ensure_authentication_token!
						render :status => 200, :json => { :token => @session.authentication_token, :user => @user, :profile_picture => @user.profile_picture.url }
					else
						render :status => 401, :json => { :user => @user, :message => "session creation failed"}
					end
				else
					render :status => 401, :json => { :user => @user, :message => "You have entered a wrong email or password."}
				end
			end
		end
	end

	def check
		@user = UserSession.find_by_authentication_token(params[:id])
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
					format.json { render :json => { :profile_picture => @user.profile_picture.url, :message => "success"} }
				end
			else
				respond_to do |format|
					format.json { render :json => ["failed to update profile picture"], :status => 401 }
				end
			end
		else
			respond_to do |format|
				format.json { render :json => ["No picture sent"], :status => 404 }
			end
		end
	end

	def destroy
		@user = UserSession.find_by_authentication_token(params[:id])
		
		if @user.nil?
			render :status => 404, :json => { :message => "Invalid token"}
		else
			@user.reset_authentication_token!
			render :status => 200, :json => { :token => params[:id]}
		end		
	end

	def show
		@session = UserSession.find_by_authentication_token(params[:authentication_token])
		if @user.nil?
			render :status => 404, :json => { :message => params[:authentication_token]}
		else
			@user = @session.user
			render :status => 200, :json => { :user => @user, :image => @user.profile_picture.url }
		end		
	end

	def profile
		session = UserSession.find_by_authentication_token(params[:authentication_token])
		user = session.user
		if user
			profile = User.find_by_id(params[:id])

			if profile and user != profile
				numOfLikes = profile.recipes.to_a.sum(&:likes_count)
				following = "Follow"
				mostPopularRecipe = profile.recipes.order('likes_count DESC').limit(1)

				@recipes = Recipe.fetch_with_user(profile)
				if profile.followers.include? user
					following = "Following"
				end
				respond_to do |format|
					# format.json { render :json => { :user => profile, :ingredients => profile.ingredients.map { |ingredient| ingredient.name }, :profile_image => profile.profile_picture.url, :recipes => @recipes}}
					format.json { render :json => { :user => profile, :ingredients => profile.ingredients.map { |ingredient| ingredient.name }, :profile_image => profile.profile_picture.url, :recipes => @recipes, :followers => profile.followers, :likes => numOfLikes, :most => mostPopularRecipe, :follow => following, :rating => profile.reputation_for(:average_rating), :liked => profile.liked, :following => profile.following }}
				end
			else
				numOfLikes = user.recipes.to_a.sum(&:likes_count)
				following = "You"
				mostPopularRecipe = user.recipes.order('likes_count DESC').limit(1)

				@recipes = Recipe.fetch_with_user(user)
				respond_to do |format|
					format.json { render :json => { :user => user, :ingredients => user.ingredients.map { |ingredient| ingredient.name }, :profile_image => user.profile_picture.url, :recipes => @recipes, :followers => user.followers, :likes => numOfLikes, :most => mostPopularRecipe, :follow => following, :rating => user.reputation_for(:average_rating), :liked => user.liked, :following => user.following }}
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
				@session = UserSession.create(:user => @user)
				@session.ensure_authentication_token!
				format.json { render :json => { :message => "currently registered user", :user => @user, :profile_picture => @user.profile_picture.url, :token => @session.authentication_token }}
			else
				@email_user = User.find_by_email(email)
				if @email_user
					@email_user.provider = "facebook"
					@email_user.uid = uid

					if @email_user.save
						@session = UserSession.create(:user => @email_user)
						@session.ensure_authentication_token!
						format.json { render :json => { :message => "currently registered email", :user => @email_user, :profile_picture => @user.profile_picture.url, :token => @session.authentication_token}}
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
		@uids = User.where(:provider => "facebook").map { |user| user.uid }

		respond_to do |format|
			format.json { render :json => @uids }
		end
	end

	def search
    session = UserSession.find_by_authentication_token(params[:authentication_token])
    user = session.user
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

  def update
  	user = UserSession.user_by_authentication_token(params[:authentication_token])
  	respond_to do |format|
  		if user
  			user.first_name = params[:first_name].strip.titleize
  			user.last_name = params[:last_name].strip.titleize
  			user.about = params[:about].strip
  			user.website = params[:website].strip

  			if params[:image]
  				user.profile_picture = params[:image]
  			end
  			user.save!

  			format.json { render :json => { :message => "success", :user => user, :profile_picture => user.profile_picture.url}}
  		else
  			format.json { render :json => {:message => "Invalid authentication token"}, :status => 404}
  		end
  	end
  end

  def reset
  	@user = User.find_by_email(params[:email])
  	respond_to do |format|
	  	if @user
	  		@user.send_reset_password_instructions
	  		format.json { render :json => { :message => "success"}}
	  	else
	  		format.json { render :json => { :message => "failure"}, :status => 404 }
	  	end
	  end
  end

  def password
  	user = UserSession.user_by_authentication_token(params[:authentication_token])
  	respond_to do |format|
  		if user
  			if user.valid_password?(params[:current_password])
	  			user.password = params[:new_password]
	  			if user.save!
	  				format.json { render :json => { :message => "success"}}
	  			else
	  				format.json { render :json => { :message => "failure"}, :status => 503 }
	  			end
	  		else
	  			format.json { render :json => { :message => "Wrong password!"}, :status => 404}
	  		end
  		else
  			format.json { render :json => { :message => "Invalid authentication token"}, :status => 404 }
  		end
  	end
  end

  def liked
  	user = UserSession.user_by_authentication_token(params[:authentication_token])
  	respond_to do |format|
			target = User.find_by_id(params[:id])
			@recipes = []
			target.liked.each { |recipe|
				user_ingredients_set = Set.new(user.ingredients)
	      recipe_ingredients_set = Set.new(recipe.ingredients)
	      set_difference = recipe_ingredients_set - user_ingredients_set
				@recipes << { :id => recipe.id, :recipe_name => recipe.name, :recipe_image => recipe.recipe_image.url, :missing_ingredients => set_difference, :user => recipe.user, :missing => set_difference.length, :likes => recipe.likers.length, :uid => recipe.user.uid, :provider => recipe.user.provider }
			}
			format.json { render :json => { :message => "success", :recipes => @recipes} }

  	end
  end

  def followers
  	respond_to do |format|
			target = User.find_by_id(params[:id])
			@followers = []
			target.followers.each { |follower|
				@followers << { :id => follower.id, :first_name => follower.first_name, :last_name => follower.last_name, :profile_picture => follower.profile_picture.url, :provider => follower.provider, :uid => follower.uid }
			}
			format.json { render :json => { :message => "success", :users => @followers } }
  	end
  end

  def following
  	respond_to do |format|
			@followers = []
			target = User.find_by_id(params[:id])
			target.following.each { |follower|
				@followers << { :id => follower.id, :first_name => follower.first_name, :last_name => follower.last_name, :profile_picture => follower.profile_picture.url, :provider => follower.provider, :uid => follower.uid }
			}
			format.json { render :json => { :message => "success", :users => @followers } }
  	end
  end

end
