$:.unshift(File.dirname(__FILE__) + '/../lib')

require File.expand_path(File.dirname(__FILE__) + "/../../../../config/environment")


require 'ym4r_gm'
require 'test/unit'

include Ym4r::GmPlugin

class TestGoogleMaps< Test::Unit::TestCase
  def test_javascriptify_method
    assert_equal("addOverlayToHello",MappingObject::javascriptify_method("add_overlay_to_hello"))
  end

  def test_javascriptify_variable_mapping_object
    map = GMap.new("div")
    assert_equal(map.to_javascript,MappingObject::javascriptify_variable(map))
  end

  def test_javascriptify_variable_numeric
    assert_equal("123.4",MappingObject::javascriptify_variable(123.4))
  end

  def test_javascriptify_variable_array
    map = GMap.new("div")
    assert_equal("[123.4,#{map.to_javascript},[123.4,#{map.to_javascript}]]",MappingObject::javascriptify_variable([123.4,map,[123.4,map]]))
  end

  def test_javascriptify_variable_hash
    map = GMap.new("div")
    test_str = MappingObject::javascriptify_variable("hello" => map, "chopotopoto" => [123.55,map])
    assert("{hello : #{map.to_javascript},chopotopoto : [123.55,#{map.to_javascript}]}" == test_str || "{chopotopoto : [123.55,#{map.to_javascript}],hello : #{map.to_javascript}}" == test_str)
  end

  def test_method_call_on_mapping_object
    map = GMap.new("div","map")
    assert_equal("map.addHello(123.4);",map.add_hello(123.4).to_s)
  end

  def test_nested_calls_on_mapping_object
    gmap = GMap.new("div","map")
    assert_equal("map.addHello(map.hoYoYo(123.4),map);",gmap.add_hello(gmap.ho_yo_yo(123.4),gmap).to_s)
  end
  
  def test_declare_variable_latlng
    point = GLatLng.new([123.4,123.6])
    assert_equal("var point = new GLatLng(123.4,123.6);",point.declare("point"))
    assert_equal("point",point.variable)
  end

  def test_array_indexing
    obj = Variable.new("obj")
    assert_equal("obj[0]",obj[0].variable)
  end

  def test_google_maps_geocoding
    

    placemarks = Geocoding.get("Rue Clovis Paris")
    assert_equal(Geocoding::GEO_SUCCESS,placemarks.status)
    assert_equal(1,placemarks.length)
    placemark = placemarks[0]
    assert_equal("FR",placemark.country_code)
    assert_equal("Paris",placemark.locality)
    assert_equal("75005",placemark.postal_code)
    
    #test iwht multiple placemarks
    placemarks = Geocoding.get('hoogstraat, nl')
    assert_equal(Geocoding::GEO_SUCCESS,placemarks.status)
    assert(placemarks.length > 1)
    assert(placemarks[0].latitude != placemarks[1].latitude )
    

  end

  
end

