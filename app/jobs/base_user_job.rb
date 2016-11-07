#
# This is a base class for jobs that are initiated by a user, i.e.
# we know the user ID and marketplace ID
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

class BaseUserJob
  attr_reader :params, :user_info

  UserInfo = EntityUtils.define_builder(
    [:marketplace_id, :fixnum, :mandatory],
    [:user_id, :fixnum, :mandatory]
  )

  def initialize(data)
    @user_info = user_info_entity(data[:user_info])
    @params    = params_entity(data[:params])
  end

  def user_info_entity(data)
    UserInfo.call(data)
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
    RequestStore.store[:current_user_id] = @user_info[:user_id]
    RequestStore.store[:current_community_id] = @user_info[:marketplace_id]
  end
end
