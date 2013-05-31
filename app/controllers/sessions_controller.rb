class SessionsController < Devise::SessionsController
	# POST /resource/sign_in

  def index
    respond_to do |format|
      format.html 
    end
  end
  
  def create
    respond_to do |format|
      format.json { render :json => ["hihi"]}
    end
  end

  def failure
    respond_to do |format|
      format.json { render :json => ["failure"]}
    end
  end
end