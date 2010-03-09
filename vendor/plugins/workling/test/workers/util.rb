require 'workling/base'

class Util < Workling::Base
  def echo(*args)
    # shout!
  end
  
  def faulty(args)
    raise Exception.new("this is pretty faulty.")
  end
  
  def stuffing(contents)
    # expects contents. 
  end
end