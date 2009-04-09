# Require required for mixin of helper methods
require "smerf_system_helpers"
require "smerf_helpers"

# This model class manages the smerf_forms DB table and stores details about smerf forms. 
# One of the main function it performs it to rebuild a form from a form 
# definition file if required.
# 

class SmerfForm < ActiveRecord::Base
  
  # Add smerf helper methods to this class 
  include SmerfSystemHelpers
  include SmerfHelpers
  
  has_many :users, :through => :smerf_forms_users
  validates_presence_of :name, :code, :active
  validates_length_of :name, :allow_nil => false, :maximum => 50
  validates_length_of :code, :allow_nil => false, :maximum => 20
  validates_uniqueness_of :code
  
  # We read the form contents from a form definition file, we then
  # save the results in YAML format to this DB field. Doing this prevents
  # us from having to read and process the definition file everytime the 
  # form needs to be displayed. We check the form definition file date 
  # against a date we store in the DB to determine if we need to rebuild.
  #
  # We override the attribute reader for cache so that we only unserialize
  # it the first time this field is accessed, it also allows us to initialize
  # class variables which can not be serialized as they store object references
  # which are initialized at run time (see below)
  #  
  serialize :cache  
  
  @unserialized_cache = nil
    
  # This method retrieves a form record using the name of the form which 
  # is the same name as the form definition file. If the file is called 
  # <tt>testsmerf.yml</tt> then the <em>code</em> parameter should be 
  # <tt>testsmerf</tt>.
  #
  def SmerfForm.find_by_code(code)
    smerfform = SmerfForm.find(:first, :conditions => "code = '#{code}'")      
    # Create a new smerfform object if record not found
    smerfform = SmerfForm.new() if (!smerfform)    
    return smerfform
  end

  # This method processed a form definition file and stores the results in
  # the smerf_forms DB record.
  # 
  # When a form definition file is seen for the first time, it will be processed
  # and all resultant objects created during the processing of the file will be 
  # serialized to the <em>cache</em> field within the form record. The 
  # <em>cache_date</em> is updated with the current date and time.
  # 
  # Subsequently the form will be retrieved directly from the DB record rather
  # than having to rebuilt from the definition file. The timestamp of the file
  # is checked against the value stored in the <em>cache_date</em> field, if they
  # are different the form definition will be reprocessed.
  #
  def rebuild_cache(code)  
    return if (!self.code.blank?() and !SmerfFile.modified?(code, self.cache_date))        
    # First clear the current cache
    self.cache = nil ; self.save if (!code.blank?)
    self.cache = Hash.new
    # Build the form and save to cache
    smerffile = SmerfFile.new
    smerfmetaform = smerffile.process(code)
    self.cache[:smerfform] = smerfmetaform
    self.cache_date = File.mtime(SmerfFile.smerf_file_name(code)).utc
    if (self.code.blank?())
      # Set code
      self.code = code
      # Set as active
      self.active = 1
    end  
    # Assign the name as it may have changed
    self.name = smerfmetaform.name
    # Save the changes
    self.save!()
  end 
  
  # This method checks if the form is active, returns true if it is.
  #
  def active?
    (self.active == 1)
  end
  
  # Override read attribute accessor for the cache attribute so that we only 
  # unserialize this field once which improves performance, it also allows 
  # us to initialize class variables which are not serialized
  #
  def cache
    # Unserialize the data
    cache = unserialize_attribute('cache')
    self[:cache] = cache
  end
  
  # Alias to smerfform.cache[:smerfform]
  #
  def form
    @unserialized_cache = self.cache if (!@unserialized_cache)
    return @unserialized_cache[:smerfform]
  end
  
  # This method validates all user responses.
  #
  # All validations are specified as part of the question (or subquestion) definition
  # using the 'validation:' field. The SMERF validation system is very flexible and
  # allows any number of validation methods to be specified for a question by comma
  # separating each method.
  #
  #  validation: validate_mandatory_question, validate_years 
  #
  # Currently there are two validation methods provided with the plugin:
  #
  # validate_mandatory_question:: This method will ensure that the user has answered 
  #                               the question
  # validate_sub_question:: Only applies to subquestions and makes sure that the user 
  #                         has selected the answer that relates to the subquestion, it 
  #                         will also ensure the subquestion has been answered if the 
  #                         answer that relates to the subquestion has been selected.
  #
  # SMERF also allows you to define your own custom validation methods. During
  # the installation process SMERF creates a helper module called smerf_helpers.rb in 
  # the /lib directory. You can add new validation methods into this module and 
  # access them by simply referencing them in the form definition file. For example
  # we have question 'How many years have you worked in the industry' and we want
  # to ensure that the answer provided is between 0-99 we can create a new validation
  # method called 'validate_years'.
  #
  #   # Example validation method for "How many years have you worked in the industry"
  #   # it uses a regex to make sure 0-99 years specified.
  #
  #   def validate_years(question, responses, form)
  #     # Validate entry and make sure years are numeric and between 0-99
  #     answer = smerf_get_question_answer(question, responses)    
  #      if (answer)
  #        # Expression will return nil if regex fail, also check charcters
  #        # after the match to determine if > 2 numbers specified
  #        res = ("#{answer}" =~ /\d{1,2}/)      
  #        return "Years must be between 0 and 99" if (!res or $'.length() > 0)      
  #      end
  #  
  #      return nil
  #    end
  #
  # Note: There are some helper methods that you can use within these methods included
  # in the smerf_system_helpers.rb module which you can find in the plugins lib
  # directory.
  #
  # Your question definition may then look like this:
  #
  #    how_many_years:
  #      code: g2q3
  #      type: textfield
  #      sort_order: 3
  #      header: 
  #      question: | How many years have you worked in the industry
  #      textfield_size: 10
  #      validation: validate_mandatory_question, validate_years
  #      help: 
  #
  # When the form is validated your custom validation method will be called. When 
  # an error is detected, a summary of the errors are displayed at the top of the 
  # form, additionally an error message is displayed for each question that has an 
  # error. This makes it very easy for the user to see which question they need 
  # to fix. 
  #
  def validate_responses(responses, errors)
    # Perform all validations by calling the validation helper methods
    # defined in the SmerfHelpers module 
    call_validations(self.form, responses, errors)
  end
    
  private
  
    def call_validations(object, responses, errors)
      object.child_items.each do |item|
        if (item.respond_to?('validation') and !item.send('validation').blank?)
          # Multiple validation functions can be specified by using a comma
          # between each function
          validation_functions = item.validation.split(",")
          validation_functions.each do |validation_function|
            if (self.respond_to?(validation_function.strip()))
              # Call the method
              error_msg = self.send(validation_function.strip(),
                item, responses, self.form)
              add_error(errors, error_msg, item) if (!error_msg.blank?())
            end                      
          end
        end
        # Recursivly call this method to navigate all items on the form
        call_validations(item, responses, errors)        
      end
    end
  
    def add_error(errors, msg, item)
      errors[item.item_id] = Hash.new if (errors[item.item_id].nil?())
      errors[item.item_id]["msg"] = Array.new if (errors[item.item_id]["msg"].nil?())
      errors[item.item_id]["msg"] << msg
      errors[item.item_id]["question"] = item.question
    end
    
end
