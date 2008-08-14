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
  
  describe '==' do
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

  describe '.parse' do
    describe 'with no end' do
      before :all do
        str = <<-STR
          name=From 2008 to forever
          start=2008-01-01T01:01:00.0000000
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
        @period.start.utc_offset.should == -18000
      end
      
      it 'should have an end' do
        @period.end.should be_nil
      end
      
      it 'should have a scheme' do
        @period.scheme.should == 'W3C-DTF'
      end
    end
  
    describe 'with no name' do
      before :all do
        str = <<-STR
          start=2008-06-24T01:01:00.0000000
          end=2008-07-01T01:01:00.0000000
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
        @period.start.utc_offset.should == -14400
      end
      
      it 'should have an end' do
        @period.end.year.should       == 2008
        @period.end.month.should      == 7
        @period.end.day.should        == 1
        @period.end.hour.should       == 1
        @period.end.min.should        == 1
        @period.end.sec.should        == 0
        @period.end.utc_offset.should == -14400
      end
      
      it 'should have a scheme' do
        @period.scheme.should == 'W3C-DTF'
      end
    end
    
    describe 'with a mix of semicolons and line-endings' do
      before :all do
        str = <<-STR
          name=How long I can hold my breath; start=2008-06-24T01:01:00.0000000
          end=2008-07-01T01:01:00.0000000; scheme=W3C-DTF
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
        @period.start.utc_offset.should == -14400
      end
      
      it 'should have an end' do
        @period.end.year.should       == 2008
        @period.end.month.should      == 7
        @period.end.day.should        == 1
        @period.end.hour.should       == 1
        @period.end.min.should        == 1
        @period.end.sec.should        == 0
        @period.end.utc_offset.should == -14400
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
  end
end
