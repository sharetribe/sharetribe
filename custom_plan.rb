require 'zeus/rails'

class CustomPlan < Zeus::Rails

  # def my_custom_command
  #  # see https://github.com/burke/zeus/blob/master/docs/ruby/modifying.md
  # end

  def cucumber_environment


    # Ensure sphinx directories exist for the test environment
    ThinkingSphinx::Test.init
    
    # Stop Sphinx if it was already running
    ThinkingSphinx::Test.stop

    # Start Sphinx
    # With Zeus we don't care if it stays running afterwards. It's anyway restarted next time Zeus starts
    # And keeping it running makes running new tests much faster
    ThinkingSphinx::Test.start


  	# Load the seeds here
    # As this seemed the only place possible to make Zeus load default categories while Zeus starts 
    # And not every time cucumber tests are run
  	CategoriesHelper.load_test_categories_and_transaction_types_to_db
 
  end

end

Zeus.plan = CustomPlan.new
