require 'time'

module DCMI
  class Period
    def self.parse( str )
      name, start_str, end_str, scheme = nil, nil, nil, nil
      str.split( /(\n|;)+/ ).each do |component|
        component.strip!
        if component =~ /name=(.*)/
          name = $1
        elsif component =~ /start=(.*)/
          start_str = $1
        elsif component =~ /end=(.*)/
          end_str = $1
        elsif component =~ /scheme=(.*)/
          scheme = $1
        end
      end
      if scheme == 'W3C-DTF' || scheme.nil?
        start = Time.parse( start_str ) if start_str
        _end = Time.parse( end_str ) if end_str
      else
        start = start_str
        _end = end_str
      end
      new( :name => name, :start => start, :end => _end, :scheme => scheme )
    end
    
    attr_accessor :name, :start, :scheme
    alias_method :begin, :start
    alias_method :first, :start
    
    def initialize( atts )
      @name = atts[:name]
      @start = atts[:start]
      @_end = atts[:end]
      @scheme = atts[:scheme]
    end
    
    def ==( obj )
      if obj.is_a?( DCMI::Period )
        obj.start == self.start && obj.end == self.end
      else
        super
      end
    end
    
    def end; @_end; end
    
    def end=( _end ); @_end = _end; end
  end
end