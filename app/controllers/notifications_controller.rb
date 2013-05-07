class NotificationsController < ApplicationController
  # GET /notifications
  # GET /notifications.json
  def index
    @notifications = Notification.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @notifications }
    end
  end

  # GET /notifications/1
  # GET /notifications/1.json
  def show
    @notification = Notification.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @notification }
    end
  end

  # GET /notifications/new
  # GET /notifications/new.json
  def new
    @notification = Notification.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @notification }
    end
  end

  # GET /notifications/1/edit
  def edit
    @notification = Notification.find(params[:id])
  end

  # POST /notifications
  # POST /notifications.json
  def create
    @notification = Notification.new(params[:notification])

    respond_to do |format|
      if @notification.save
        format.html { redirect_to @notification, notice: 'Notification was successfully created.' }
        format.json { render json: @notification, status: :created, location: @notification }
      else
        format.html { render action: "new" }
        format.json { render json: @notification.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /notifications/1
  # PUT /notifications/1.json
  def update
    @notification = Notification.find(params[:id])

    respond_to do |format|
      if @notification.update_attributes(params[:notification])
        format.html { redirect_to @notification, notice: 'Notification was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @notification.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /notifications/1
  # DELETE /notifications/1.json
  def destroy
    @notification = Notification.find(params[:id])
    @notification.destroy

    respond_to do |format|
      format.html { redirect_to notifications_url }
      format.json { head :no_content }
    end
  end

  def user
    @user = User.find_by_authentication_token(params[:authentication_token])
    if @user
      notifications = Notification.where(:target_id => @user.id)
      notifications_array = []
      count = 0
      for notification in notifications
        notifications_array << { :category => notification.category, :source => notification.source, :target => notification.target, :recipe => notification.recipe, :seen => notification.seen }
        if notification.seen == 0
          count += 1
        end
      end

      respond_to do |format|
        format.json { render :json => { :notifications => notifications_array, :unseen_count => count }}
      end
    else
      respond_to do |format|
        format.json { render :json => { :message => "Invalid authentication_token"}}
      end
    end

  end
end
