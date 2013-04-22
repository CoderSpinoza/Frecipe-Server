class OmniauthController < ApplicationController
	def facebook
		@user = User.find_for_facebook_oauth(request.env['omniauth.auth'], current_user)
	end

	def create
		auth = request.env["omniauth.auth"]
		user = User.where(:provider => auth[:provider], :uid => auth[:uid])

		if user
			# respond_to do |format|
			# 	format.json { render :json => user }
			# end
			redirect_to "/users/sign_in"
		else
			# respond_to do |format|
			# 	format.json { render :json => ["no"]}
			# end
			redirect_to "/"
		end
	end
end
