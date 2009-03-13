module Ym4r
  module GmPlugin 
    #Representing the Google Maps API class GMap2.
    class GMap
      include MappingObject
      
      #A constant containing the declaration of the VML namespace, necessary to display polylines under IE.
      VML_NAMESPACE = "xmlns:v=\"urn:schemas-microsoft-com:vml\""
      
      #The id of the DIV that will contain the map in the HTML page. 
      attr_reader :container
      
      #By default the map in the HTML page will be globally accessible with the name +map+.
      def initialize(container, variable = "map")
        @container = container
        @variable = variable
        @init = []
        @init_end = [] #for stuff that must be initialized at the end (controls)
        @init_begin = [] #for stuff that must be initialized at the beginning (center + zoom)
        @global_init = []
      end

      #Deprecated. Use the static version instead.
      def header(with_vml = true)
        GMap.header(:with_vml => with_vml)
      end

      #Outputs the header necessary to use the Google Maps API, by including the JS files of the API, as well as a file containing YM4R/GM helper functions. By default, it also outputs a style declaration for VML elements. This default can be overriddent by passing <tt>:with_vml => false</tt> as option to the method. You can also pass a <tt>:host</tt> option in order to select the correct API key for the location where your app is currently running, in case the current environment has multiple possible keys. Usually, in this case, you should pass it <tt>@request.host</tt>. If you have defined only one API key for the current environment, the <tt>:host</tt> option is ignored. Finally you can override all the key settings in the configuration by passing a value to the <tt>:key</tt> key. You can pass a language for the map type buttons with the <tt>:hl</tt> option (possible values are: Japanese (ja), French (fr), German (de), Italian (it), Spanish (es), Catalan (ca), Basque (eu) and Galician (gl): no values means english). Finally, you can pass <tt>:local_search => true</tt> to get the header css and js information needed for the local search control. If you do want local search you must also add <tt>:local_search => true</tt> to the @map.control_init method.
      def self.header(options = {})
        options[:with_vml] = true unless options.has_key?(:with_vml)
        options[:hl] ||= ''
        options[:local_search] = false unless options.has_key?(:local_search)
        api_key = ApiKey.get(options)
        a = "<script src=\"http://maps.google.com/maps?file=api&amp;v=2.x&amp;key=#{api_key}&amp;hl=#{options[:hl]}\" type=\"text/javascript\"></script>\n"
        a << "<script src=\"#{ActionController::Base.relative_url_root}/javascripts/ym4r-gm.js\" type=\"text/javascript\"></script>\n" unless options[:without_js]
        a << "<style type=\"text/css\">\n v\:* { behavior:url(#default#VML);}\n</style>" if options[:with_vml]
        a << "<script src=\"http://www.google.com/uds/api?file=uds.js&amp;v=1.0\" type=\"text/javascript\"></script>" if options[:local_search]
        a << "<script src=\"http://www.google.com/uds/solutions/localsearch/gmlocalsearch.js\" type=\"text/javascript\"></script>\n" if options[:local_search]
        a << "<style type=\"text/css\">@import url(\"http://www.google.com/uds/css/gsearch.css\");@import url(\"http://www.google.com/uds/solutions/localsearch/gmlocalsearch.css\");}</style>" if options[:local_search]
        a
      end
     
      #Outputs the <div id=...></div> which has been configured to contain the map. You can pass <tt>:width</tt> and <tt>:height</tt> as options to output this in the style attribute of the DIV element (you could also achieve the same effect by putting the dimension info into a CSS or using the instance method GMap#header_width_height). You can aslo pass <tt>:class</tt> to set the classname of the div.
      def div(options = {})
        attributes = "id=\"#{@container}\" "
        if options.has_key?(:height) && options.has_key?(:width)
          width = options.delete(:width)
          if width.is_a?(Integer) or width =~ /^[0-9]+$/
            width = width.to_s + "px"
          end
          height = options.delete(:height)
          if height.is_a?(Integer) or height =~ /^[0-9]+$/
            height = height.to_s + "px"
          end
          attributes += "style=\"width:#{width};height:#{height}\" "
        end
        if options.has_key?(:class)
          attributes += options.keys.map {|opt| "#{opt}=\"#{options[opt]}\"" }.join(" ")
        end
        "<div #{attributes}></div>"
      end

      #Outputs a style declaration setting the dimensions of the DIV container of the map. This info can also be set manually in a CSS.
      def header_width_height(width,height)
        "<style type=\"text/css\">\n##{@container} { height: #{height}px;\n  width: #{width}px;\n}\n</style>"
      end

      #Records arbitrary JavaScript code and outputs it during initialization inside the +load+ function.
      def record_init(code)
        @init << code
      end

      #Initializes the controls: you can pass a hash with keys <tt>:small_map</tt>, <tt>:large_map</tt>, <tt>:small_zoom</tt>, <tt>:scale</tt>, <tt>:map_type</tt>, <tt>:overview_map</tt> and a boolean value as the value (usually true, since the control is not displayed by default), <tt>:local_search</tt> and <tt>:local_search_options</tt>
      def control_init(controls = {})
        @init_end << add_control(GSmallMapControl.new) if controls[:small_map]
        @init_end << add_control(GLargeMapControl.new) if controls[:large_map]
        @init_end << add_control(GSmallZoomControl.new) if controls[:small_zoom]
        @init_end << add_control(GScaleControl.new) if controls[:scale]
        @init_end << add_control(GMapTypeControl.new) if controls[:map_type]
        @init_end << add_control(GHierarchicalMapTypeControl.new) if controls[:hierarchical_map_type]        
        @init_end << add_control(GOverviewMapControl.new) if controls[:overview_map]
        @init_end << add_control(GLocalSearchControl.new(controls[:anchor], controls[:offset_width], controls[:offset_height], controls[:local_search_options])) if controls[:local_search]
      end
      
      #Initializes the interface configuration: double-click zoom, dragging, continuous zoom,... You can pass a hash with keys <tt>:dragging</tt>, <tt>:info_window</tt>, <tt>:double_click_zoom</tt>, <tt>:continuous_zoom</tt> and <tt>:scroll_wheel_zoom</tt>. The values should be true or false. Check the google maps API doc to know what the default values are.
      def interface_init(interface = {})
        if !interface[:dragging].nil?
          if interface[:dragging]
             @init << enableDragging() 
          else
            @init << disableDragging() 
          end
        end
        if !interface[:info_window].nil?
          if interface[:info_window]
            @init << enableInfoWindow()
          else
            @init << disableInfoWindow()
          end
        end
        if !interface[:double_click_zoom].nil?
          if interface[:double_click_zoom]
            @init << enableDoubleClickZoom()
          else
            @init << disableDoubleClickZoom()
          end
        end
        if !interface[:continuous_zoom].nil?
          if interface[:continuous_zoom]
            @init << enableContinuousZoom()
          else
            @init << disableContinuousZoom()
          end
        end
        if !interface[:scroll_wheel_zoom].nil?
          if interface[:scroll_wheel_zoom]
            @init << enableScrollWheelZoom()
          else
            @init << disableScrollWheelZoom()
          end
        end
      end

      #Initializes the initial center and zoom of the map. +center+ can be both a GLatLng object or a 2-float array.
      def center_zoom_init(center, zoom)
        if center.is_a?(GLatLng)
          @init_begin << set_center(center,zoom)
        else
          @init_begin << set_center(GLatLng.new(center),zoom)
        end
      end

      #Center and zoom based on the coordinates passed as argument (either 2D arrays or GLatLng objects)
      def center_zoom_on_points_init(*points)
        if(points.length > 0)
          if(points[0].is_a?(Array))
            points = points.collect { |point| GLatLng.new(point) }
          end
          @init_begin << center_and_zoom_on_points(points)
        end
      end

      #Center and zoom based on the bbox corners. Pass a GLatLngBounds object, an array of 2D coordinates (sw and ne) or an array of GLatLng objects (sw and ne).
      def center_zoom_on_bounds_init(latlngbounds)
        if(latlngbounds.is_a?(Array))
          if latlngbounds[0].is_a?(Array)
            latlngbounds = GLatLngBounds.new(GLatLng.new(latlngbounds[0]),GLatLng.new(latlngbounds[1]))
          elsif latlngbounds[0].is_a?(GLatLng)
            latlngbounds = GLatLngBounds.new(*latlngbounds)
          end
        end
        #else it is already a latlngbounds object

        @init_begin << center_and_zoom_on_bounds(latlngbounds)
      end

      #Initializes the map by adding an overlay (marker or polyline).
      def overlay_init(overlay)
        @init << add_overlay(overlay)
      end

      #Sets up a new map type. If +add+ is false, all the other map types of the map are wiped out. If you want to access the map type in other methods, you should declare the map type first (with +declare_init+).
      def add_map_type_init(map_type, add = true)
        unless add
          @init << get_map_types.set_property(:length,0)
        end
        @init << add_map_type(map_type)
      end
      #for legacy purpose
      alias :map_type_init :add_map_type_init

      #Sets the map type displayed by default after the map is loaded. It should be known from the map (ie either the default map types or a user-defined map type added with <tt>add_map_type_init</tt>). Use <tt>set_map_type_init(GMapType::G_SATELLITE_MAP)</tt> or <tt>set_map_type_init(GMapType::G_HYBRID_MAP)</tt> to initialize the map with repsecitvely the Satellite view and the hybrid view.
      def set_map_type_init(map_type)
        @init << set_map_type(map_type)
      end

      #Locally declare a MappingObject with variable name "name"
      def declare_init(variable, name)
        @init << variable.declare(name)
      end

      #Records arbitrary JavaScript code and outputs it during initialization outside the +load+ function (ie globally).
      def record_global_init(code)
        @global_init << code
      end
      
      #Deprecated. Use icon_global_init instead.
      def icon_init(icon , name)
        icon_global_init(icon , name)
      end
      
      #Initializes an icon  and makes it globally accessible through the JavaScript variable of name +variable+.
      def icon_global_init(icon , name, options = {})
        declare_global_init(icon,name,options)
      end

      #Registers an event
      def event_init(object,event,callback)
        @init << "GEvent.addListener(#{object.to_javascript},\"#{MappingObject.javascriptify_method(event.to_s)}\",#{callback});"
      end

      #Registers an event globally
      def event_global_init(object,event,callback)
        @global_init << "GEvent.addListener(#{object.to_javascript},\"#{MappingObject.javascriptify_method(event.to_s)}\",#{callback});"
      end
      
      #Declares the overlay globally with name +name+
      def overlay_global_init(overlay,name, options = {})
        declare_global_init(overlay,name, options)
        @init << add_overlay(overlay)
      end

      #Globally declare a MappingObject with variable name "name". Option <tt>:local_construction</tt> should be passed if the construction has to be done inside the onload callback method (for exsample if it depends on the GMap to be initialized)
      def declare_global_init(variable,name, options = {})
        unless options[:local_construction]
          @global_init << "var #{variable.assign_to(name)}"
        else
          @global_init << "var #{name};"
          @init << variable.assign_to(name)
        end
      end
      
      #Outputs the initialization code for the map. By default, it outputs the script tags, performs the initialization in response to the onload event of the window and makes the map globally available. If you pass +true+ to the option key <tt>:full</tt>, the map will be setup in full screen, in which case it is not necessary (but not harmful) to set a size for the map div.
      def to_html(options = {})
        no_load = options[:no_load]
        no_script_tag = options[:no_script_tag]
        no_declare = options[:no_declare]
        no_global = options[:no_global]
        fullscreen = options[:full]
        load_pr = options[:proto_load] #to prevent some problems when the onload event callback from Prototype is used
        
        html = ""
        html << "<script type=\"text/javascript\">\n" if !no_script_tag
        #put the functions in a separate javascript file to be included in the page
        html << @global_init * "\n"
        html << "var #{@variable};\n" if !no_declare and !no_global
        if !no_load
          if load_pr
            html << "Event.observe(window,'load',"
          else
            html << "window.onload = addCodeToFunction(window.onload,"
          end
          html << "function() {\n"
        end

        html << "if (GBrowserIsCompatible()) {\n" 
        
        if fullscreen
          #Adding the initial resizing and setting up the event handler for
          #future resizes
          html << "setWindowDims(document.getElementById('#{@container}'));\n"
          html << "if (window.attachEvent) { window.attachEvent(\"onresize\", function() {setWindowDims(document.getElementById('#{@container}'));})} else {window.addEventListener(\"resize\", function() {setWindowDims(document.getElementById('#{@container}')); } , false);}\n"
        end
      
        if !no_declare and no_global 
          html << "#{declare(@variable)}\n"
        else
          html << "#{assign_to(@variable)}\n"
        end
        html << @init_begin * "\n"
        html << @init * "\n"
        html << @init_end * "\n"
        html << "\n}\n"
        html << "});\n" if !no_load
        html << "</script>" if !no_script_tag
        
        if fullscreen
          #setting up the style in case of full screen
          html << "<style>html, body {width: 100%; height: 100%} body {margin-top: 0px; margin-right: 0px; margin-left: 0px; margin-bottom: 0px} ##{@container} {margin:  0px;} </style>"
        end
        
        html
      end
      
      #Outputs in JavaScript the creation of a GMap2 object 
      def create
        "new GMap2(document.getElementById(\"#{@container}\"))"
      end
    end
  end
end

