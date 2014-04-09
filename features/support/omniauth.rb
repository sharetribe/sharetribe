# Doc at: https://github.com/intridea/omniauth/wiki/Integration-Testing

OmniAuth.config.test_mode = true

OmniAuth.config.mock_auth[:facebook] = OmniAuth::AuthHash.new( {
    :provider => 'facebook',
    :uid => '597013691',
    :extra =>{
      :raw_info => {
        :first_name => "Markus",
        :last_name => "Sugarberg",
        :username => "markus.sharer-123",
        :email => "markus@example.com",
        :id => '597013691'
      }
    }
  })
