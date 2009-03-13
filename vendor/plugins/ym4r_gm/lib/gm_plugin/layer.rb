module Ym4r
  module GmPlugin
    #Map types of the map
    class GMapType
      include MappingObject
      
      G_NORMAL_MAP = Variable.new("G_NORMAL_MAP")
      G_SATELLITE_MAP = Variable.new("G_SATELLITE_MAP")
      G_HYBRID_MAP = Variable.new("G_HYBRID_MAP")
      G_PHYSICAL_MAP = Variable.new("G_PHYSICAL_MAP")
      
      attr_accessor :layers, :name, :projection, :options
      
      #The options can be any of the GMapType options detailed in the documentation + a <tt>:projection</tt>.
      def initialize(layers, name, options = {})
        @layers = layers
        @name = name
        @projection = options.delete(:projection) || GMercatorProjection.new
        @options = options
      end

      def create
        "new GMapType(#{MappingObject.javascriptify_variable(Array(layers))}, #{MappingObject.javascriptify_variable(projection)}, #{MappingObject.javascriptify_variable(name)}, #{MappingObject.javascriptify_variable(options)})"
      end
    end

    #Represents a mercator projection for zoom levels 0 to 17 (more than that by passing an argument to the constructor)
    class GMercatorProjection
      include MappingObject
      
      attr_accessor :n
      
      def initialize(n = nil)
        @n = n
      end

      def create
        if n.nil?
          return "G_NORMAL_MAP.getProjection()"
        else
          "new GMercatorProjection(#{@n})"
        end
      end
    end

    #Abstract Tile layer. Subclasses must implement a get_tile_url method.
    class GTileLayer
      include MappingObject
            
      attr_accessor :opacity, :zoom_range, :copyright, :format

      #Options are the following, with default values:
      #:zoom_range (0..17), :copyright ({'prefix' => '', 'copyright_texts' => [""]}), :opacity (1.0), :format ("png")
      def initialize(options = {})
        @opacity = options[:opacity] || 1.0
        @zoom_range = options[:zoom_range] || (0..17)
        @copyright = options[:copyright] || {'prefix' => '', 'copyright_texts' => [""]}
        @format = (options[:format] || "png").to_s
      end

      def create
        "addPropertiesToLayer(new GTileLayer(new GCopyrightCollection(\"\"),#{zoom_range.begin},#{zoom_range.end}),#{get_tile_url},function(a,b) {return #{MappingObject.javascriptify_variable(@copyright)};}\n,function() {return #{@opacity};},function(){return #{@format == "png"};})"
      end
      
      #for subclasses to implement
      def get_tile_url
      end
    end
    
    #Represents a pre tiled layer, taking images directly from a server, without using a server script.
    class PreTiledLayer < GTileLayer
      attr_accessor :base_url
      
      #Possible options are the same as for the GTileLayer constructor
      def initialize(base_url,options = {})
        super(options)
        @base_url = base_url
      end
      
      #Returns the code to determine the url to fetch the tile. Follows the convention adopted by the tiler: {base_url}/tile_{b}_{a.x}_{a.y}.{format}
      def get_tile_url
        "function(a,b) { return '#{@base_url}/tile_' + b + '_' + a.x + '_' + a.y + '.#{format}';}"
      end 
    end

    #Represents a pretiled layer (it actually does not really matter where the tiles come from). Calls an action on the server to get back the tiles. It passes the action arguments x, y (coordinates of the tile) and z (zoom level). It can be used, for example, to return default tiles when the requested tile is not present.
    class PreTiledLayerFromAction < PreTiledLayer
      def get_tile_url
        "function(a,b) { return '#{base_url}?x=' + a.x + '&y=' + a.y + '&z=' + b ;}"
      end
    end
    
    #Represents a TileLayer where the tiles are generated dynamically from a WMS server (MapServer, GeoServer,...)
    #You need to include the JavaScript file wms-gs.js for this to work
    #see http://docs.codehaus.org/display/GEOSDOC/Google+Maps
    class WMSLayer < GTileLayer
      attr_accessor :base_url, :layers, :styles, :merc_proj, :use_geographic

      #Options are the same as with GTileLayer + :styles (""), :merc_proj (:mapserver), :use_geographic (false)
      def initialize(base_url, layers, options = {})
        super(options)
        @base_url = base_url.gsub(/\?$/,"") #standardize the url
        @layers = layers
        @styles = options[:styles] || ""
        merc_proj = options[:merc_proj] || :mapserver
        @merc_proj = if merc_proj == :mapserver
                       "54004"
                     elsif merc_proj == :geoserver
                       "41001"
                     else
                       merc_proj.to_s
                     end
        @use_geographic = options.has_key?(:use_geographic)? options[:use_geographic] : false
        puts format
      end
      
      def get_tile_url
        "getTileUrlForWMS"
      end

      def create
        "addWMSPropertiesToLayer(#{super},#{MappingObject.javascriptify_variable(@base_url)},#{MappingObject.javascriptify_variable(@layers)},#{MappingObject.javascriptify_variable(@styles)},#{MappingObject.javascriptify_variable(format)},#{MappingObject.javascriptify_variable(@merc_proj)},#{MappingObject.javascriptify_variable(@use_geographic)})"
      end
    end
  end
end
