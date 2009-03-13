module Ym4r
  module GmPlugin
    #A graphical marker positionned through geographic coordinates (in the WGS84 datum). An HTML info window can be set to be displayed when the marker is clicked on.
    class GMarker
      include MappingObject
      attr_accessor :point, :options, :info_window, :info_window_tabs, :address
      #The +points+ argument can be either a GLatLng object or an array of 2 floats. The +options+ keys can be: <tt>:icon</tt>, <tt>:clickable</tt>, <tt>:title</tt>, <tt>:info_window</tt> and <tt>:info_window_tabs</tt>, as well as <tt>:max_width</tt>. The value of the +info_window+ key is a string of HTML code that will be displayed when the markers is clicked on. The value of the +info_window_tabs+ key is an array of GInfoWindowTab objects or a hash directly, in which case it will be transformed to an array of GInfoWindowTabs, with the keys as the tab headers and the values as the content.
      def initialize(position, options = {})
        if position.is_a?(Array)
          @point = GLatLng.new(position)
        elsif position.is_a?(String)
          @point = Variable.new("INVISIBLE") #default coordinates: won't appear anyway
          @address = position
        else
          @point = position
        end
        @info_window = options.delete(:info_window)
        @info_window_tabs = options.delete(:info_window_tabs)
        if options.has_key?(:max_url)
          @info_window_options = {:max_url => options.delete(:max_url) } 
        else
          @info_window_options = {}
        end
        @options = options
      end
      #Creates a marker: If an info_window or info_window_tabs is present, the response to the click action from the user is setup here.
      def create
        if @options.empty?
          creation = "new GMarker(#{MappingObject.javascriptify_variable(@point)})"
        else
          creation = "new GMarker(#{MappingObject.javascriptify_variable(@point)},#{MappingObject.javascriptify_variable(@options)})"
        end
        if @info_window && @info_window.is_a?(String)
          creation = "addInfoWindowToMarker(#{creation},#{MappingObject.javascriptify_variable(@info_window)},#{MappingObject.javascriptify_variable(@info_window_options)})"
        elsif @info_window_tabs && @info_window_tabs.is_a?(Hash)
          creation = "addInfoWindowTabsToMarker(#{creation},#{MappingObject.javascriptify_variable(@info_window_tabs.to_a.collect{|kv| GInfoWindowTab.new(kv[0],kv[1] ) })},#{MappingObject.javascriptify_variable(@info_window_options)})"
        elsif @info_window_tabs 
          creation = "addInfoWindowTabsToMarker(#{creation},#{MappingObject.javascriptify_variable(Array(@info_window_tabs))},#{MappingObject.javascriptify_variable(@info_window_options)})"
        end
        if @address.nil?
          creation
        else
          "addGeocodingToMarker(#{creation},#{MappingObject.javascriptify_variable(@address)})"
        end
      end
    end
    
    #Represents a tab to be displayed in a bubble when a marker is clicked on.
    class GInfoWindowTab < Struct.new(:tab,:content)
      include MappingObject
      def create
        "new GInfoWindowTab(#{MappingObject.javascriptify_variable(tab)},#{MappingObject.javascriptify_variable(content)})"
      end
    end
        
    #Represents a definition of an icon. You can pass rubyfied versions of the attributes detailed in the Google Maps API documentation. You can initialize global icons to be used in the application by passing a icon object, along with a variable name, to GMap#icon_init. If you want to declare an icon outside this, you will need to declare it first, since the JavaScript constructor does not accept any argument.
    class GIcon
      include MappingObject
      DEFAULT = Variable.new("G_DEFAULT_ICON")
      attr_accessor :options, :copy_base

      #Options can contain all the attributes (in rubyfied format) of a GIcon object (see Google's doc), as well as <tt>:copy_base</tt>, which indicates if the icon is copied from another one.
      def initialize(options = {})
        @copy_base = options.delete(:copy_base)
        @options = options
      end
      #Creates a GIcon.
      def create
        if @copy_base
          c = "new GIcon(#{MappingObject.javascriptify_variable(@copy_base)})"
        else
          c = "new GIcon()"
        end
        if !options.empty?
          "addOptionsToIcon(#{c},#{MappingObject.javascriptify_variable(@options)})"
        else
          c
        end
      end
    end
     
    #A polyline.
    class GPolyline
      include MappingObject
      attr_accessor :points,:color,:weight,:opacity
      #Can take an array of +GLatLng+ or an array of 2D arrays. A method to directly build a polyline from a GeoRuby linestring is provided in the helper.rb file.
      def initialize(points,color = nil,weight = nil,opacity = nil)
        if !points.empty? and points[0].is_a?(Array)
          @points = points.collect { |pt| GLatLng.new(pt) }
        else
          @points = points
        end
        @color = color
        @weight = weight
        @opacity = opacity
      end
      #Creates a new polyline.
      def create
        a = "new GPolyline(#{MappingObject.javascriptify_variable(points)}"
        a << ",#{MappingObject.javascriptify_variable(@color)}" if @color
        a << ",#{MappingObject.javascriptify_variable(@weight)}" if @weight
        a << ",#{MappingObject.javascriptify_variable(@opacity)}" if @opacity
        a << ")"
      end
    end

    #Encoded GPolyline class
    class GPolylineEncoded 
      include MappingObject
      attr_accessor :points,:color,:weight,:opacity,:levels,:zoom_factor,:num_levels

      def initialize(options={})
        #points = options[:points]
        #if !points.empty? and points[0].is_a?(Array)
        #  @points = points.collect { |pt| GLatLng.new(pt) }
        #else
        #@points = points
          #end
        @points = options[:points]
        @color = options[:color]
        @weight = options[:weight]
        @opacity = options[:opacity]
        @levels = options[:levels] || "BBBBBBBBBBBB"
        @zoom_factor = options[:zoom_factor] || 32
        @num_levels = options[:num_levels] || 4
      end
      def create
        a = "new GPolyline.fromEncoded({points: #{MappingObject.javascriptify_variable(points)},\n" 
        a << "levels: #{MappingObject.javascriptify_variable(@levels)},"
        a << "zoomFactor: #{MappingObject.javascriptify_variable(@zoom_factor)},"
        a << "numLevels: #{MappingObject.javascriptify_variable(@num_levels)}"
        a << ",color: #{MappingObject.javascriptify_variable(@color)}" if @color
        a << ",weight: #{MappingObject.javascriptify_variable(@weight)}" if @weight
        a << ",opacity: #{MappingObject.javascriptify_variable(@opacity)}" if @opacity
        a << "})"
      end
    end

    #A basic Latitude/longitude point.
    class GLatLng 
      include MappingObject
      attr_accessor :lat,:lng,:unbounded
      
      def initialize(latlng,unbounded = nil)
        @lat = latlng[0]
        @lng = latlng[1]
        @unbounded = unbounded
      end
      def create
        unless @unbounded
          "new GLatLng(#{MappingObject.javascriptify_variable(@lat)},#{MappingObject.javascriptify_variable(@lng)})"
        else
          "new GLatLng(#{MappingObject.javascriptify_variable(@lat)},#{MappingObject.javascriptify_variable(@lng)},#{MappingObject.javascriptify_variable(@unbounded)})"
        end
      end
    end
    
    #A rectangular bounding box, defined by its south-western and north-eastern corners.
    class GLatLngBounds < Struct.new(:sw,:ne)
      include MappingObject
      def create
        "new GLatLngBounds(#{MappingObject.javascriptify_variable(sw)},#{MappingObject.javascriptify_variable(ne)})"
      end
    end

    #Polygon. Not documented yet in the Google Maps API
    class GPolygon
      include MappingObject
      
      attr_accessor :points,:stroke_color,:stroke_weight,:stroke_opacity,:color,:opacity
      
      #Can take an array of +GLatLng+ or an array of 2D arrays. A method to directly build a polygon from a GeoRuby polygon is provided in the helper.rb file.
      def initialize(points,stroke_color="#000000",stroke_weight=1,stroke_opacity=1.0,color="#ff0000",opacity=1.0,encoded=false)
        if !points.empty? and points[0].is_a?(Array)
          @points = points.collect { |pt| GLatLng.new(pt) }
        else
          @points = points
        end
        @stroke_color = stroke_color
        @stroke_weight = stroke_weight
        @stroke_opacity = stroke_opacity
        @color = color
        @opacity = opacity
      end
      
      #Creates a new polygon
      def create
        a = "new GPolygon(#{MappingObject.javascriptify_variable(points)}"
        a << ",#{MappingObject.javascriptify_variable(@stroke_color)}"
        a << ",#{MappingObject.javascriptify_variable(@stroke_weight)}"
        a << ",#{MappingObject.javascriptify_variable(@stroke_opacity)}"
        a << ",#{MappingObject.javascriptify_variable(@color)}"
        a << ",#{MappingObject.javascriptify_variable(@opacity)}"
        a << ")"
      end
    end

    class GPolygonEncoded 
      include MappingObject
      
      attr_accessor :polyline, :color, :opacity, :outline, :fill
      
      def initialize(polylines,fill=true,color="#000000",opacity=0.5,outline=false)
        #force polylines to be an array
        if polylines.is_a? Array
          @polylines = polylines
        else
          @polylines = [polylines]
        end
        @color = color
        @fill = fill 
        @opacity = opacity
        @outline = outline
      end
      
      #Creates a new polygon.
      def create
        polylines_for_polygon= []
        @polylines.each do |p|
          x = "{points: #{MappingObject.javascriptify_variable(p.points)}," 
          x << "levels: #{MappingObject.javascriptify_variable(p.levels)},"
          x << "zoomFactor: #{MappingObject.javascriptify_variable(p.zoom_factor)},"
          x << "numLevels: #{MappingObject.javascriptify_variable(p.num_levels)} "
          x << "}"
          polylines_for_polygon << x
        end

        polylines_for_polygon = "[" + polylines_for_polygon.join(",") + "]"

        a = "new GPolygon.fromEncoded({polylines: #{polylines_for_polygon},"
        a << "fill: #{MappingObject.javascriptify_variable(@fill)},"
        a << "color: #{MappingObject.javascriptify_variable(@color)},"
        a << "opacity: #{MappingObject.javascriptify_variable(@opacity)},"
        a << "outline: #{MappingObject.javascriptify_variable(@outline)}"
        a << "})"
      end
    end

    class ELabel
      attr_accessor :point, :text, :style
      include MappingObject

      def initialize(point, text=nil, style=nil)
        @point = point
        @text = text
        @style = style
      end

      def create
          a = "new ELabel(#{MappingObject.javascriptify_variable(@point)}"
          a << ",#{MappingObject.javascriptify_variable(@text)}" if @text
          a << ",#{MappingObject.javascriptify_variable(@style)}" if @style
          a << ")"
      end
    end


    #A GGeoXml object gets data from a GeoRSS or KML feed and displays it. Use <tt>overlay_init</tt> to add it to a map at initialization time.
    class GGeoXml
      include MappingObject
      
      attr_accessor :url

      def initialize(url)
        @url = url
      end

      def create
        "new GGeoXml(#{MappingObject.javascriptify_variable(@url)})"
      end

    end
    
    #A GOverlay representing a group of GMarkers. The GMarkers can be identified with an id, which can be used to show the info window of a specific marker, in reponse, for example, to a click on a link. The whole group can be shown on and off at once. It should be declared global at initialization time to be useful.
    class GMarkerGroup
      include MappingObject
      attr_accessor :active, :markers, :markers_by_id

      def initialize(active = true , markers = nil)
        @active = active
        @markers = []
        @markers_by_id = {}
        if markers.is_a?(Array)
          @markers = markers
        elsif markers.is_a?(Hash)
          @markers_by_id = markers
        end
      end
      
      def create
        "new GMarkerGroup(#{MappingObject.javascriptify_variable(@active)},#{MappingObject.javascriptify_variable(@markers)},#{MappingObject.javascriptify_variable(@markers_by_id)})"
      end
    end

    #Can be used to implement a clusterer, similar to the clusterer below, except that there is more stuff to manage explicitly byt the programmer (but this is also more flexible). See the README for usage esamples.
    class GMarkerManager
      include MappingObject
      
      attr_accessor :map,:options,:managed_markers
            
      #options can be <tt>:border_padding</tt>, <tt>:max_zoom</tt>, <tt>:track_markers</tt> and <tt>:managed_markers</tt>: managed_markers must be an array of ManagedMarker objects
      def initialize(map, options = {})
        @map = map
        @managed_markers = Array(options.delete(:managed_markers)) #[] if nil
        @options = options
      end

      def create
        puts @options.inspect
        "addMarkersToManager(new GMarkerManager(#{MappingObject.javascriptify_variable(@map)},#{MappingObject.javascriptify_variable(@options)}),#{MappingObject.javascriptify_variable(@managed_markers)})"
      end

    end

    #A set of similarly managed markers: They share the same minZoom and maxZoom.
    class ManagedMarker
      include MappingObject
      
      attr_accessor :markers,:min_zoom, :max_zoom
      
      def initialize(markers,min_zoom,max_zoom = nil)
        @markers = markers
        @min_zoom = min_zoom
        @max_zoom = max_zoom
      end

      def create
        "new ManagedMarker(#{MappingObject.javascriptify_variable(@markers)},#{MappingObject.javascriptify_variable(@min_zoom)},#{MappingObject.javascriptify_variable(@max_zoom)})"
      end
      
    end

    #Makes the link with the Clusterer2 library by Jef Poskanzer (slightly modified though). Is a GOverlay making clusters out of its GMarkers, so that GMarkers very close to each other appear as one when the zoom is low. When the zoom gets higher, the individual markers are drawn.
    class Clusterer
      include MappingObject
      attr_accessor :markers,:icon, :max_visible_markers, :grid_size, :min_markers_per_cluster , :max_lines_per_info_box

      def initialize(markers = [], options = {})
        @markers = markers
        @icon = options[:icon] || GIcon::DEFAULT
        @max_visible_markers = options[:max_visible_markers] || 150
        @grid_size = options[:grid_size] || 5
        @min_markers_per_cluster = options[:min_markers_per_cluster] || 5
        @max_lines_per_info_box = options[:max_lines_per_info_box] || 10
      end

      def create 
        js_marker = '[' + @markers.collect do |marker|
          add_description(marker)
        end.join(",") + ']'

        "new Clusterer(#{js_marker},#{MappingObject.javascriptify_variable(@icon)},#{MappingObject.javascriptify_variable(@max_visible_markers)},#{MappingObject.javascriptify_variable(@grid_size)},#{MappingObject.javascriptify_variable(@min_markers_per_cluster)},#{MappingObject.javascriptify_variable(@max_lines_per_info_box)})"
      end
            
      private
      def add_description(marker)
        "addDescriptionToMarker(#{MappingObject.javascriptify_variable(marker)},#{MappingObject.javascriptify_variable(marker.options[:description] || marker.options[:title] || '')})"
      end
    end
    
    #Makes the link with the MGeoRSS extension by Mikel Maron (a bit modified though). It lets you overlay on top of Google Maps the items present in a RSS feed that has GeoRss data. This data can be either in W3C Geo vocabulary or in the GeoRss Simple format. See http://georss.org to know more about GeoRss.
    class GeoRssOverlay
      include MappingObject
      attr_accessor :url, :proxy, :icon, :options
      
      #You can pass the following options:
      #- <tt>:icon</tt>: An icon for the items of the feed. Defaults to the classic red balloon icon.
      #- <tt>:proxy</tt>: An URL on your server where fetching the RSS feed will be taken care of.
      #- <tt>:list_div</tt>: In case you want a list of all the markers, with a link on which you can click in order to display the info on the marker, use this option to indicate the ID of the div (that you must place yourself).
      #- <tt>:list_item_class</tt>: class of the DIV containing each item of the list. Ignored if option <tt>:list_div</tt> is not set.
      #- <tt>:limit</tt>: Maximum number of items to display on the map.
      #- <tt>:content_div</tt>: Instead of having an info window appear, indicates the ID of the DIV where this info should be displayed.
      def initialize(url, options = {})
        @url = url
        @icon = options.delete(:icon) || GIcon::DEFAULT
        @proxy = options.delete(:proxy) || Variable::UNDEFINED
        @options = options 
      end

      def create 
        "new GeoRssOverlay(#{MappingObject.javascriptify_variable(@url)},#{MappingObject.javascriptify_variable(@icon)},#{MappingObject.javascriptify_variable(@proxy)},#{MappingObject.javascriptify_variable(@options)})"
      end
    end

  end
end
