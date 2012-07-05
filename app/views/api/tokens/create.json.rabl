object @person => :token
attributes :authentication_token => :api_token

child @person do
  extends "api/people/show"
end

