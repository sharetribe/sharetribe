marketplace = MarketplaceService.create(
  marketplace_name: 'donalo',
  marketplace_type: 'product',
  marketplace_country: 'ES',
  marketplace_language: 'es'
)
user = UserService::API::Users.create_user(
  {
    given_name: 'Troy',
    family_name: 'McClure',
    email: 'donalo@example.com',
    password: 'papapa22',
    locale: 'es'
  },
  marketplace.id
)
user = user.data

auth_token = UserService::API::AuthTokens.create_login_token(user[:id])
auth_token = AuthToken.first
user_token = auth_token[:token]
url = URLUtils.append_query_param(
  marketplace.full_domain(with_protocol: true), "auth", user_token
)

Rake::Task['stripe:enable'].invoke

puts "\n\e[33mYou can now navigate to your markeplace at #{url}"
