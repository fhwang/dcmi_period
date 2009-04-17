require 'time'

module DCMI
  class Period
    def self.parse(str, opts = {})
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
      start = parse_time start_str, scheme, opts[:missing_timezones_to_utc]
      _end = parse_time end_str, scheme, opts[:missing_timezones_to_utc]
      new( :name => name, :start => start, :end => _end, :scheme => scheme )
    end
    
    def self.parse_time(str, scheme, missing_timezones_to_utc)
      if (scheme == 'W3C-DTF' || scheme.nil?) && str
        begin
          w3cdtf str
        rescue ArgumentError => err
          if missing_timezones_to_utc
            str = str + 'Z'
            w3cdtf str
          else
            raise err
          end
        end
      else
        str
      end
    end
    
    # Lifted from rss/rss.rb
    def self.w3cdtf(str)
      if /\A\s*
          (-?\d+)-(\d\d)-(\d\d)
          (?:T
          (\d\d):(\d\d)(?::(\d\d))?
          (\.\d+)?
          (Z|[+-]\d\d:\d\d)?)?
          \s*\z/ix =~ str and (($5 and $8) or (!$5 and !$8))
        datetime = [$1.to_i, $2.to_i, $3.to_i, $4.to_i, $5.to_i, $6.to_i] 
        datetime << $7.to_f * 1000000 if $7
        if $8
          Time.utc(*datetime) - Time.zone_offset($8)
        else
          Time.local(*datetime)
        end
      else
        raise ArgumentError.new("invalid date: #{str.inspect}")
      end
    end
    
    attr_accessor :name, :start, :scheme
    alias_method :begin, :start
    alias_method :first, :start
    
    def initialize( atts )
      @name = atts[:name]
      @start = atts[:start]
      @start.utc if @start.respond_to? :utc
      @_end = atts[:end]
      @_end.utc if @_end.respond_to? :utc
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
    
    def to_s
      components = {}
      components['name'] = name if name
      strftime_format = '%Y-%m-%dT%H:%M:%SZ'
      components['start'] = start.strftime( strftime_format ) if start
      components['end'] = self.end.strftime( strftime_format ) if self.end
      components['scheme'] = scheme if scheme
      components.map { |name, value| "#{ name }=#{ value }" }.join( "\n" )
    end
  end
end