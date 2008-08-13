require 'time'

module DCMI
  class Period
    def self.parse( str )
      name, start, _end, scheme = nil, nil, nil, nil
      str.split( /(\n|;)+/ ).each do |component|
        component.strip!
        if component =~ /name=(.*)/
          name = $1
        elsif component =~ /start=(.*)/
          start = Time.parse $1
        elsif component =~ /end=(.*)/
          _end = Time.parse $1
        elsif component =~ /scheme=(.*)/
          scheme = $1
        end
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
    
    def end; @_end; end
    
    def end=( _end ); @_end = _end; end
  end
end