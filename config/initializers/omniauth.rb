OmniAuth.config.logger = Rails.logger

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :facebook, "295470053913692", "9b2a04b148544a0af5d59a513a55a4a4"
end