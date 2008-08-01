require 'rubygems'
require File.dirname(__FILE__) + '/../lib/dcmi_period.rb'

describe 'DCMI::Period.parse' do
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
end