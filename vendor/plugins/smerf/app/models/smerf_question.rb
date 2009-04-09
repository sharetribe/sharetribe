# This class contains details about form questions, it derives from
# SmerfItem.
# 
# A group can contain any number of questions, there must be at least one question 
# per group. When defining a question you must specify the question type, 
# the type determines the type of form field that will be created. 
# There are currently four types that can be used, this will be expanded as 
# needed. The current question types are:
#
# multiplechoice:: Allows the user to select all of the answers that apply from a 
#                  list of possible choices, check boxes are used for this question 
#                  type as multiple selections can be made 
# singlechoice:: Allows the user to select one answer from a list of possible choices, 
#                radio buttons are used for the question type as only a single answer 
#                can be selected 
# textbox:: Allows the user to enter a large amount of free text, the size of the 
#           text box can be specified 
# textfield:: Allows the user to enter a small amount of free form text, the size 
#             of the text field can be specified 
# selectionbox:: Allows the user to select one or more answers from a dropdown list 
#                of possible choices
# 
# The following fields can be used to define a question:
# 
# code:: Unique code that will identify the question, the code must be unique within 
#        a form (mandatory) 
# type:: Specifies the type of field that should be constructed on the form for 
#        this question, see above list for current types (mandatory) 
# question:: The text of the question, this field is optional as subquestions do 
#            not have to have question text 
# textbox_size:: Specifies the size of the text box to construct, rows x cols, 
#                defaults to 30x5 (optional) 
# textfield_size:: Specified the size of the text field that should be constructed, 
#                  specified in the number of visible characters, default to 30 (optional) 
# header:: Specifies a separate heading for the question. The text will be 
#          displayed above the question allowing questions to be broken up into 
#          subsections (optional) 
# sort_order:: Specifies the sort order for the question 
# help:: Help text that will be displayed below the question 
# answers:: Defines the answers to the question if the question type displays a 
#           list of possibilities to the user 
# validation:: Specifies the validation methods (comma separated) that should be 
#              executed for this question, see Validation and Errors section for 
#              more details
# selectionbox_multiplechoice:: Specifies if the dropdown box should allow multiple choices
#  
# Below is an example question definition:
# 
#       questions:
#         specify_your_age:
#           code: g1q1
#           type: singlechoice
#           sort_order: 1
#           question: | Specify your ages  
#           help: | Select the <b>one</b> that apply 
#           validation: validate_mandatory_question
#           ...
#

class SmerfQuestion < SmerfItem
  attr_accessor :code, :type, :question, :sort_order, :help, :textbox_size
  attr_accessor :textfield_size, :header, :validation, :selectionbox_multiplechoice    
  
  # A question object maintains any number of answers, here we alias the 
  # variable that stores the child objects to make code more readable
  alias :answers :child_items 
 
  def initialize(parent_id, sort_order_field)
    super(parent_id, sort_order_field)
    
    @fields = {
      'code'                        => {'mandatory' => 'Y'},
      'type'                        => {'mandatory' => 'Y', 'field_method' => 'check_question_type'},
      'question'                    => {'mandatory' => 'N'},
      'sort_order'                  => {'mandatory' => 'Y'},
      'help'                        => {'mandatory' => 'N'},
      'answers'                     => {'mandatory' => 'N', 'child_items' => 'SmerfAnswer', 'sort_by' => 'sort_order', 'unique_code_check' => 'parent'},
      'textbox_size'                => {'mandatory' => 'N'},
      'textfield_size'              => {'mandatory' => 'N'},
      'header'                      => {'mandatory' => 'N'},
      'selectionbox_multiplechoice' => {'mandatory' => 'N'},
      'validation'                  => {'mandatory' => 'N'},
    }
  end    
    
  protected
    
    # Additional validation method to make sure a valid question type
    # has been used
    #
    def check_question_type
      case @type
      when 'multiplechoice'
      when 'textbox'
      when 'singlechoice'
      when 'textfield'
      when 'selectionbox'
      else
        msg = "Invalid question type #{@type} specified"
        msg = msg + " for #{@data_id}" if (!@data_id.blank?)
        @form_object.error(self.class, msg)
      end
    end
end
