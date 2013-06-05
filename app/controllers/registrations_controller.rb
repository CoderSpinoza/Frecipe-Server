class RegistrationsController < Devise::RegistrationsController
	def create
		build_resource

    if User.find_by_email(resource[:user][:email])
      respond_to do |format|
        format.json { render :json => { :message => "An account with the email you entered already exists."} }
      end
    else
      if resource.save
        if resource.active_for_authentication?
          sign_up(resource_name, resource)
          # session = UserSession.
          resource.ensure_authentication_token!
          session = UserSession.new(:user => resource)

          if session.save
            session.ensure_authentication_token!
            grocery_recipe = GroceryRecipe.create(:user => resource, :recipe_id => 0)
            UserMailer.welcome(resource).deliver
            respond_to do |format|
              format.json { render :json => {:message => "success", :user => resource, :authentication_token => session.authentication_token, :profile_picture => resource.profile_picture.url}}
            end
          else
            respond_to do |format|
              format.json { render :json => {:message => "Session creation failed. Please retry.", :user => resource}, :status => 400}
            end
          end
        else
          expire_session_data_after_sign_in!
          respond_to do |format|
            format.json { render :json => { :message => "Account is inactive. Please try to login again.", :user => resource }, :status => 400 }
          end
        end
      else
        clean_up_passwords resource
        respond_to do |format|
          format.json { render :json => { :message => "There was an error processing your sign up request.", :user => resource }, :status => 400 }
        end
      end
    end
	end
end
