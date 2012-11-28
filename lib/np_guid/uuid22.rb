# Copyright (c) 2005-2007 Assembla, LLC
# MIT License

require File.expand_path('../uuidtools', __FILE__)

class UUID

  # Make an array of 64 URL-safe characters
  @@chars64=('a'..'z').to_a + ('A'..'Z').to_a + ('0'..'9').to_a + ['-','_']
    #return a 22 byte URL-safe string, encoded six bits at a time using 64 characters
  def to_s22
  	integer=self.to_i
  	rval=''
    22.times do
      c=(integer & 0x3F)
      rval+=@@chars64[c]
      integer =integer >> 6
    end
    return rval.reverse
  end
  	# Create a new UUID from a 22char string
  def self.parse22(s)
    	# get the integer representation
    integer=0
    s.each_byte {|c|
    	integer = integer << 6
      pos=@@chars64.index(c.chr)
      integer+=pos
    }

    time_low = (integer >> 96) & 0xFFFFFFFF
    time_mid = (integer >> 80) & 0xFFFF
    time_hi_and_version = (integer >> 64) & 0xFFFF
    clock_seq_hi_and_reserved = (integer >> 56) & 0xFF
    clock_seq_low = (integer >> 48) & 0xFF
    nodes = []
    for i in 0..5 do
      nodes << ((integer >> (40 - (i * 8))) & 0xFF)
    end
    return new(time_low, time_mid, time_hi_and_version,
      clock_seq_hi_and_reserved, clock_seq_low, nodes)
  end	
end
