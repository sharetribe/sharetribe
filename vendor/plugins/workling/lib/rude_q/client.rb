#
#  A RudeQ client that behvaes somewhat like memcache-client
#
module RudeQ
  class Client    
    def initialize(*args); super(); end   
    def set(key, value); RudeQueue.set(key, value); end;
    def get(key); RudeQueue.get(key); end;
    def stats; ActiveRecord::Base.connection; end
  end
end