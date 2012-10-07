class Api::TokensController < Api::ApiController

  # Shows the token based on username and password
  # Used http://matteomelani.wordpress.com/2011/10/17/authentication-for-mobile-devices/ as example for this
  def create

    login = params[:login] || params[:username]
    password = params[:password]

    if login.nil? or password.nil?
       render :status=>400,
              :json=>{:message=>"The request must contain the user login (username or email) and password."}
       return
    end

    @person = Person.where(["lower(username) = :value OR lower(email) = :value", { :value => login.downcase }]).first

    if @person.nil?
      logger.info("User #{username} failed signin, user cannot be found.")
      render :status=>401, :json=>{:message=>"Invalid login or password."}
      return
    end

    if not @person.valid_password?(password)
      logger.info("User #{login} failed signin, password is invalid")
      render :status=>401, :json=>{:message=>"Invalid login or password."}
    else
      @person.ensure_authentication_token!
      respond_with @person 
    end

  end

end


