require "smerf_system_helpers"

# This module contains all the helper methods used by the smerf form views.
module SmerfFormsHelper
  include SmerfSystemHelpers

  # This method creates a formatted error message that is then 
  # displayed on the smerf form page to inform the user of any errors.
  # 
  # CSS identifier: <tt>smerfFormError</tt>
  #
  def get_error_messages(errors)
    if (errors and !errors.empty?())
      header_message = 
        "#{pluralize(errors.size(), 'error')} prevented #{@smerfform.name} from being saved"
      error_messages = ""
      errors.each do |error| 
        # Check if question text available as some questions may have no text, 
        # e.g. sub questions. If this happens we check all parent objects to see
        # if the question text is available until text found or no more parents
        question = (error[1]["question"] and !error[1]["question"].blank?()) ? error[1]["question"] : find_question_text(error[0])        
        # Format error message
        error[1]["msg"].each do |error_msg|
          error_messages += content_tag(:li, "#{question}: #{error_msg}") 
        end
      end
      content_tag(:div,
        content_tag(:h2, header_message) <<
          content_tag(:p, 'There were problems with the following questions:') <<
          content_tag(:ul, error_messages),
        :class => "smerfFormError")
    else
      ''
    end
  end
  
  # This method creates a formatted notice message that is then 
  # displayed on the smerf form. The notice message is retrieved
  # from the flash[:notice].
  # 
  # CSS identifier: <tt>smerfFormNotice</tt>
  #
  def get_notice_messages
    if flash[:notice]
      content_tag(:div, content_tag(:p, flash[:notice]), :class => "smerfFormNotice")
    end
  end  

  # This method retrieves and formats the form title.
  # 
  # CSS identifier: <tt>h2</tt>
  #
  def smerf_title
    if !@smerfform.form.name.blank?
      content_tag(:h2, @smerfform.form.name)
    end
  end
  
  # This method retrieves and formats the form welcome message.
  # 
  # CSS identifier: <tt>formWelcome</tt>
  #
  def smerf_welcome
    if !@smerfform.form.welcome.blank?
      content_tag(:div, content_tag(:p, @smerfform.form.welcome), :class => "smerfWelcome")
    end
  end
  
  # This method retrieves and formats the form thank you message.
  # 
  # CSS identifier: <tt>smerfThankyou</tt>
  #
  def smerf_thank_you
    if !@smerfform.form.thank_you.blank?
      content_tag(:div, content_tag(:p, @smerfform.form.thank_you), :class => "smerfThankyou")
    end
  end
  
  # This method retrieves and formats the group name of the group
  # passed in as a parameter.
  # 
  # CSS identifier: <tt>smerfGroup</tt>
  #
  def smerf_group_name(group)
    if !group.name.blank?
      content_tag(:div, content_tag(:h3, group.name), :class => "smerfGroup")
    end
  end
   
  # This method retrieves and formats the group description of the group
  # passed in as a parameter.
  # 
  # CSS identifier: <tt>smerfGroup</tt>
  #
  def smerf_group_description(group)
    if !group.description.blank?
      content_tag(:div, content_tag(:p, group.description), :class => "smerfGroupDescription")
    end
  end
 
  # This method retrieves all the groups defined in the form.
  # 
  def smerf_get_groups
    @smerfform.form.groups
  end
 
  # This method retrieves all the questions defined for the group
  # passed in as a parameter.
  # 
  def smerf_get_group_questions(group)
    group.questions 
  end
  
  # This method formats the question, and any answers and subquestions
  # defined for it. The method takes a question object(SmerfQuestion)
  # and a level indicator as parameters. The level indicator tells us if
  # a question is a subquestion or not (level > 1).
  # 
  # The question type is checked to see how is should be formatted, currently 
  # the following formats are supported:
  # 
  # * Multiple choice (checkbox)
  # * Single choice (radio)
  # * Text field (large amount of text)
  # * Text box (small amount of text) 
  # 
  # CSS identifiers: 
  #   smerfQuestionHeader
  #   smerfQuestion
  #   smerfSubquestion
  #   smerfQuestionError
  #   smerfInstruction
  # 
  def smerf_group_question(question, level = 1)
    contents = ""
    # Format question header 
    contents += content_tag(:div, content_tag(:p, question.header), 
      :class => "smerfQuestionHeader") if (question.header and !question.header.blank?) 
    # Format question  
    contents += content_tag(:div, content_tag(:p, question.question), 
      :class => (level <= 1) ? "smerfQuestion" : "smerfSubquestion") if (question.question and !question.question.blank?) 
    # Format error
    contents += content_tag(:div, 
      content_tag(:p, "#{image_tag("smerf_error.gif", :alt => "Error")} #{@errors["#{question.item_id}"]["msg"]}"), 
      :class => "smerfQuestionError") if (@errors and @errors.has_key?("#{question.item_id}"))    
    # Format help   
    contents += content_tag(:div, 
      content_tag(:p, "#{image_tag("smerf_help.gif", :alt => "Help")} #{question.help}"), 
      :class => "smerfInstruction") if (!question.help.blank?)    
   
    # Check the type and format appropriatly
    case question.type
    when 'multiplechoice'
      contents += get_multiplechoice(question, level)
    when 'textbox'
      contents += get_textbox(question)
    when 'textfield'
      contents += get_textfield(question)
    when 'singlechoice'
      contents += get_singlechoice(question, level)
    when 'selectionbox'
      contents += get_selectionbox(question, level)
    else  
      raise("Unknown question type for question: #{question.question}")
    end
    # Draw a line to indicate the end of the question if level 1, 
    # i.e. not an answer sub question
    contents += content_tag(:div, "", :class => "questionbox") if (!contents.blank? and level <= 1)
    return contents   
  end
  
  private
  
    # Some answers to questions may have further questions, here we 
    # process these sub questions.
    #
    def process_sub_questions(answer, level)
      # Process any answer sub quesions by recursivly calling this function
      sq_contents = ""
      if (answer.respond_to?("subquestions") and 
        answer.subquestions and answer.subquestions.size > 0)
        answer.subquestions.each {|subquestion| sq_contents += 
          smerf_group_question(subquestion, level+1)}
        # Indent question
        sq_contents = "<div style=\"margin-left: #{level * 25}px;\">" + sq_contents + '</div>'       
      end
      return sq_contents
    end

    # Format multiple choice question
    #
    def get_multiplechoice(question, level)
      contents = ""
      question.answers.each do |answer|
        # Get the user input if available
        user_answer = nil
        if (@responses and !@responses.empty?() and 
          @responses.has_key?("#{question.code}") and
          @responses["#{question.code}"].has_key?("#{answer.code}"))
          user_answer = @responses["#{question.code}"]["#{answer.code}"]
        end
        # Note we wrap the form element in a label element, this allows the input
        # field to be selected by selecting the label, we could otherwise use a 
        # <lable for="....">...</label> construct to do the same
        html = '<label>' + check_box_tag("responses[#{question.code}][#{answer.code}]", answer.code, 
          # If user responded to the question and the value is the same as the question 
          # value then tick this checkbox
          ((user_answer and !user_answer.blank?() and user_answer.to_s() == answer.code.to_s()) or   
          # If this is a new record and no responses have been entered, i.e. this is the
          # first time the new record form is displayed set on if default 
          ((!@responses or @responses.empty?()) and params['action'] == 'show' and
          answer.default.upcase == 'Y'))) + 
          "#{answer.answer}</label>\n"
        contents += content_tag(:div, content_tag(:p, html), :class => "checkbox")
        # Process any sub questions this answer may have
        contents += process_sub_questions(answer, level)
      end
      # Process error messages if they exist
      #wrap_error(contents, (@errors and @errors.has_key?("#{question.code}")))
      #contents = content_tag(:div, contents, :class => "questionWithErrors") if (@errors and @errors.has_key?("#{question.code}"))
      return contents
    end

    # Format text box question
    #
    def get_textbox(question)
      # Get the user input if available
      user_answer = nil
      if (@responses and !@responses.empty?() and 
        @responses.has_key?("#{question.code}"))
        user_answer = @responses["#{question.code}"]
      end
      contents = text_area_tag("responses[#{question.code}]",    
        # Set value to user response if available
        if (user_answer and !user_answer.blank?())
          user_answer
        else
          nil
        end,
        :size => (!question.textbox_size.blank?) ? question.textbox_size : "30x5")
      contents = content_tag(:div, content_tag(:p, contents), :class => "textarea")
    end

    # Format text field question
    #
    def get_textfield(question)
      # Get the user input if available
      user_answer = nil
      if (@responses and !@responses.empty?() and 
        @responses.has_key?("#{question.code}"))
        user_answer = @responses["#{question.code}"]
      end
      contents = text_field_tag("responses[#{question.code}]", 
        # Set value to user responses if available
        if (user_answer and !user_answer.blank?())
          user_answer
        else
          nil
        end, 
        :size => (!question.textfield_size.blank?) ? question.textfield_size : "30")
      contents = content_tag(:div, content_tag(:p, contents), :class => "text")
    end

    # Format single choice question
    #
    def get_singlechoice(question, level)
      contents = ""
      question.answers.each do |answer|
        # Get the user input_objects if available
        user_answer = nil
        if (@responses and !@responses.empty?() and 
          @responses.has_key?("#{question.code}"))
          user_answer = @responses["#{question.code}"]
        end
        # Note we wrap the form element in a label element, this allows the input
        # field to be selected by selecting the label, we could otherwise use a 
        # <lable for="....">...</label> construct to do the same
        html = '<label>' + radio_button_tag("responses[#{question.code}]", answer.code,
          # If user responses then set on if answer available
          ((user_answer and !user_answer.blank?() and user_answer.to_s() == answer.code.to_s()) or   
          # If this is a new record and no response have been entered, i.e. this is the
          # first time the new record form is displayed set on if default 
          ((!@responses or @responses.empty?()) and params['action'] == 'show' and
          answer.default.upcase == 'Y'))) + 
          "#{answer.answer}</label>\n"
        contents += content_tag(:div, content_tag(:p, html), :class => "radiobutton")
        # Process any sub questions this answer may have
        contents += process_sub_questions(answer, level)
      end
      return contents
    end
 
    # Format drop down box(select) question
    #
    def get_selectionbox(question, level)
      # Note: This question type can not have subquestions      
      contents = ""
      answers = "\n"
      question.answers.each do |answer|
        # Get the user input if available
        user_answer = nil
        if (@responses and !@responses.empty?() and 
          @responses.has_key?("#{question.code}") and
          @responses["#{question.code}"].include?("#{answer.code}"))
          user_answer = answer.code
        end
        # Format answers
        answers += '<option ' + 
          # If user responses then set on if answer available
          (((user_answer and !user_answer.blank?() and user_answer.to_s() == answer.code.to_s()) or   
          # If this is a new record and no response have been entered, i.e. this is the
          # first time the new record form is displayed set on if default 
          ((!@responses or @responses.empty?() or !@responses.has_key?("#{question.code}")) and params['action'] == 'show' and
          answer.default.upcase == 'Y')) ?  ' selected="selected"' : '') 
        answers += ' value="' + answer.code.to_s() + '">' +       
          answer.answer + "</option>\n"
      end
        
      # Note the additional [] in the select_tag name, without this we only get 
      # one choice in params, adding the [] gets all choices as an array
      html = "\n" + select_tag("responses[#{question.code}][]", answers, :multiple => 
        # Check if multiple choice
        (question.selectionbox_multiplechoice and 
        !question.selectionbox_multiplechoice.blank?() and
        question.selectionbox_multiplechoice.upcase == 'Y'))
      contents += content_tag(:div, content_tag(:p, html), :class => "select")
      
      return contents
    end
   
    # Some questions/sub questions may not actually have any question text,
    # e.g. sub question. When an error occurs we want to display the text
    # of the question where the problem has occurred so this function will
    # try and find the question this object belongs to and display the question
    # text in the error message
    #
    def find_question_text(item_id)
      text = ""
      
      # Retrieve the object with the supplied ident         
      smerf_object = smerf_get_object(item_id, @smerfform.form)
      
      # Check if  we have reached the root level, if so return
      # an empty string
      return text if (smerf_object.parent_id == @smerfform.code)

      # Retrieve the owner object and see if it is a question, if not
      # we move up the object tree until a question is found with 
      # question text or we reach the root level
      smerf_owner_object = smerf_get_owner_object(smerf_object, @smerfform.form)      
      if (!smerf_owner_object.is_a?(SmerfQuestion) or
        smerf_owner_object.question.blank?())
        # Not a question, or no text for this question, recursivly call this function
        # moving up the tree until we reach the root level or a question with text
        # is found
        text = find_question_text(smerf_owner_object.item_id)
      else
        text = smerf_owner_object.question
      end
      
      return text.strip()
    end
end
