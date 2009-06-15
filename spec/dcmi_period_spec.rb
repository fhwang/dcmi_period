require 'rubygems'
require File.dirname(__FILE__) + '/../lib/dcmi_period.rb'

describe 'DCMI::Period' do
  describe 'instance' do
    before :all do
      @start_time = Time.now.utc
      @end_time = Time.now.utc + ( 10 * 60 )
      @period = DCMI::Period.new(
        :name => 'The next ten minutes', :start => @start_time,
        :end => @end_time, :scheme => 'W3C-DTF'
      )
    end
  
    it 'should use begin and first as aliases of start' do
      @period.begin.should == @start_time
      @period.first.should == @start_time
    end
  end
  
  describe '#==' do
    before :all do
      @start_time = Time.now.utc
      @end_time = Time.now.utc + ( 10 * 60 )
      @period = DCMI::Period.new(
        :name => 'The next ten minutes', :start => @start_time,
        :end => @end_time, :scheme => 'W3C-DTF'
      )
    end
    
    it 'should be true for another instance with same start, end, and scheme' do
      period2 = DCMI::Period.new(
        :name => 'The next six-hundred seconds', :start => @start_time,
        :end => @end_time, :scheme => 'W3C-DTF'
      )
      @period.should == period2
      period2.should == @period
    end
    
    it 'should be false for a Range' do
      range = @start_time..@end_time
      @period.should_not == range
      range.should_not   == @period
    end
    
    it 'should be false for another instance with different start' do
      period2 = DCMI::Period.new(
        :name => 'Ten minutes and one second', :start => @start_time - 1,
        :end => @end_time, :scheme => 'W3C-DTF'
      )
      @period.should_not == period2
      period2.should_not == @period
    end
    
    it 'should be false for another instance with different end' do
      period2 = DCMI::Period.new(
        :name => 'Ten minutes and one second', :start => @start_time,
        :end => @end_time + 1, :scheme => 'W3C-DTF'
      )
      @period.should_not == period2
      period2.should_not == @period
    end
    
    it 'should be false for another instance with different scheme' do
      period2 = DCMI::Period.new(
        :name => 'Phanerozoic Eon', :start => 'Cambrian period',
        :scheme => 'Geological timescale'
      )
      @period.should_not == period2
      period2.should_not == @period
    end
  end
  
  describe '#to_s' do
    before :all do
      @start_time = Time.utc( 2006, 1, 1, 1, 1 )
      @end_time = Time.utc( 2010, 1, 1, 1, 1 )
      @period = DCMI::Period.new(
        :name => '2006 to 2010', :start => @start_time,
        :end => @end_time, :scheme => 'W3C-DTF'
      )
      @string = @period.to_s
    end

    it 'should contain the name' do
      @string.should match( /name=2006 to 2010/ )
    end

    it 'should contain the start' do
      @string.should match( /start=2006-01-01T01:01:00Z/ )
    end

    it 'should contain the end' do
      @string.should match( /end=2010-01-01T01:01:00Z/ )
    end

    it 'should contain the scheme' do
      @string.should match( /scheme=W3C-DTF/ )
    end
    
    it 'should be parseable by DCMI::Period.parse' do
      period2 = DCMI::Period.parse @string
      period2.should == @period
    end
  end

  describe '.parse' do
    describe 'with no end' do
      before :all do
        str = <<-STR
          name=From 2008 to forever
          start=2008-01-01T01:01:00Z
          scheme=W3C-DTF
        STR
        @period = DCMI::Period.parse str
      end
    
      it 'should have a name' do
        @period.name.should == 'From 2008 to forever'
      end
      
      it 'should have a start' do
        @period.start.year.should       == 2008
        @period.start.month.should      == 1
        @period.start.day.should        == 1
        @period.start.hour.should       == 1
        @period.start.min.should        == 1
        @period.start.sec.should        == 0
        @period.start.utc_offset.should == 0
      end
      
      it 'should not have an end' do
        @period.end.should be_nil
      end
      
      it 'should have a scheme' do
        @period.scheme.should == 'W3C-DTF'
      end
    end
  
    describe 'with no name' do
      before :all do
        str = <<-STR
          start=2008-06-24T01:01:00Z
          end=2008-07-01T01:01:00Z
          scheme=W3C-DTF
        STR
        @period = DCMI::Period.parse str
      end
    
      it 'should have no name' do
        @period.name.should be_nil
      end
      
      it 'should have a start' do
        @period.start.year.should       == 2008
        @period.start.month.should      == 6
        @period.start.day.should        == 24
        @period.start.hour.should       == 1
        @period.start.min.should        == 1
        @period.start.sec.should        == 0
        @period.start.utc_offset.should == 0
      end
      
      it 'should have an end' do
        @period.end.year.should       == 2008
        @period.end.month.should      == 7
        @period.end.day.should        == 1
        @period.end.hour.should       == 1
        @period.end.min.should        == 1
        @period.end.sec.should        == 0
        @period.end.utc_offset.should == 0
      end
      
      it 'should have a scheme' do
        @period.scheme.should == 'W3C-DTF'
      end
    end
    
    describe 'with a mix of semicolons and line-endings' do
      before :all do
        str = <<-STR
          name=How long I can hold my breath; start=2008-06-24T01:01:00Z
          end=2008-07-01T01:01:00Z; scheme=W3C-DTF
        STR
        @period = DCMI::Period.parse str
      end
    
      it 'should have a name' do
        @period.name.should == 'How long I can hold my breath'
      end
      
      it 'should have a start' do
        @period.start.year.should       == 2008
        @period.start.month.should      == 6
        @period.start.day.should        == 24
        @period.start.hour.should       == 1
        @period.start.min.should        == 1
        @period.start.sec.should        == 0
        @period.start.utc_offset.should == 0
      end
      
      it 'should have an end' do
        @period.end.year.should       == 2008
        @period.end.month.should      == 7
        @period.end.day.should        == 1
        @period.end.hour.should       == 1
        @period.end.min.should        == 1
        @period.end.sec.should        == 0
        @period.end.utc_offset.should == 0
      end
      
      it 'should have a scheme' do
        @period.scheme.should == 'W3C-DTF'
      end
    end
  
    describe "with a scheme I can't parse" do
      before :all do
        str = <<-STR
          name=Phanerozoic Eon; start=Cambrian period
          end=Some other period; scheme=Geological timescale
        STR
        @period = DCMI::Period.parse str
      end
    
      it 'should have a name' do
        @period.name.should == 'Phanerozoic Eon'
      end
    
      it 'should not try to parse start or end' do
        @period.start.should == 'Cambrian period'
        @period.end.should == 'Some other period'
      end
      
      it 'should have a scheme' do
        @period.scheme.should == 'Geological timescale'
      end
    end
    
    describe 'when the specified scheme is W3C-DTF but the timezone is missing' do
      before :all do
        @str = <<-STR
          name=From 2008 to forever
          start=2008-01-01T01:01:00
          scheme=W3C-DTF
        STR
      end
      
      it 'should raise a parse error' do
        lambda {
          DCMI::Period.parse @str
        }.should raise_error(
          ArgumentError, "start time '2008-01-01T01:01:00' could not be parsed"
        )
      end
    end
    
    describe "when the specified scheme is W3C-DTF but start and end times can't be parsed" do
      before :all do
        @str = <<-STR
          name=From 2008 to forever
          start=0000-00-00T00:00:00Z
          end=0000-00-00T00:00:00Z
          scheme=W3C-DTF
        STR
      end
      
      it 'should raise an ArgumentError' do
        lambda {
          DCMI::Period.parse @str
        }.should raise_error(
          ArgumentError,
          "start time '0000-00-00T00:00:00Z' could not be parsed; end time '0000-00-00T00:00:00Z' could not be parsed"
        )
      end
    end
    
    describe 'with decimal fractions of seconds' do
      before :all do
        str = <<-STR
          name=From 2008 to 2009
          start=2008-01-01T01:01:00.123456Z
          end=2009-01-01T01:01:00.1234567Z
          scheme=W3C-DTF
        STR
        @period = DCMI::Period.parse str
      end
    
      it 'should have a name' do
        @period.name.should == 'From 2008 to 2009'
      end
      
      it 'should have a start' do
        @period.start.year.should       == 2008
        @period.start.month.should      == 1
        @period.start.day.should        == 1
        @period.start.hour.should       == 1
        @period.start.min.should        == 1
        @period.start.sec.should        == 0
        @period.start.usec.should       == 123456
        @period.start.utc_offset.should == 0
      end
      
      it 'should have an end' do
        @period.end.year.should       == 2009
        @period.end.month.should      == 1
        @period.end.day.should        == 1
        @period.end.hour.should       == 1
        @period.end.min.should        == 1
        @period.end.sec.should        == 0
        @period.end.usec.should       == 123456
        @period.end.utc_offset.should == 0
      end
      
      it 'should have a scheme' do
        @period.scheme.should == 'W3C-DTF'
      end
    end
    
    describe 'with an invalid blank component value' do
      before :all do
        @str = <<-STR
          start=2008-01-01T01:01:00Z;end=;scheme=W3C-DTF
        STR
      end
      
      it 'should normally raise an ArgumentError' do
        lambda {
          DCMI::Period.parse @str
        }.should raise_error(
          ArgumentError, "end time '' could not be parsed"
        )
      end
    end
  end
  
  describe '.parse with custom time string transforms' do
    before :all do
      @base_str = <<-STR
        name=From 2008 to forever
        start=START_TIME
        scheme=W3C-DTF
      STR
      @time_string_transforms = [
        Proc.new { |time_string| time_string + 'Z' },
        Proc.new { |time_string|
          time_string.gsub(
            /(\d{4}-\d{2}-\d{2}T\d{2})\.(\d{2}:\d{2}Z)/, '\1:\2'
          )
        },
        Proc.new { |time_string|
          time_string.gsub(
            /(\d{4}-\d{2}-\d{2}T\d{2}\:\d{2}-\d{2})(\d{2})/, '\1:\2'
          )
        },
        Proc.new { |time_string| (time_string =~ /^\s*$/) ? nil : time_string }
      ]
    end
    
    describe 'with a missing timezone' do
      before :all do
        str = @base_str.gsub /START_TIME/, '2008-01-01T01:01:00'
        @period = DCMI::Period.parse(
          str, :time_string_transforms => @time_string_transforms
        )
      end
      
      it 'should force to UTC' do
        @period.start.year.should       == 2008
        @period.start.month.should      == 1
        @period.start.day.should        == 1
        @period.start.hour.should       == 1
        @period.start.min.should        == 1
        @period.start.sec.should        == 0
        @period.start.utc_offset.should == 0
      end
      
      it 'should have some useful info' do
        @period.info.should ==
            "start time '2008-01-01T01:01:00' doesn't conform to W3C-DTF; parsed as '2008-01-01T01:01:00Z'"
      end
    end
    
    describe "with bad format '2010-05-14T12.00:00Z'" do
      before :all do
        str = @base_str.gsub /START_TIME/, '2010-05-14T12.00:00Z'
        @period = DCMI::Period.parse(
          str, :time_string_transforms => @time_string_transforms
        )
      end
      
      it 'should set hour-min divider appropriately' do
        @period.start.year.should       == 2010
        @period.start.month.should      == 5
        @period.start.day.should        == 14
        @period.start.hour.should       == 12
        @period.start.min.should        == 0
        @period.start.sec.should        == 0
        @period.start.utc_offset.should == 0
      end
      
      it 'should have some useful info' do
        @period.info.should ==
            "start time '2010-05-14T12.00:00Z' doesn't conform to W3C-DTF; parsed as '2010-05-14T12:00:00Z'"
      end
    end
    
    describe "with bad format '2009-05-12T19:00-0700'" do
      before :all do
        str = @base_str.gsub /START_TIME/, '2009-05-12T19:00-0700'
        @period = DCMI::Period.parse(
          str, :time_string_transforms => @time_string_transforms
        )
      end
      
      it 'should set time offset appropriately' do
        @period.start.year.should       == 2009
        @period.start.month.should      == 5
        @period.start.day.should        == 13
        @period.start.hour.should       == 2
        @period.start.min.should        == 0
        @period.start.sec.should        == 0
        @period.start.utc_offset.should == 0
      end
      
      it 'should have some useful info' do
        @period.info.should ==
            "start time '2009-05-12T19:00-0700' doesn't conform to W3C-DTF; parsed as '2009-05-12T19:00-07:00'"
      end
    end
    
    describe "with bad format 'monkey'" do
      before :all do
        @str = @base_str.gsub /START_TIME/, 'monkey'
      end
      
      it 'should raise an ArgumentError' do
        lambda {
          DCMI::Period.parse(
            @str, :time_string_transforms => @time_string_transforms
          )
        }.should raise_error(
          ArgumentError, "start time 'monkey' could not be parsed"
        )
      end
    end
    
    describe 'with a blank component value' do
      before :all do
        str = @base_str.gsub /START_TIME/, ''
        @period = DCMI::Period.parse(
          str, :time_string_transforms => @time_string_transforms
        )
      end
      
      it 'should simply accept that as a nil value' do
        @period.start.should be_nil
      end
      
      it 'should have some useful info' do
        @period.info.should ==
            "start time '' doesn't conform to W3C-DTF; set to nil"
      end
    end
  end
  
  describe '.parse of a string that incorrectly uses non-newline whitespace to delimit' do
    before :all do
      @str = <<-STR
                 start=2008-12-13T05:01:00Z
        end=2010-01-31T11:00:00Z          scheme=W3C-DTF       
      STR
    end
    
    describe 'when parsing according to the standard' do
      it 'should raise a parse error' do
        lambda {
          DCMI::Period.parse @str
        }.should raise_error(
          ArgumentError,
          "end time '2010-01-31T11:00:00Z          scheme=W3C-DTF' could not be parsed"
        )
      end
    end
    
    describe 'when parsing with :accept_any_whitespace_to_separate_components' do
      before :all do
        @period = DCMI::Period.parse(
          @str, :accept_any_whitespace_to_separate_components => true
        )
      end
    
      it 'should not have a name' do
        @period.name.should be_nil
      end
      
      it 'should have a start' do
        @period.start.year.should       == 2008
        @period.start.month.should      == 12
        @period.start.day.should        == 13
        @period.start.hour.should       == 5
        @period.start.min.should        == 1
        @period.start.sec.should        == 0
        @period.start.usec.should       == 0
        @period.start.utc_offset.should == 0
      end
      
      it 'should have an end' do
        @period.end.year.should       == 2010
        @period.end.month.should      == 1
        @period.end.day.should        == 31
        @period.end.hour.should       == 11
        @period.end.min.should        == 0
        @period.end.sec.should        == 0
        @period.end.usec.should       == 0
        @period.end.utc_offset.should == 0
      end
      
      it 'should have a scheme' do
        @period.scheme.should == 'W3C-DTF'
      end
    end
  end
end
