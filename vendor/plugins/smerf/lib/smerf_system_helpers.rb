# This module contains some standard helper methods used by smerf.
# 
# All validation methods need to take three parameters:
# question:: The SmerfQuestion object to be validated
# responses:: Hash containing user responses keyed using the question code
# form:: Hash that contains all form objects including groups, questions and answers
# 
# The method needs to return an empty string or nil if no errors or 
# if there is an error then an error message describing the error should be returned.
# 
# Within the form definition file you specify if a validation is required
# on a question by specifying which methods within this module
# should be called to perform that validation, e.g.
# 
# specify_your_age:
#   code: g1q1
#   type: singlechoice
#   sort_order: 1
#   question: | Specify your ages  
#   help: | Select the <b>one</b> that apply 
#   validation: validation_mandatory
# 
# Multiple validation methods can be specified by comma separating each method name.                            
#

module SmerfSystemHelpers  

  # This method checks to make sure that mandatory questions
  # have been answered by the user
  #
  def validate_mandatory_question(question, responses, form)
    # Check if the responses hash has a key equal to the question code, if
    # not we know the question has not been answered
    if (!smerf_question_answered?(question, responses))
      return "Question requires an answer" 
    else
      return nil
    end
  end
  
  # This method will perform two checks:
  # 1. Check if the subquestion has been answered, if so then we want to 
  #    make sure that the answer this subquestion relates to has been 
  #    answered
  # 2. If the answer that has a subquestion is answered then make sure the 
  #    subquestion has been answered
  # 
  # This validation method is called from a subquestion, so the object
  # parameter should be a subquestion
  #
  def validate_sub_question(question, responses, form)
    # Retrieve the owner object of this subquestion
    answer_object = smerf_get_owner_object(question, form)
    # Make sure owner object is a SmerfAnswer
    raise(RuntimeError, "Owner object not a SmerfAnswer") if (!answer_object.kind_of?(SmerfAnswer))
    # Get the answer code
    answer_code = answer_object.code
    # Retrieve the owner object of the answer
    question_object = smerf_get_owner_object(answer_object, form)

    # 1. Make sure that the answer that relates to this subsequestion 
    # has the correct response, e.g.
    # Select your skills
    # Banker
    # Builder
    # ...
    # Other
    #    Please specify
    # We want to make sure 'Other' was selected if the 'Please specify'
    # subquestion has an answer
    # 
    # Check if this subquestion has an answer
    if (smerf_question_answered?(question, responses))
      # Check if the correct answer selected
      if (!smerf_question_has_answer?(question_object, responses, answer_code))
        return "'#{answer_object.answer}' needs to be selected"
      end  
    end
    
    # 2. Make sure that if an answer that has a subquestion is answered that
    # the subquestion has an answer, e.g.
    #
    # Select your skills
    # Banker
    # Builder
    # ...
    # Other
    #    Please specify
    # We want to make sure that if 'Other' was selected the 'Please specify'
    # subquestion has an answer
    # 
    # Check if the answer this subquestion relates to has been answered
    if (smerf_question_has_answer?(question_object, responses, answer_code))
      # Make sure the subquestion has been answered
      if (!smerf_question_answered?(question, responses))
        return "'#{answer_object.answer}' needs additional information"
      end        
    end
    
    return nil
  end
    
  # This method will find the object with the specified object ident
  #
  def smerf_get_object(item_id, form)    
    if (form.item_index.has_key?(item_id) and
      form.item_index[item_id])
      return form.item_index[item_id]
    else
      raise(RuntimeError, "Object with item_id(#{item_id}) not found or nil")
    end
  end   
    
  # This method will find the owner object of the object passed
  # in as a parameter
  #
  def smerf_get_owner_object(object, form)    
    if (form.item_index.has_key?(object.parent_id) and
      form.item_index[object.parent_id])
      return form.item_index[object.parent_id]
    else
      raise(RuntimeError, "Owner object not found or nil")
    end
  end   
  
  # This method check the to see if the supplied question has been answered 
  #
  def smerf_question_answered?(question, responses)
    return (responses.has_key?(question.code) and !responses[question.code].blank?())       
  end
  
  # This method will check if the question has the answer passed as a parameter. 
  # Some questions allow multiple answers so we need to check if one of the 
  # answers is equal to the supplied answer.
  #  
  def smerf_question_has_answer?(question, responses, answer)
    return (responses.has_key?(question.code) and
      ((responses[question.code].kind_of?(Hash) and
      responses[question.code].has_key?("#{answer}")) or
      (!responses[question.code].blank?() and
      responses[question.code] == "#{answer}")))    
  end
  
  # This method retrieves the answer to the supplied question, if no answer
  # found it will return nil. This method may return a hash containing all
  # answers if the question allows multiple choices.
  #
  def smerf_get_question_answer(question, responses)
    if (!smerf_question_answered?(question, responses))
      return nil
    else
      return responses[question.code]
    end
  end

end
