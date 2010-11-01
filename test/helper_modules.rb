# Modules in this file are included in both specs and cucumber steps.

module TestHelpers
  def get_test_person_and_session(username="kassi_testperson1")
    session = nil
    test_person = nil

    #frist try loggin in to cos
    begin
      session = Session.create({:username => username, :password => "testi" })
      #try to find in kassi database
      test_person = Person.find(session.person_id)

    rescue RestClient::Request::Unauthorized => e
      #if not found, create completely new
      session = Session.create
      test_person = Person.create({ :username => username, 
                      :password => "testi", 
                      :email => "#{username}@example.com",
                      :given_name => "Test",
                      :family_name => "Person"},  
                       session.cookie)

    rescue ActiveRecord::RecordNotFound  => e
      test_person = Person.add_to_kassi_db(session.person_id)
    end
    return [test_person, session]
  end
  
  def generate_random_username(length = 12)
    chars = ("a".."z").to_a + ("0".."9").to_a
    random_username = "aa_kassitest"
    1.upto(length - 7) { |i| random_username << chars[rand(chars.size-1)] }
    return random_username
  end
end
