require 'time'

module DCMI
  class Period
    def self.parse( str )
      name, start, _end, scheme = nil, nil, nil, nil
      str.each do |line|
        if line =~ /^\s*name=(.*)/
          name = $1
        elsif line =~ /^\s*start=(.*)/
          start = Time.parse $1
        elsif line =~ /^\s*end=(.*)/
          _end = Time.parse $1
        elsif line =~ /^\s*scheme=(.*)/
          scheme = $1
        end
      end
      new( name, start, _end, scheme )
    end
    
    attr_accessor :name, :start, :scheme
    
    def initialize( name, start, _end, scheme )
      @name, @start, @_end, @scheme = name, start, _end, scheme
    end
    
    def end; @_end; end
    
    def end=( _end ); @_end = _end; end
  end
end