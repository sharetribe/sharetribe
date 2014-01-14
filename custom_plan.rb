require 'zeus/rails'

class CustomPlan < Zeus::Rails

  # def my_custom_command
  #  # see https://github.com/burke/zeus/blob/master/docs/ruby/modifying.md
  # end

  def cucumber_environment
  	# Load the seeds here
    # As this seemed the only place possible to make Zeus load default categories while Zeus starts 
    # And not every time cucumber tests are run
  	load "#{Rails.root}/db/seeds.rb"
 
  end

end

Zeus.plan = CustomPlan.new
