class TestJob < BaseUserJob

  Params = EntityUtils.define_builder(
    [:message, :string, :mandatory]
  )

  def perform
    puts "User info from request store: #{RequestStore[:current_user_id]}"
    puts "Marketplace info from request store: #{RequestStore[:current_community_id]}"
    puts "Params #{params}"
  end

  def params_entity(params)
    Params.call(params)
  end
end
