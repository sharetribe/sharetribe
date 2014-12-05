class PasswordsController < Devise::PasswordsController
  skip_filter :single_community_only

  layout :application
end
