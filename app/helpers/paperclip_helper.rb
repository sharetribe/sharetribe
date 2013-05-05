module PaperclipHelper
  
  def self.paperclip_default_options
    paperclip_options = {
          :path => ":rails_root/public/system/:attachment/:id/:style/:filename",
          :url => "/system/:attachment/:id/:style/:filename"
    }
          
    if ApplicationHelper.use_s3?
      paperclip_options.merge!({
        :path => "images/:class/:attachment/:id/:style/:filename",
        :url => "/system/:class/:attachment/:id/:style/:filename",
        :storage => :s3,
        :s3_protocol => 'https',
        :s3_credentials => {
              :bucket            => APP_CONFIG.s3_bucket_name, 
              :access_key_id     => APP_CONFIG.aws_access_key_id, 
              :secret_access_key => APP_CONFIG.aws_secret_access_key 
        }
      })
    end
    
    return paperclip_options
    
  end
  
end