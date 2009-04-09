module Smerf
  
  protected

    # Method retrieves the user id from the session if it exists
    def smerf_user_id
      session[:smerf_user_id] || -1      
    end

    # Method stores the specified user id in the session
    def smerf_user_id=(id)
      session[:smerf_user_id] = id
    end

end    