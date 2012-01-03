# from Demetrio Nunes
# Modified by Andy Singleton to use different GUID generator
#
# MIT License

require 'uuid22'

module ActiveRecord
  module Usesguid #:nodoc:
  
    def self.append_features(base)
      super
      base.extend(ClassMethods)  
    end

    
    module ClassMethods
      
      def usesguid(options = {})
                
        class_eval do
          set_primary_key options[:column] if options[:column]
          
          # don't implement directly in after_initialize.  If the model class defines
          # the after_initialize method, this one would be overwritten.  Instead use the
          # recommended practice of defining an empty after_initialize method and then
          # calling the custom code in a method declared with the after_initialize filter
          
          #def after_initialize; end
          
          after_initialize :set_uuid
          
          def set_uuid
            self.id ||= UUID.timestamp_create().to_s22
          end
        end        
        
      end
      
    end
  end
end

ActiveRecord::Base.class_eval do
  include ActiveRecord::Usesguid
end
