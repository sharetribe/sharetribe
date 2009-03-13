module Ym4r
  module GmPlugin
    #The module where all the Ruby-to-JavaScript conversion takes place. It is included by all the classes in the YM4R library.
    module MappingObject
      #The name of the variable in JavaScript space.
      attr_reader :variable
      
      #Creates javascript code for missing methods + takes care of listeners
      def method_missing(name,*args)
        str_name = name.to_s
        if str_name =~ /^on_(.*)/
          if args.length != 1
            raise ArgumentError("Only 1 argument is allowed on on_ methods");
          else
            Variable.new("GEvent.addListener(#{to_javascript},\"#{MappingObject.javascriptify_method($1)}\",#{args[0]})")
          end
        else
          args.collect! do |arg|
            MappingObject.javascriptify_variable(arg)
          end
          Variable.new("#{to_javascript}.#{MappingObject.javascriptify_method(str_name)}(#{args.join(",")})")
        end
      end
            
      #Creates javascript code for array or hash indexing
      def [](index) #index could be an integer or string
        return Variable.new("#{to_javascript}[#{MappingObject.javascriptify_variable(index)}]")
      end

      #Transforms a Ruby object into a JavaScript string : MAppingObject, String, Array, Hash and general case (using to_s)
      def self.javascriptify_variable(arg)
        if arg.is_a?(MappingObject)
          arg.to_javascript
        elsif arg.is_a?(String)
          "\"#{MappingObject.escape_javascript(arg)}\""
        elsif arg.is_a?(Array)
          "[" + arg.collect{ |a| MappingObject.javascriptify_variable(a)}.join(",") + "]"
        elsif arg.is_a?(Hash)
          "{" + arg.to_a.collect do |v|
            "#{MappingObject.javascriptify_method(v[0].to_s)} : #{MappingObject.javascriptify_variable(v[1])}"
          end.join(",") + "}"
        elsif arg.nil?
          "undefined"
        else
          arg.to_s
        end
      end
      
      #Escape string to be used in JavaScript. Lifted from rails.
      def self.escape_javascript(javascript)
        javascript.gsub(/\r\n|\n|\r/, "\\n").gsub("\"") { |m| "\\#{m}" }
      end
      
      #Transform a ruby-type method name (like add_overlay) to a JavaScript-style one (like addOverlay).
      def self.javascriptify_method(method_name)
        method_name.gsub(/_(\w)/){|s| $1.upcase}
      end
      
      #Declares a Mapping Object bound to a JavaScript variable of name +variable+.
      def declare(variable)
        @variable = variable
        "var #{@variable} = #{create};"
      end

      #declare with a random variable name
      def declare_random(init,size = 8)
        s = init.clone
        6.times { s << (i = Kernel.rand(62); i += ((i < 10) ? 48 : ((i < 36) ? 55 : 61 ))).chr }
        declare(s)
      end

      #Checks if the MappinObject has been declared
      def declared?
        !@variable.nil?
      end
      
      #Binds a Mapping object to a previously declared JavaScript variable of name +variable+.
      def assign_to(variable)
        @variable = variable
        "#{@variable} = #{create};"
      end

      #Assign the +value+ to the +property+ of the MappingObject
      def set_property(property, value)
        "#{to_javascript}.#{MappingObject.javascriptify_method(property.to_s)} = #{MappingObject.javascriptify_variable(value)}"
      end

      #Returns the code to get a +property+ from the MappingObject
      def get_property(property)
        Variable.new("#{to_javascript}.#{MappingObject.javascriptify_method(property.to_s)}")
      end
      
      #Returns a Javascript code representing the object
      def to_javascript
        unless @variable.nil?
          @variable
        else
          create
        end
      end
      
      #Creates a Mapping Object in JavaScript.
      #To be implemented by subclasses if needed
      def create
      end
    end

    #Used to bind a ruby variable to an already existing JavaScript one. It doesn't have to be a variable in the sense "var variable" but it can be any valid JavaScript expression that has a value.
    class Variable
      include MappingObject
      
      def initialize(variable)
        @variable = variable
      end
      #Returns the javascript expression contained in the object.
      def create
        @variable
      end
      #Returns the expression inside the Variable followed by a ";"
      def to_s
        @variable + ";"
      end

      UNDEFINED = Variable.new("undefined")
    end
  end
end

