module Ym4r
  module GmPlugin
    #A point in pixel coordinates
    class GPoint < Struct.new(:x,:y)
      include MappingObject
      def create
        "new GPoint(#{x},#{y})"
      end
    end
    #A rectangular that contains all the pixel points passed as arguments
    class GBounds
      include MappingObject
      attr_accessor :points
      #Accepts both an array of GPoint and an array of 2-element arrays
      def initialize(points)
        if !points.empty? and points[0].is_a?(Array)
          @points = points.collect { |pt| GPoint.new(pt[0],pt[1]) }
        else
          @points = points
        end
      end
      def create
        "new GBounds([#{@points.map { |pt| pt.to_javascript}.join(",")}])"
      end
    end
    #A size object, in pixel space
    class GSize < Struct.new(:width,:height)
      include MappingObject
      def create
        "new GSize(#{width},#{height})"
      end
    end
  end
end
