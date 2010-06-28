class Transaction < ActiveResource::Base
   self.site = APP_CONFIG.asi_url + '/people/:sender_id/@transactions'
   self.timeout =  3 #APP_CONFIG.asi_timeout
   #self.format = :json 
end
