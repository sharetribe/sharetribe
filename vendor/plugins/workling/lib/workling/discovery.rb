#
#  Discovery is responsible for loading workers in app/workers. 
#
module Workling
  class Discovery
    cattr_accessor :discovered
    @@discovered = []
    
    # requires worklings so that they are added to routing. 
    def self.discover!
      Dir.glob(Workling.load_path.map { |p| "#{ p }/**/*.rb" }).each { |wling| require wling }
    end
  end
end