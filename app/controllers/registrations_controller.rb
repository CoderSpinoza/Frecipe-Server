class RegistrationsController < Devise::RegistrationsController
	def create
		build_resource
    uid = params[:uid]
    if uid
      # resource.provider = 'facebook'
      # resource.uid = uid
    end
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
            format.json { render :json => ["success", resource, session.authentication_token, resource.profile_picture.url ]}
          end
        else
          respond_to do |format|
            format.json { render :json => ["session creation failed", resource], :status => 400}
          end
        end
      else
        expire_session_data_after_sign_in!
        respond_to do |format|
          format.json { render :json => ["inactive", resource], :status => 400 }
        end
      end
    else
      clean_up_passwords resource
      respond_to do |format|
        format.json { render :json => ["error", resource], :status => 400 }
      end
    end
	end
end
