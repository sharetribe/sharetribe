#
# This is a base class for jobs that are initiated by a user, i.e.
# we know the user ID and marketplace ID
#
# Features:
#
# - Saves user/marketplace ID to RequestStore
# - Validate/transform params (optional)
#
# To use this class, make a new subclass:
#
# ```
# class TestJob < BaseUserJob
#
#   Params = EntityUtils.define_builder(
#     [:message, :string, :mandatory]
#   )
#
#   def perform
#     puts "User ID: #{RequestStore[:current_user_id]}"
#     puts "Marketplace ID: #{RequestStore[:current_community_id]}"
#     puts "Message #{params[:message]}"
#   end
#
#   def params_entity(params)
#     Params.call(params)
#   end
# end
# ```
#
# To enqueue a new class:
#
# ```
# Delayed::Job.enqueue(TestJob.new(
#   user: {
#     id: @current_user.id,
#     marketplace_id: @current_community.id
#   },
#   params: {
#     message: "Test message!"
#   }
# }
# ```

class BaseUserJob
  attr_reader :params, :user_info

  User = EntityUtils.define_builder(
    [:id, :string, :mandatory],
    [:marketplace_id, :fixnum, :mandatory]
  )

  def initialize(data)
    @user   = user_entity(data.fetch(:user))
    @params = params_entity(data[:params] || {})
  end

  def user_entity(data)
    User.call(data)
  end

  def params_entity(data)
    # Override this
    data
  end

  # Hooks

  def before
    set_request_store
  end

  private

  # Set user/marketplace to RequestStore
  # The store will be cleared automatically by a Delayed Job plugin
  #
  def set_request_store
    RequestStore.store[:current_user_id] = @user[:id]
    RequestStore.store[:current_community_id] = @user[:marketplace_id]
  end
end
