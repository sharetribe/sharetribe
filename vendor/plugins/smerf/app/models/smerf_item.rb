# SmerfItem class is a base class used by all other smerf classes
# and contains shared functionality.
# 
# Derived classes include:
# 
# * SmerfMetaForm
# * SmerfGroup
# * SmerfQuestion
# * SmerfAnswer
#

class SmerfItem
  
  attr_accessor :child_items, :data_id, :item_id, :parent_id 
  
  def initialize(parent_id='', sort_order_field='')
    
    # Item id of the owner of this item
    @parent_id = parent_id
    # Init this items id
    @item_id = ''
    # Name of the field used for sorting this item
    @sort_order_field = sort_order_field
    
    # Items may have child items, a form has groups, groups have questions
    # and so on, this hash stores the field name and the class name for these 
    # child items, e.g. field name = groups, class name = SmerfGroup
    @child_item_fields ||= Hash.new()
    
    # This hash stores the field to be used to sort child items, the field
    # must be one of the ones used to define the child item. For example,
    # if we want to sort groups by the group name we would  set the 
    # group_sort_order_field to name
    @child_item_sort_order_fields ||= Hash.new()
    
    # Most items within a form are uniquely identified by the value assigned
    # to the code field. Some items need to have unique codes for the complete
    # form, other need to be unique within a particular parent (e.g. answers 
    # for a particular question).
    @unique_code_check ||= 'form'
    
    # Hash that contains all the fields used to define each item. The items in 
    # this array is defined in the derived class for example SmerfGroup
    @fields ||= Hash.new()
    
    # Array holds all child item objects for this item, e.g. for a group
    # item it will contain all the questions that belong to the group
    @child_items ||= Array.new()
    
    # Variable that hold the SmerfMetaForm object
    @form_object ||= nil
    
    # Variables used to store the decoded data passed to this item
    # for processing
    @data ||= nil
    @data_id ||= ''
    
  end
  
  # Method to process data
  def process(data, form_object)
    @form_object = form_object   
    
    if (!data.blank?)  
      # Decode the data
      decode_data(data)
      
      # Check and make sure all fields that define this item in the form
      # definition file is correct 
      check_item_fields()
      
      # If this item is to be sorted make sure the field used for
      # sorting exists
      check_sort_order_field()
      
      # Create a unique id for this object
      @item_id = get_item_id()

      # Process child items if required
      process_child_items() 

      # Remove any variables that we do not want to save to the DB
      cleanup()
      
      # Add the object to the item_index hash
      @form_object.item_index[@item_id.to_s] = self
    end
  end
  
  
  private
  
    # Decode the data
    def decode_data(data)
      return if (data.blank?)
      if (data.kind_of?(Hash) and data.has_key?('smerfform') and !data['smerfform'].blank?)
        @data = data['smerfform']
        @data_id = 'smerfform'
      elsif (data.kind_of?(Array) and data.size == 2)
        @data = data[1]
        @data_id = data[0]
      end      
      if (@data.blank?)
        msg = "Invalid data found"
        msg +=" for #{@data_id}" if (!@data_id.blank?)
        raise(msg)
      end
    end

    # This method receives a hash that contains the data for the item as retrieved
    # from the form definition file. We use the array that contains the fields 
    # that define this item and make sure they have been specified correctly.
    def check_item_fields
      # Process each field for this item
      @fields.each do |field, options| 
        # If manadatory make sure it exists and a value have been defined        
        rc = true       
        rc = check_mandatory(field) if (options.has_key?('mandatory') and options['mandatory'] == 'Y')
        
        # Check if this field contains child items, if so add to hash        
        @child_item_fields[field] = options['child_items'] if (options.has_key?('child_items') and 
            !options['child_items'].blank?)

        # Some child items are sorted by a field specified in the form definition 
        # file (e.g. groups), others such as questions are sorted by a fixed 
        # sort order field (i.e. sort_order)
        if (rc == true and options.has_key?('sort_field') and options['sort_field'] == 'Y')
          @child_item_sort_order_fields = @data[field] 
        elsif (@child_item_sort_order_fields.kind_of?(Hash) and 
          options.has_key?('sort_by') and !options['sort_by'].blank?)
          @child_item_sort_order_fields[field] = options['sort_by'] 
        end
        
        # Get the method to use when checking for duplicate codes 
        @unique_code_check = options['unique_code_check'] if (options.has_key?('unique_code_check') and 
            !options['unique_code_check'].blank?)
        
        # Create an instance variable for the field and set to nil
        instance_variable_set("@#{field}", nil)
        
        # If the field exists then we set the instance variable for that field.
        # For example we define 'code' as a field, here we extract the value for
        # code and assign it to @code which is the instance variable for code.
        if (rc == true and !@data.blank?() and @data.has_key?(field) and !@data[field].blank?)
          instance_variable_set("@#{field}", @data[field])
          
          # Check if a method has been defined for this field, if so call it now
          if (options.has_key?('field_method') and !options['field_method'].blank? and
            self.respond_to?(options['field_method']))
            # Call the function
            self.send(options['field_method'])
          end                
        end        
      end
    end

    # The method checks the form definition file data to see if the specified 
    # field exists, it also checks to see if a value has been specified for the 
    # field. 
    def check_mandatory(field)
      if (@data.blank?() or !@data.has_key?(field) or @data[field].blank?)        
        msg = "No '#{field}' specified"
        msg += " for #{@data_id}" if (!@data_id.blank?)
        @form_object.error(self.class, msg)
        return false
      end
      return true
    end
    
    # If this item is to be sorted make sure that the field that will be used
    # for sorting actually exists, e.g. if groups are to be sorted by name
    # we want to make sure that the name field exists and has a value
    def check_sort_order_field
      if (!@sort_order_field.blank? and 
        (@data.blank?() or !@data.has_key?(@sort_order_field) or @data[@sort_order_field].blank?))
        msg = "Specified sort order field '#{@sort_order_field}' could not be found"
        msg += " for #{@data_id}" if (!@data_id.blank?)
        @form_object.error(self.class, msg)
      end
    end

    # This method will create and process any child items that belong to this
    # item. for example if we are processing a group then the group will contain
    # a number of questions.
    def process_child_items
      @child_item_fields.each do |field, classname| 
        process_child_item(field, classname)
        # Check to make sure all child item sort fields are present and correct
        # if any problems found do not sort. If for example the definition file
        # has a question that do not have the sort_order field defined then
        # an obscure error will be generated as the sort will fail.
        rc = false
        @child_items.each do |item| 
          rc = (item.respond_to?(sort_field(field)) and 
            item.send(sort_field(field)).blank?) if (rc == false)            
        end        
        # Sort the child items if required
        @child_items = @child_items.sort {
          |a, b| eval("a.#{sort_field(field)}<=>b.#{sort_field(field)}")          
          } if (rc == false and @child_items.size > 0 and !sort_field(field).blank?)
      end
    end

    # Create a new object for the child item using the class name given to us, 
    # then process the new child item.
    def process_child_item(field, classname)
      return if (!@data.has_key?(field) or @data[field].blank?)
      @data[field].each do |child_item_data|
        # Create a new child object using the class name passed to us
        child_item = Object.const_get(classname).new(@item_id, sort_field(field)) 
        # Process the new child item
        child_item.process(child_item_data, @form_object)
        # We store all child objects in an array, add new object to array         
        @child_items << child_item        
        # Check for duplicate codes
        check_duplicate_codes(child_item)
      end
    end
    
    # This method creates a unique id for this item, which is a combination 
    # of onwer_id and this objects unique code     
    def get_item_id
      code = self.send('code') if (self.respond_to?('code'))
      @item_id = (@parent_id and !code.blank?) ? "#{@parent_id}~~#{code}" : "#{@form_object.code}"       
    end
    
    # This method checks for duplicate code values. We uniquely ID each item
    # (group, question, ...) using a code.
    def check_duplicate_codes(object)
      # Get the code for the item given to us
      child_item_code = ''
      child_item_code = object.send('code') if (object.respond_to?('code'))
      return if (child_item_code.blank?)
      # Get the code for this item which is the parent
      code = ''
      code = self.send('code') if (self.respond_to?('code') and @unique_code_check == 'parent')
      # Check if the code already exists, if the code check = 'parent' then we make
      # sure the code is unique within the parent (e.g. answers within questions)
      # otherwise the check is made form wide, all group codes need to be unique
      # for a form for example
      if (!@form_object.class_item_code(object.class.to_s, child_item_code, code))
        msg = "Duplicate 'code' found for #{object.class.to_s}"
        msg += " (#{object.data_id})" if (!object.data_id.blank?)
        msg += " in #{@data_id}" if (!@data_id.blank?)
        @form_object.error(self.class, msg)
      end
    end  

    # The sort order for items can be specified in the form definition file as
    # is the case with groups or they are fixed as it the case with questions
    # where the sort_order field is the field used for sorting. Here we decide
    # which field to use.
    def sort_field(field)
      (@child_item_sort_order_fields.kind_of?(Hash)) ? 
        @child_item_sort_order_fields[field] : @child_item_sort_order_fields      
    end
    
    # Cleanup all vars that do not need to be saved to the DB
    def cleanup
      remove_instance_variable(:@data)
      remove_instance_variable(:@data_id)
      remove_instance_variable(:@sort_order_field)
      remove_instance_variable(:@child_item_fields)
      remove_instance_variable(:@child_item_sort_order_fields)
      remove_instance_variable(:@unique_code_check)       
      remove_instance_variable(:@fields)
    end
    
end
