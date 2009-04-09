# This class contains details about the form, it derives from SmerfItem.
#
# When setting up a new form the first thing we do is define some settings for 
# the form as a whole. Currently the following items can be defined for the form:
#
# name:: Name of the form (mandatory) 
# welcome:: Message displayed at the start of the form (optional) 
# thank_you:: Message displayed at the end of the form (optional) 
# group_sort_order_field:: Nominates which group field to use when sorting groups 
#                          for display (mandatory) 
# groups:: Defines the question groups within the form (mandatory) 
#
# Here is the definition for the test form included with the plugin:
#
#    --- 
#    smerfform:   
#      name: Test SMERF Form
#      welcome: | 
#        <b>Welcome:</b><br>
#        Thank you for taking part in our Test survey we appreciate your
#        input.<br><br>
#
#        <b>PRIVACY STATEMENT</b><br>
#        We will keep all the information you provide private and not share
#        it with anyone else....<br>
#
#      thank_you: | 
#        <b>Thank you for your input.</b><br><br>
#
#        Should you wish to discuss this survey please contact<br>
#        Joe Bloggs<br>
#        Tel. 12 345 678<br>
#        e-mail <A HREF=\"mailto:jbloggs@xyz.com.au\">Joe's email</A><br><br>
#
#        February 2007
#      group_sort_order_field: code
#
#      groups:
#      ...
#

class SmerfMetaForm < SmerfItem

  attr_accessor :code, :name, :welcome, :thank_you, :code
  
  # Hash that stores the item id and a reference to the object, this 
  # allows us to easily find objects using the item id
  attr_accessor :item_index
  
  # The form object maintains question groups, here we alias the 
  # variable that stores the child objects to make code more readable
  alias :groups :child_items 
  
  # Error hash
  attr_accessor :errors
  
  # Most items within a form are uniquely identified by the value assigned
  # to the code field. Some items need to have unique codes for the complete
  # form, other need to be unique within a particular parent (e.g. answers 
  # for a particular question). We store codes that are to be unique for 
  # a form in this hash so we can easily check it once all form data has
  # been processed
  attr_accessor :class_item_codes
  
  def initialize(code)
    super('','')
    
    @code = code
    @errors = Hash.new()
    @class_item_codes = Hash.new()
    @item_index = Hash.new()
    
    # Define form fields
    @fields = {
      'name'                    => {'mandatory' => 'Y'},
      'welcome'                 => {'mandatory' => 'N'},
      'thank_you'               => {'mandatory' => 'N'},
      'groups'                  => {'mandatory' => 'Y', 'child_items' => 'SmerfGroup'},
      'group_sort_order_field'  => {'mandatory' => 'Y', 'sort_field' => 'Y'}
    }
    
  end
  
  # Method to process data
  def process(data, form_object)
    super(data, form_object)
    
    # Remove variables we do not need to save to DB
    remove_instance_variable(:@class_item_codes)
  end

  # Method adds error message to error array
  def error(attribute, msg)
    @errors[attribute.to_s] = [] if @errors[attribute.to_s].nil?
    @errors[attribute.to_s] << msg
  end   

  # This method will add the specified code to the hash, it will return
  # false if the code already exists for the specified class
  def class_item_code(classname, code, parent='')
    @class_item_codes[classname.to_s] = Hash.new() if (!@class_item_codes.has_key?(classname.to_s))
    if (parent.blank?)
      return false if (@class_item_codes[classname.to_s].has_key?(code.to_s))
      @class_item_codes[classname.to_s][code.to_s] = '1'
    else
      @class_item_codes[classname.to_s][parent.to_s] = Hash.new() if (!@class_item_codes[classname.to_s].has_key?(parent.to_s))
      return false if (@class_item_codes[classname.to_s][parent.to_s].has_key?(code.to_s))
      @class_item_codes[classname.to_s][parent.to_s][code.to_s] = '1'
    end
    return true    
  end   
  
end