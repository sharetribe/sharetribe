require 'zeus/rails'

class CustomPlan < Zeus::Rails

  # def my_custom_command
  #  # see https://github.com/burke/zeus/blob/master/docs/ruby/modifying.md
  # end

  def cucumber_environment
  	# Load the seeds here 
  	load "#{Rails.root}/db/seeds.rb"
  	
  	# this didn't work from here
  	#load "#{Rails.root}/features/support/env.rb"

  end

end

Zeus.plan = CustomPlan.new
