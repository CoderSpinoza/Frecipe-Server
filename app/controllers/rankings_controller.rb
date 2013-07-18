class RankingsController < ApplicationController
	def index
		@users = User.all
		respond_to do |format|
			format.json { :json => {:users => @users, :message => "success"}}
		end
	end
end
