class Transaction < ActiveResource::Base
   self.site = COS_URL + '/people/:sender_id/@transactions'
   self.timeout =  3 #COS_TIMEOUT
   #self.format = :json 
end
