class RankingsController < ApplicationController
	def index
		@users = User.all
		@event = Event.first
		@user = UserSession.user_by_authentication_token(params[:authentication_token])
		respond_to do |format|
			format.json { render :json => {:users => @users, :user => @user, :event => @event, message => "success"}}
		end
	end
end
