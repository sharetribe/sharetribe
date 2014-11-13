module UserService::API::DataTypes

  User = EntityUtils.define_builder(
    [:id, :mandatory, :string],
    [:given_name, :string],
    [:family_name, :string],
    [:locale, :string],
  )

  module_function

  def create_user(opts); User.call(opts) end
end
