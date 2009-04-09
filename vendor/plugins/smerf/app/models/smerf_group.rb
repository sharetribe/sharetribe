# This class contains details about smerf form groups, it derives from
# SmerfItem.
# 
# Each form is divided up into groups of questions, you must have at least one 
# group per form. Here are the fields that are currently available when 
# defining a group:
#
# code:: This code must be unique for all groups within the form as it is used to identify each group (mandatory) 
# name:: The name of the group, this is displayed as the group heading (mandatory) 
# description:: Provide more detailed description/instructions for the group (optional) 
# questions:: Defines all the questions contained within this group (mandatory) 
#
# Here is the definition for the Personal Details group of the test form:
#
#     personal_details:
#       code: 1
#       name: Personal Details Group
#       description: | This is a brief description of the Personal Details Group
#         here we ask you some personal details ...
#       questions:
#       ...
#

class SmerfGroup < SmerfItem
  attr_accessor :code, :name, :description
  
  # A group object maintains any number of questions, here we alias the 
  # variable that stores the child objects to make code more readable
  alias :questions :child_items 
  
  def initialize(parent_id, sort_order_field)
    super(parent_id, sort_order_field)

    # Define group fields
    @fields = {
      'code'                      => {'mandatory' => 'Y'},
      'name'                      => {'mandatory' => 'Y'},
      'questions'                 => {'mandatory' => 'Y', 'child_items' => 'SmerfQuestion', 'sort_by' => 'sort_order'},
      'description'               => {'mandatory' => 'N'}
    }     
  end
end
  