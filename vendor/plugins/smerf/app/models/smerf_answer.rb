# This class contains details about answers to form questions, it derives from
# SmerfItem.
# 
# It knows how to handle subquestions. Subquestions are additional questions
# that a user can answer if certain answers are selected. An example subquestion
# would be where an <em>Other</em> is provided as one of the answers to a question,
# a subquestion can be defined to display a text field to accept more information.
#
# Question answers are defined using the following fields:
# 
# code:: Code to uniquely identify the answer, code needs to be unique for each 
#        question (mandatory). The value specified here will be saved as the 
#        users response when the answer is selected.
# answer:: The text that will be displayed to the user (mandatory) 
# default:: If set to Y then this answer will be selected by default (optional) 
# sort_order:: The sort order for this answer (mandatory) 
# subquestions:: Some answers may need additional information, another question 
#                can be defined to obtain this information. To define a subquestion 
#                the same fields that define a normal question is used (optional) 
#
# Here is an example answer definition:
#
#      answers:
#        1_20:
#          code: 1
#          answer: | 1-20
#          sort_order: 1
#          default: N
#          ...
#

class SmerfAnswer < SmerfItem
  attr_accessor :code, :answer, :default, :sort_order 
  
  # A answer object maintains any number of sub-questions, here we alias the 
  # variable that stores the child objects to make code more readable
  alias :subquestions :child_items 
 
  def initialize(parent_id, sort_order_field)
    super(parent_id, sort_order_field)
    
    @fields = {
      'code'                      => {'mandatory' => 'Y'},
      'answer'                    => {'mandatory' => 'Y'},
      'default'                   => {'mandatory' => 'Y'},
      'sort_order'                => {'mandatory' => 'Y'},
      'subquestions'              => {'mandatory' => 'N', 'child_items' => 'SmerfQuestion', 'sort_by' => 'sort_order'}
    }  
  end
    
end
