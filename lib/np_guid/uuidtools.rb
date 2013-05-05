#--
# Copyright (c) 2005 Robert Aman
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#++

UUID_TOOLS_VERSION = "1.0.0"

$:.unshift(File.dirname(__FILE__))

require 'uri'
require 'time'
require 'thread'
require 'digest/sha1'
require 'digest/md5'

#  Because it's impossible to hype a UUID generator on its genuine merits,
#  I give you... Really bad ASCII art in the comments:
#
#                                                                  
#                \                                                 
#                /                                                   
#               +                                                  
#              ]                                                   
#              ]                                                   
#              |                                                    
#             /                                                     
#           Mp___                                                  
#              `~0NNp,                                             
#               __ggM'                                             
#             g0M~"`                                               
#            ]0M*-                                                 
#                                                                  
#                    ___                                           
#                _g000M00g,                                        
#              j0M~      ~M&                                       
#            j0M"          ~N,                                     
#           j0P              M&                                    
#          jM                  1                                   
#         j0                   ]1                                  
#        .0P                    0,                                 
#        00'                    M&                                 
#        0M                     ]0L                                
#       ]0f         ___          M0                                
#        M0NN0M00MMM~"'M          0&                               
#          `~          ~0         ]0,                              
#                       ]M        ]0&                              
#                        M&        M0,                             
#               ____gp_   M&        M0_                            
#            __p0MPM8MM&_  M/        ^0&_                          
#           gN"`       M0N_j0,         MM&__                       
#         _gF           `~M0P`   __      M00g                      
#        g0'                    gM0&,     ~M0&                     
#      _pM`                     0, ]M1     "00&                    
#     _00                    /g1MMgj01      ]0MI                   
#    _0F                     t"M,7MMM        00I                   
#   g0'                  _   N&j&            40'                   
#  g0'                _p0Mq_   '             N0QQNM#g,             
#  0'              _g0000000g__              ~M@MMM000g            
#  f             _jM00@`  ~M0000Mgppg,             "P00&           
# |             g000~       `~M000000&_               ~0&          
# ]M          _M00F              "00MM`                ~#&         
# `0L        m000F                #E                    "0f        
#   9r     j000M`                 40,                    00        
#    ]0g_ j00M`                   ^M0MNggp#gqpg          M0&       
#     ~MPM0f                         ~M000000000g_ ,_ygg&M00f      
#                                        `~~~M00000000000000       
#                                              `M0000000000f       
#                                                  ~@@@MF~`        
#                                                                  
#                                                                  

