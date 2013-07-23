class RankingsController < ApplicationController
	def index
		@users = User.all

		@user = UserSession.user_by_authentication_token(params[:authentication_token])
		respond_to do |format|
			format.json { render :json => {:users => @users, :user => @user, :message => "success"}}
		end
	end
end
