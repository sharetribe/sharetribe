class S3Uploader

  def initialize()
    @aws_access_key_id = APP_CONFIG.aws_access_key_id
    @aws_secret_access_key = APP_CONFIG.aws_secret_access_key
    @bucket = APP_CONFIG.s3_upload_bucket_name
    @acl = "public-read"
    @expiration = 10.hours.from_now
  end

  def fields
    {
      :key => key,
      :acl => @acl,
      :policy => policy,
      :signature => signature,
      "AWSAccessKeyId" => @aws_access_key_id,
      :success_action_status => 200
    }
  end

  def url
    "https://#{@bucket}.s3.amazonaws.com/"
  end

  private

  def url_friendly_time
    Time.now.utc.strftime("%Y%m%dT%H%MZ")
  end

  def year
    Time.now.year
  end

  def month
    Time.now.month
  end

  def key
    "uploads/listing-images/#{year}/#{month}/#{url_friendly_time}-#{SecureRandom.hex}/${index}/${filename}"
  end

  def policy
    Base64.encode64(policy_data.to_json).gsub("\n", "")
  end

  def policy_data
    {
      expiration: @expiration.utc.iso8601,
      conditions: [
        ["starts-with", "$key", "uploads/listing-images/"],
        ["starts-with", "$Content-Type", "image/"],
        ["starts-with", "$success_action_status", "200"],
        ["content-length-range", 0, APP_CONFIG.max_image_filesize],
        {bucket: @bucket},
        {acl: @acl}
      ]
    }
  end

  def signature
    Base64.encode64(
      OpenSSL::HMAC.digest(
        OpenSSL::Digest.new('sha1'),
        @aws_secret_access_key, policy
      )
    ).gsub("\n", "")
  end
end
