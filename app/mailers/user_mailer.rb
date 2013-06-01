class UserMailer < ActionMailer::Base
  default from: "frecipe@gmail.com"

  def welcome(user)
  	@user = user
  	mail(:to => user.email, :subject => "Welcome to Frecipe!")
  end
end
