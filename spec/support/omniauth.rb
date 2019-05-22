# Doc at: https://github.com/intridea/omniauth/wiki/Integration-Testing

OmniAuth.config.test_mode = true

module OmniAuthTestHelpers
  def oauth_mock(provider, options = {})
    OmniAuth.config.add_mock(provider, oauth_provider_data(provider, options))
  end

  def oauth_provider_data(provider, options)
    data = if provider == 'facebook'
             oauth_facebook_data
           elsif provider == 'google_oauth2'
             stub_google_image_request
             oauth_google_data
           elsif provider == 'linkedin'
             stub_linkedin_image_request
             oauth_linkedin_data
           end
    data.dup.deep_merge(options)
  end

  # rubocop:disable Metrics/LineLength
  def oauth_facebook_data
    {
      provider: 'facebook',
      uid: '597013691',
      info: {
        nickname: 'markussharer',
        email: 'markus@example.com',
        name: 'Markus Sugarberg',
        first_name: 'Markus',
        last_name: 'Sugarberg',
        image: 'http://graph.facebook.com/1234567/picture',
        urls: { Facebook: 'http://www.facebook.com/jbloggs' },
        location: 'Palo Alto, California',
        verified: true
      },
      credentials: {
        token: 'ABCDEF...', # OAuth 2.0 access_token, which you may wish to store
        expires_at: 1321747205, # when the access token expires (it always will)
        expires: true, # this will always be true
        refresh_token: 'TTT'
      },
      extra: {
        raw_info: {
          id: '597013691',
          name: 'Markus Sugarberg',
          first_name: 'Markus',
          last_name: 'Sugarberg',
          link: 'http//www.facebook.com/jbloggs',
          birthday: '02/14/1990',
          username: 'markus.sharer-123',
          location: { id: '123456789', name: 'Palo Alto, California' },
          gender: 'male',
          email: 'markus@example.com',
          timezone: -8,
          locale: 'en_US',
          verified: true,
          updated_time: '2011-11-11T06:21:03+0000'
        }
      }
    }
  end

  def oauth_google_data
    {
      provider: 'google_oauth2',
      uid: '123456789012345678901',
      info: {
        name: 'John Due',
        email: 'john@ithouse.lv',
        first_name: 'John',
        last_name: 'Due',
        image: 'https://lh3.googleusercontent.com/-BILLeKNfUNs/AAAAAAAAAAI/AAAAAAAAAAA/bk9ax13dM2E/photo.jpg',
        urls: {
          Google: 'https://plus.google.com/123456789012345678901'
        }
      },
      credentials: {
        token: 'ya29.CjFnA0akHI-t5rf9vT_hYe_qmhMQQxkSmYYyaG-I34TW2GijlAPZR8RNy0IpycFhfgML',
        expires_at: 1474622535,
        expires: true,
        refresh_token: 'TTT'
      },
      extra: {
        id_token: 'eyJhbGciOiJSUzI1NiIsImtpZCI6IjA3MTEyNWE2NDY4ZTBjODQ3NGQzNWM4OWRjZjJjMzM5MGI4M2I1Y2IifQ.eyJpc3MiOiJhY2NvdW50cy5nb29nbGUuY29tIiwiYXRfaGFzaCI6ImY0cHdTX3NWc1lDaUJWd0J0QWs1c3ciLCJhdWQiOiIzMjU5NjQ5NzIzMjItb3BzaWEycnVyODFpMDdjYnZwZXZ2YzRmZGlmZnZ2bmQuYXBwcy5nb29nbGV1c2VyY29udGVudC5jb20iLCJzdWIiOiIxMTQ5MjkyNTA1MTI1OTgwMjU2NjgiLCJlbWFpbF92ZXJpZmllZCI6dHJ1ZSwiYXpwIjoiMzI1OTY0OTcyMzIyLW9wc2lhMnJ1cjgxaTA3Y2J2cGV2dmM0ZmRpZmZ2dm5kLmFwcHMuZ29vZ2xldXNlcmNvbnRlbnQuY29tIiwiaGQiOiJpdGhvdXNlLmx2IiwiZW1haWwiOiJhaXZpbHNAaXRob3VzZS5sdiIsImlhdCI6MTQ3NDYxODkzNSwiZXhwIjoxNDc0NjIyNTM1fQ.hfBkT43GrSrrUqJg4_KlYr5IYrehoRlSAUtDq6BUpAT-V4meMGvMz0wiGKmTMs_igdngX6KVLzlF4zWVllGlfZM3esFmSyumLgP83HDoEfWtcVcG-OlMtuzDCKOU0hJhNTV5KntIxTMrs1eGdknVaRrdb8fLC_EYnXKJoZYAO_6UtLc-v44j8Z_IC29Owb24P6O1GrOnpFz6xAjHnljGFn5nYPQR-ZIvA2dV8OFNS2preF1ox0Ujz98vtwaee33-oyJuuJOzQHiP8WI0SctVr8KWn38XYHjwKry0wVvPJpLL_8s1Ngo6H7fws3z_4Zy3VqrD_mrjya-VmdckSyOi9Q',
        id_info: {
          iss: 'accounts.google.com',
          at_hash: 'f4pwS_sVsYCiBVwBtAk5sw',
          aud: '325964972322-opsia2rur81i07cbvpevvc4fdiffvvnd.apps.googleusercontent.com',
          sub: '123456789012345678901',
          email_verified: true,
          azp: '325964972322-opsia2rur81i07cbvpevvc4fdiffvvnd.apps.googleusercontent.com',
          hd: 'ithouse.lv',
          email: 'john@ithouse.lv',
          iat: 1474618935,
          exp: 1474622535
        },
        raw_info: {
          kind: 'plus#personOpenIdConnect',
          gender: 'male',
          sub: '123456789012345678901',
          name: 'John Due',
          given_name: 'John',
          family_name: 'Due',
          profile: 'https://plus.google.com/123456789012345678901',
          picture: 'https://lh3.googleusercontent.com/-BILLeKNfUNs/AAAAAAAAAAI/AAAAAAAAAAA/bk9ax13dM2E/photo.jpg?sz=50',
          email: 'john@ithouse.lv',
          email_verified: 'true',
          locale: 'lv',
          hd: 'ithouse.lv'
        }
      }
    }
  end

  # rubocop:disable Metrics/MethodLength
  def oauth_linkedin_data
    {"provider" => "linkedin",
     "uid" => "50k-SSSS99",
     "info" =>
    {"email" => "devel@example.com",
     "first_name" => "Tony",
     "last_name" => "Testmen",
     "picture_url" =>
        "https://media.licdn.com/dms/image/C5603AQEK2H8SiE59Jw/profile-displayphoto-shrink_800_800/0?e=1553126400&v=beta&t=9Zg8_GZwAKl_Za2CF5IgC-gD2XvHjupCm_8wqdQjvVk"},
     "credentials" =>
      {"token" =>
        "12345678-DGT50OyLxmjzY9SssMxeBSEpDC2R25vr68hVy3HwRcU5jDmLhg2UKsPDWBCoQo9XyE4BG84xFNLZ3RDUzAoEJLVGBAxh99cLWjSc9ghODpIwfv3A6rLn4yx3Cs1IR2L9ofWtOoXmUVWoKfM2Mj4Bj_OHoVzt47wCxWQfq1gL28Ro8IP4qMrheWCr2TzX1QHHs0XdhytStcos3C_D6XmhhpFTMaHL5W06ej7eIn5dJJIr_xNu-u7LtgDTU0h3v0wMlkmcXFKnY_iZZ3SldyLJs-6E00YonU6unhuxLz5Zzj2hEZ1gNVEgEvQqCS6EDTiNfUTfu1PBIYPIqqqqQQQQ",
       "expires_at" => 1552727705,
       "expires" => true},
     "extra" =>
      {"raw_info" =>
        {"firstName" =>
          {"localized" => {"en_US"=>"Tony"},
           "preferredLocale" => {"country"=>"US", "language"=>"en"}},
         "lastName" =>
          {"localized" => {"en_US"=>"Testmen"},
           "preferredLocale" => {"country"=>"US", "language"=>"en"}},
         "profilePicture" =>
          {"displayImage" => "urn:li:digitalmediaAsset:C5603AQEK2H8SiE59Jw",
           "displayImage~" =>
            {"elements" =>
              [{"artifact" =>
                 "urn:li:digitalmediaMediaArtifact:(urn:li:digitalmediaAsset:C5603AQEK2H8SiE59Jw,urn:li:digitalmediaMediaArtifactClass:profile-displayphoto-shrink_100_100)",
                "authorizationMethod" => "PUBLIC",
                "data" =>
                 {"com.linkedin.digitalmedia.mediaartifact.StillImage" =>
                   {"storageSize" => {"width"=>100, "height"=>100},
                    "storageAspectRatio" =>
                     {"widthAspect" => 1.0,
                      "heightAspect" => 1.0,
                      "formatted" => "1.00:1.00"},
                    "mediaType" => "image/jpeg",
                    "rawCodecSpec" => {"name"=>"jpeg", "type"=>"image"},
                    "displaySize" => {"uom"=>"PX", "width"=>100.0, "height"=>100.0},
                    "displayAspectRatio" =>
                     {"widthAspect" => 1.0,
                      "heightAspect" => 1.0,
                      "formatted" => "1.00:1.00"}}},
                "identifiers" =>
                 [{"identifier" =>
                    "https://media.licdn.com/dms/image/C5603AQEK2H8SiE59Jw/profile-displayphoto-shrink_100_100/0?e=1553126400&v=beta&t=eHikoEd4N3NbHu90XtlQD8VM6oX9guudosWLpjD1XjA",
                   "file" =>
                    "urn:li:digitalmediaFile:(urn:li:digitalmediaAsset:C5603AQEK2H8SiE59Jw,urn:li:digitalmediaMediaArtifactClass:profile-displayphoto-shrink_100_100,0)",
                   "index" => 0,
                   "mediaType" => "image/jpeg",
                   "identifierType" => "EXTERNAL_URL",
                   "identifierExpiresInSeconds" => 1553126400}]},
               {"artifact" =>
                 "urn:li:digitalmediaMediaArtifact:(urn:li:digitalmediaAsset:C5603AQEK2H8SiE59Jw,urn:li:digitalmediaMediaArtifactClass:profile-displayphoto-shrink_200_200)",
                "authorizationMethod" => "PUBLIC",
                "data" =>
                 {"com.linkedin.digitalmedia.mediaartifact.StillImage" =>
                   {"storageSize" => {"width"=>200, "height"=>200},
                    "storageAspectRatio" =>
                     {"widthAspect" => 1.0,
                      "heightAspect" => 1.0,
                      "formatted" => "1.00:1.00"},
                    "mediaType" => "image/jpeg",
                    "rawCodecSpec" => {"name"=>"jpeg", "type"=>"image"},
                    "displaySize" => {"uom"=>"PX", "width"=>200.0, "height"=>200.0},
                    "displayAspectRatio" =>
                     {"widthAspect" => 1.0,
                      "heightAspect" => 1.0,
                      "formatted" => "1.00:1.00"}}},
                "identifiers" =>
                 [{"identifier" =>
                    "https://media.licdn.com/dms/image/C5603AQEK2H8SiE59Jw/profile-displayphoto-shrink_200_200/0?e=1553126400&v=beta&t=S7WhbAux-oy5a4nUt_p46xRCO-o25PHAExFVG2R8FDE",
                   "file" =>
                    "urn:li:digitalmediaFile:(urn:li:digitalmediaAsset:C5603AQEK2H8SiE59Jw,urn:li:digitalmediaMediaArtifactClass:profile-displayphoto-shrink_200_200,0)",
                   "index" => 0,
                   "mediaType" => "image/jpeg",
                   "identifierType" => "EXTERNAL_URL",
                   "identifierExpiresInSeconds" => 1553126400}]},
               {"artifact" =>
                 "urn:li:digitalmediaMediaArtifact:(urn:li:digitalmediaAsset:C5603AQEK2H8SiE59Jw,urn:li:digitalmediaMediaArtifactClass:profile-displayphoto-shrink_400_400)",
                "authorizationMethod" => "PUBLIC",
                "data" =>
                 {"com.linkedin.digitalmedia.mediaartifact.StillImage" =>
                   {"storageSize" => {"width"=>400, "height"=>400},
                    "storageAspectRatio" =>
                     {"widthAspect" => 1.0,
                      "heightAspect" => 1.0,
                      "formatted" => "1.00:1.00"},
                    "mediaType" => "image/jpeg",
                    "rawCodecSpec" => {"name"=>"jpeg", "type"=>"image"},
                    "displaySize" => {"uom"=>"PX", "width"=>400.0, "height"=>400.0},
                    "displayAspectRatio" =>
                     {"widthAspect" => 1.0,
                      "heightAspect" => 1.0,
                      "formatted" => "1.00:1.00"}}},
                "identifiers" =>
                 [{"identifier" =>
                    "https://media.licdn.com/dms/image/C5603AQEK2H8SiE59Jw/profile-displayphoto-shrink_400_400/0?e=1553126400&v=beta&t=o7XXBfFBhd2Y_Tufd1Y4EjndAxrxSDg6MUmpEdMByS0",
                   "file" =>
                    "urn:li:digitalmediaFile:(urn:li:digitalmediaAsset:C5603AQEK2H8SiE59Jw,urn:li:digitalmediaMediaArtifactClass:profile-displayphoto-shrink_400_400,0)",
                   "index" => 0,
                   "mediaType" => "image/jpeg",
                   "identifierType" => "EXTERNAL_URL",
                   "identifierExpiresInSeconds" => 1553126400}]},
               {"artifact" =>
                 "urn:li:digitalmediaMediaArtifact:(urn:li:digitalmediaAsset:C5603AQEK2H8SiE59Jw,urn:li:digitalmediaMediaArtifactClass:profile-displayphoto-shrink_800_800)",
                "authorizationMethod" => "PUBLIC",
                "data" =>
                 {"com.linkedin.digitalmedia.mediaartifact.StillImage" =>
                   {"storageSize" => {"width"=>800, "height"=>800},
                    "storageAspectRatio" =>
                     {"widthAspect" => 1.0,
                      "heightAspect" => 1.0,
                      "formatted" => "1.00:1.00"},
                    "mediaType" => "image/jpeg",
                    "rawCodecSpec" => {"name"=>"jpeg", "type"=>"image"},
                    "displaySize" => {"uom"=>"PX", "width"=>800.0, "height"=>800.0},
                    "displayAspectRatio" =>
                     {"widthAspect" => 1.0,
                      "heightAspect" => 1.0,
                      "formatted" => "1.00:1.00"}}},
                "identifiers" =>
                 [{"identifier" =>
                    "https://media.licdn.com/dms/image/C5603AQEK2H8SiE59Jw/profile-displayphoto-shrink_800_800/0?e=1553126400&v=beta&t=9Zg8_GZwAKl_Za2CF5IgC-gD2XvHjupCm_8wqdQjvVk",
                   "file" =>
                    "urn:li:digitalmediaFile:(urn:li:digitalmediaAsset:C5603AQEK2H8SiE59Jw,urn:li:digitalmediaMediaArtifactClass:profile-displayphoto-shrink_800_800,0)",
                   "index" => 0,
                   "mediaType" => "image/jpeg",
                   "identifierType" => "EXTERNAL_URL",
                   "identifierExpiresInSeconds" => 1553126400}]}],
             "paging" => {"count"=>10, "start"=>0, "links"=>[]}}},
         "id" => "50k-SSSS99"}}}
  end

  def stub_linkedin_image_request
    stub_request(:get, "https://media.licdn.com/dms/image/C5603AQEK2H8SiE59Jw/profile-displayphoto-shrink_800_800/0?e=1553126400&t=9Zg8_GZwAKl_Za2CF5IgC-gD2XvHjupCm_8wqdQjvVk&v=beta")
      .with(headers: {
        'Accept' => '*/*',
        'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
        'User-Agent' => 'Ruby'
         })
      .to_return(status: 200, body: png_image, headers: {'Content-Type'=>'image/png'})
  end

  def stub_google_image_request
    stub_request(:get, "https://lh3.googleusercontent.com/-BILLeKNfUNs/AAAAAAAAAAI/AAAAAAAAAAA/bk9ax13dM2E/photo.jpg")
      .with(headers: {
        'Accept' => '*/*',
        'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
        'User-Agent' => 'Ruby'
       })
      .to_return(status: 200, body: png_image, headers: {'Content-Type'=>'image/png'})
  end

  def png_image
    Base64.decode64('iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z/C/HgAGgwJ/lK3Q6wAAAABJRU5ErkJggg==')
  end
  # rubocop:enable Metrics/MethodLength, Metrics/LineLength
end

RSpec.configure do |config|
  config.include OmniAuthTestHelpers
end