#= uuidtools.rb
#
# UUIDTools was designed to be a simple library for generating any
# of the various types of UUIDs.  It conforms to RFC 4122 whenever
# possible.
#
#== Example
#  UUID.md5_create(UUID_DNS_NAMESPACE, "www.widgets.com")
#  => #<UUID:0x287576 UUID:3d813cbb-47fb-32ba-91df-831e1593ac29>
#  UUID.sha1_create(UUID_DNS_NAMESPACE, "www.widgets.com")
#  => #<UUID:0x2a0116 UUID:21f7f8de-8051-5b89-8680-0195ef798b6a>
#  UUID.timestamp_create
#  => #<UUID:0x2adfdc UUID:64a5189c-25b3-11da-a97b-00c04fd430c8>
#  UUID.random_create
#  => #<UUID:0x19013a UUID:984265dc-4200-4f02-ae70-fe4f48964159>
class UUID
  @@mac_address = nil
  @@last_timestamp = nil
  @@last_node_id = nil
  @@last_clock_sequence = nil
  @@state_file = nil
  @@mutex = Mutex.new
  
  def initialize(time_low, time_mid, time_hi_and_version,
      clock_seq_hi_and_reserved, clock_seq_low, nodes)
    unless time_low >= 0 && time_low < 4294967296
      raise ArgumentError,
        "Expected unsigned 32-bit number for time_low, got #{time_low}."
    end
    unless time_mid >= 0 && time_mid < 65536
      raise ArgumentError,
        "Expected unsigned 16-bit number for time_mid, got #{time_mid}."
    end
    unless time_hi_and_version >= 0 && time_hi_and_version < 65536
      raise ArgumentError,
        "Expected unsigned 16-bit number for time_hi_and_version, " +
        "got #{time_hi_and_version}."
    end
    unless clock_seq_hi_and_reserved >= 0 && clock_seq_hi_and_reserved < 256
      raise ArgumentError,
        "Expected unsigned 8-bit number for clock_seq_hi_and_reserved, " +
        "got #{clock_seq_hi_and_reserved}."
    end
    unless clock_seq_low >= 0 && clock_seq_low < 256
      raise ArgumentError,
        "Expected unsigned 8-bit number for clock_seq_low, " +
        "got #{clock_seq_low}."
    end
    unless nodes.respond_to? :size
      raise ArgumentError,
        "Expected nodes to respond to :size."
    end  
    unless nodes.size == 6
      raise ArgumentError,
        "Expected nodes to have size of 6."
    end
    for node in nodes
      unless node >= 0 && node < 256
        raise ArgumentError,
          "Expected unsigned 8-bit number for each node, " +
          "got #{node}."
      end
    end
    @time_low = time_low
    @time_mid = time_mid
    @time_hi_and_version = time_hi_and_version
    @clock_seq_hi_and_reserved = clock_seq_hi_and_reserved
    @clock_seq_low = clock_seq_low
    @nodes = nodes
  end
  
  attr_accessor :time_low
  attr_accessor :time_mid
  attr_accessor :time_hi_and_version
  attr_accessor :clock_seq_hi_and_reserved
  attr_accessor :clock_seq_low
  attr_accessor :nodes
  
  # Parses a UUID from a string.
  def UUID.parse(uuid_string)
    unless uuid_string.kind_of? String
      raise ArgumentError,
        "Expected String, got #{uuid_string.class.name} instead."
    end
    uuid_components = uuid_string.downcase.scan(
      Regexp.new("^([0-9a-f]{8})-([0-9a-f]{4})-([0-9a-f]{4})-" +
        "([0-9a-f]{2})([0-9a-f]{2})-([0-9a-f]{12})$")).first
    raise ArgumentError, "Invalid UUID format." if uuid_components.nil?
    time_low = uuid_components[0].to_i(16)
    time_mid = uuid_components[1].to_i(16)
    time_hi_and_version = uuid_components[2].to_i(16)
    clock_seq_hi_and_reserved = uuid_components[3].to_i(16)
    clock_seq_low = uuid_components[4].to_i(16)
    nodes = []
    for i in 0..5
      nodes << uuid_components[5][(i * 2)..(i * 2) + 1].to_i(16)
    end
    return UUID.new(time_low, time_mid, time_hi_and_version,
      clock_seq_hi_and_reserved, clock_seq_low, nodes)
  end

  # Parses a UUID from a raw byte string.
  def UUID.parse_raw(raw_string)
    unless raw_string.kind_of? String
      raise ArgumentError,
        "Expected String, got #{raw_string.class.name} instead."
    end
    integer = UUID.convert_byte_string_to_int(raw_string)

    time_low = (integer >> 96) & 0xFFFFFFFF
    time_mid = (integer >> 80) & 0xFFFF
    time_hi_and_version = (integer >> 64) & 0xFFFF
    clock_seq_hi_and_reserved = (integer >> 56) & 0xFF
    clock_seq_low = (integer >> 48) & 0xFF
    nodes = []
    for i in 0..5
      nodes << ((integer >> (40 - (i * 8))) & 0xFF)
    end
    return UUID.new(time_low, time_mid, time_hi_and_version,
      clock_seq_hi_and_reserved, clock_seq_low, nodes)
  end

  # Creates a UUID from a random value.
  def UUID.random_create()
    new_uuid = UUID.parse_raw(UUID.true_random)
    new_uuid.time_hi_and_version &= 0x0FFF
    new_uuid.time_hi_and_version |= (4 << 12)
    new_uuid.clock_seq_hi_and_reserved &= 0x3F
    new_uuid.clock_seq_hi_and_reserved |= 0x80
    return new_uuid
  end

  # Creates a UUID from a timestamp.
  def UUID.timestamp_create(timestamp=nil)
    # We need a lock here to prevent two threads from ever
    # getting the same timestamp.
    @@mutex.synchronize do
      # Always use GMT to generate UUIDs.
      if timestamp.nil?
        gmt_timestamp = Time.now.gmtime
      else
        gmt_timestamp = timestamp.gmtime
      end
      # Convert to 100 nanosecond blocks
      gmt_timestamp_100_nanoseconds = (gmt_timestamp.tv_sec * 10000000) +
        (gmt_timestamp.tv_usec * 10) + 0x01B21DD213814000
      nodes = UUID.get_mac_address.split(":").collect do |octet|
        octet.to_i(16)
      end
      node_id = 0
      for i in 0..5
        node_id += (nodes[i] << (40 - (i * 8)))
      end
      clock_sequence = @@last_clock_sequence
      if clock_sequence.nil?
        clock_sequence = UUID.convert_byte_string_to_int(UUID.true_random)
      end
      if @@last_node_id != nil && @@last_node_id != node_id
        # The node id has changed.  Change the clock id.
        clock_sequence = UUID.convert_byte_string_to_int(UUID.true_random)
      elsif @@last_timestamp != nil &&
          gmt_timestamp_100_nanoseconds <= @@last_timestamp
        clock_sequence = clock_sequence + 1
      end
      @@last_timestamp = gmt_timestamp_100_nanoseconds
      @@last_node_id = node_id
      @@last_clock_sequence = clock_sequence

      time_low = gmt_timestamp_100_nanoseconds & 0xFFFFFFFF
      time_mid = ((gmt_timestamp_100_nanoseconds >> 32) & 0xFFFF)
      time_hi_and_version = ((gmt_timestamp_100_nanoseconds >> 48) & 0x0FFF)
      time_hi_and_version |= (1 << 12)
      clock_seq_low = clock_sequence & 0xFF;
      clock_seq_hi_and_reserved = (clock_sequence & 0x3F00) >> 8
      clock_seq_hi_and_reserved |= 0x80
      
      return UUID.new(time_low, time_mid, time_hi_and_version,
        clock_seq_hi_and_reserved, clock_seq_low, nodes)
    end
  end

  # Creates a UUID using the MD5 hash.  (Version 3)
  def UUID.md5_create(namespace, name)
    return UUID.create_from_hash(Digest::MD5, namespace, name)
  end
  
  # Creates a UUID using the SHA1 hash.  (Version 5)
  def UUID.sha1_create(namespace, name)
    return UUID.create_from_hash(Digest::SHA1, namespace, name)
  end
  
  # This method applies only to version 1 UUIDs.
  # Checks if the node ID was generated from a random number
  # or from an IEEE 802 address (MAC address).
  # Always returns false for UUIDs that aren't version 1.
  # This should not be confused with version 4 UUIDs where
  # more than just the node id is random.
  def random_node_id?
    return false if self.version != 1
    return ((self.nodes.first & 0x01) == 1)
  end
  
  # Returns true if this UUID is the
  # nil UUID (00000000-0000-0000-0000-000000000000).
  def nil_uuid?
    return false if self.time_low != 0
    return false if self.time_mid != 0
    return false if self.time_hi_and_version != 0
    return false if self.clock_seq_hi_and_reserved != 0
    return false if self.clock_seq_low != 0
    self.nodes.each do |node|
      return false if node != 0
    end
    return true
  end
  
  # Returns the UUID version type.
  # Possible values:
  # 1 - Time-based with unique or random host identifier
  # 2 - DCE Security version (with POSIX UIDs)
  # 3 - Name-based (MD5 hash)
  # 4 - Random
  # 5 - Name-based (SHA-1 hash)
  def version
    return (time_hi_and_version >> 12)
  end

  # Returns the UUID variant.
  # Possible values:
  # 0b000 - Reserved, NCS backward compatibility.
  # 0b100 - The variant specified in this document.
  # 0b110 - Reserved, Microsoft Corporation backward compatibility.
  # 0b111 - Reserved for future definition.
  def variant
    variant_raw = (clock_seq_hi_and_reserved >> 5)
    result = nil
    if (variant_raw >> 2) == 0
      result = 0x000
    elsif (variant_raw >> 1) == 2
      result = 0x100
    else
      result = variant_raw
    end
    return (result >> 6)
  end
  
  # Returns true if this UUID is valid.
  def valid?
    if [0b000, 0b100, 0b110, 0b111].include?(self.variant) &&
      (1..5).include?(self.version)
      return true
    else
      return false
    end
  end
  
  # Returns the IEEE 802 address used to generate this UUID or
  # nil if a MAC address was not used.
  def mac_address
    return nil if self.version != 1
    return nil if self.random_node_id?
    return (self.nodes.collect do |node|
      sprintf("%2.2x", node)
    end).join(":")
  end
  
  # Returns the timestamp used to generate this UUID
  def timestamp
    return nil if self.version != 1
    gmt_timestamp_100_nanoseconds = 0
    gmt_timestamp_100_nanoseconds +=
      ((self.time_hi_and_version  & 0x0FFF) << 48)
    gmt_timestamp_100_nanoseconds += (self.time_mid << 32)
    gmt_timestamp_100_nanoseconds += self.time_low
    return Time.at(
      (gmt_timestamp_100_nanoseconds - 0x01B21DD213814000) / 10000000.0)
  end
  
  # Compares two UUIDs lexically
  def <=>(other_uuid)
    check = self.time_low <=> other_uuid.time_low
    return check if check != 0
    check = self.time_mid <=> other_uuid.time_mid
    return check if check != 0
    check = self.time_hi_and_version <=> other_uuid.time_hi_and_version
    return check if check != 0
    check = self.clock_seq_hi_and_reserved <=>
      other_uuid.clock_seq_hi_and_reserved
    return check if check != 0
    check = self.clock_seq_low <=> other_uuid.clock_seq_low
    return check if check != 0
    for i in 0..5
      if (self.nodes[i] < other_uuid.nodes[i])
        return -1
      end
      if (self.nodes[i] > other_uuid.nodes[i])
        return 1
      end
    end
    return 0
  end
  
  # Returns a representation of the object's state
  def inspect
    return "#<UUID:0x#{self.object_id.to_s(16)} UUID:#{self.to_s}>"
  end
  
  # Returns the hex digest of the UUID object.
  def hexdigest
    return self.to_i.to_s(16)
  end
  
  # Returns the raw bytes that represent this UUID.
  def raw
    return UUID.convert_int_to_byte_string(self.to_i, 16)
  end
  
  # Returns a string representation for this UUID.
  def to_s
    result = sprintf("%8.8x-%4.4x-%4.4x-%2.2x%2.2x-", @time_low, @time_mid,
      @time_hi_and_version, @clock_seq_hi_and_reserved, @clock_seq_low);
    for i in 0..5
      result << sprintf("%2.2x", @nodes[i])
    end
    return result
  end
  
  # Returns an integer representation for this UUID.
  def to_i
    bytes = (time_low << 96) + (time_mid << 80) +
      (time_hi_and_version << 64) + (clock_seq_hi_and_reserved << 56) +
      (clock_seq_low << 48)
    for i in 0..5
      bytes += (nodes[i] << (40 - (i * 8)))
    end
    return bytes
  end
    
  # Returns a URI for this UUID.
  def to_uri
    return URI.parse(self.to_uri_string)
  end

  # Returns a URI string for this UUID.
  def to_uri_string
    return "urn:uuid:#{self.to_s}"
  end
  
  def UUID.create_from_hash(hash_class, namespace, name) #:nodoc:
    if hash_class == Digest::MD5
      version = 3
    elsif hash_class == Digest::SHA1
      version = 5
    else
      raise ArgumentError,
        "Expected Digest::SHA1 or Digest::MD5, got #{hash_class.name}."
    end
    hash = hash_class.new
    hash.update(namespace.raw)
    hash.update(name)
    hash_string = hash.to_s[0..31]
    new_uuid = UUID.parse("#{hash_string[0..7]}-#{hash_string[8..11]}-" +
      "#{hash_string[12..15]}-#{hash_string[16..19]}-#{hash_string[20..31]}")
    
    new_uuid.time_hi_and_version &= 0x0FFF
    new_uuid.time_hi_and_version |= (version << 12)
    new_uuid.clock_seq_hi_and_reserved &= 0x3F
    new_uuid.clock_seq_hi_and_reserved |= 0x80
    return new_uuid
  end

  # Returns the MAC address of the current computer's network card.
  # Returns nil if a MAC address could not be found.
  def UUID.get_mac_address #:nodoc:
    if @@mac_address.nil?
      if RUBY_PLATFORM =~ /win/ && !(RUBY_PLATFORM =~ /darwin/)
        begin
          ifconfig_output = `ipconfig /all`
          mac_addresses = ifconfig_output.scan(
            Regexp.new("(#{(["[0-9a-fA-F]{2}"] * 6).join("-")})"))
          if mac_addresses.size > 0
            @@mac_address = mac_addresses.first.first.downcase.gsub(/-/, ":")
          end
        rescue
        end
      else
        begin
          mac_addresses = []
          if File.exists?('/sbin/ifconfig')
            ifconfig_output =
              `/sbin/ifconfig 2>&1`
            mac_addresses = ifconfig_output.scan(
              Regexp.new("ether (#{(["[0-9a-fA-F]{2}"] * 6).join(":")})"))
            if mac_addresses.size == 0
              ifconfig_output =
                `/sbin/ifconfig | grep HWaddr | cut -c39- 2>&1`
              mac_addresses = ifconfig_output.scan(
                Regexp.new("(#{(["[0-9a-fA-F]{2}"] * 6).join(":")})"))
            end
          else
            ifconfig_output =
              `ifconfig 2>&1`
            mac_addresses = ifconfig_output.scan(
              Regexp.new("ether (#{(["[0-9a-fA-F]{2}"] * 6).join(":")})"))
            if mac_addresses.size == 0
              ifconfig_output =
                `ifconfig | grep HWaddr | cut -c39- 2>&1`
              mac_addresses = ifconfig_output.scan(
                Regexp.new("(#{(["[0-9a-fA-F]{2}"] * 6).join(":")})"))
            end
          end
          if mac_addresses.size > 0
            @@mac_address = mac_addresses.first.first
          end
        rescue
        end
      end
    end
    
    # Fix to avoid returning nil (which would crash the ID creation later)
    # The MAC is missing mostly in virtual devices (e.g. at Travis CI)
    # So use here a random static MAC to keep the script happy.
    # the risk of this causing crashing UUIDs is pretty low.
    @@mac_address = "f8:3a:4b:66:d4:f2" if @@mac_address.nil?
    return @@mac_address
  end
  
  # Returns 128 bits of highly unpredictable data.
  # The random number generator isn't perfect, but it's
  # much, much better than the built-in pseudorandom number generators.
  def UUID.true_random #:nodoc:
    require 'benchmark'
    hash = Digest::SHA1.new
    performance = Benchmark.measure do
      hash.update(rand.to_s)
      hash.update(srand.to_s)
      hash.update(rand.to_s)
      hash.update(srand.to_s)
      hash.update(Time.now.to_s)
      hash.update(rand.to_s)
      hash.update(self.object_id.to_s)
      hash.update(rand.to_s)
      hash.update(hash.object_id.to_s)
      hash.update(self.methods.inspect)
      hash.update($:.to_s)
      begin
        random_device = nil
        if File.exists? "/dev/urandom"
          random_device = File.open "/dev/urandom", "r"
        elsif File.exists? "/dev/random"
          random_device = File.open "/dev/random", "r"
        end
        hash.update(random_device.read(20)) if random_device != nil
      rescue
      end
      begin
        srand(hash.to_s.to_i(16) >> 128)
      rescue
      end
      hash.update(rand.to_s)
      hash.update(UUID.true_random) if (rand(2) == 0)
    end
    hash.update(performance.real.to_s)
    hash.update(performance.inspect)
    return UUID.convert_int_to_byte_string(hash.to_s[4..35].to_i(16), 16)
  end
  
  def UUID.convert_int_to_byte_string(integer, size) #:nodoc:
    byte_string = ""
    for i in 0..(size - 1)
      byte_string << ((integer >> (((size - 1) - i) * 8)) & 0xFF)
    end
    return byte_string
  end

  def UUID.convert_byte_string_to_int(byte_string) #:nodoc:
    integer = 0
    size = byte_string.size
    for i in 0..(size - 1)
      # Added here the .to_i at the end of next line when updating to Ruby 1.9.3
      integer += (byte_string[i] << (((size - 1) - i) * 8)).to_i
    end
    return integer
  end
end

UUID_DNS_NAMESPACE = UUID.parse("6ba7b810-9dad-11d1-80b4-00c04fd430c8")
UUID_URL_NAMESPACE = UUID.parse("6ba7b811-9dad-11d1-80b4-00c04fd430c8")
UUID_OID_NAMESPACE = UUID.parse("6ba7b812-9dad-11d1-80b4-00c04fd430c8")
UUID_X500_NAMESPACE = UUID.parse("6ba7b814-9dad-11d1-80b4-00c04fd430c8")