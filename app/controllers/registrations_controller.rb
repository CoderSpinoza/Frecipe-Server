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
          respond_to do |format|
            format.json { render :json => ["success", resource, session.authentication_token, resource.profile_picture.url ]}
          end
        else
          respond_to do |format|
            format.json { render :json => ["session creation failed", resource]}
          end
        end
      else
        expire_session_data_after_sign_in!
        respond_to do |format|
          format.json { render :json => ["inactive", resource]}
        end
      end
    else
      clean_up_passwords resource
      respond_to do |format|
        format.json { render :json => ["error", resource]}
      end
    end
	end
end
