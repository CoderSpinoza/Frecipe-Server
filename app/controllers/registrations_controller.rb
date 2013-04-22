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
        resource.ensure_authentication_token!
        respond_to do |format|
          format.json { render :json => ["success", resource, resource.authentication_token]}
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
