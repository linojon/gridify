require File.dirname(__FILE__) + '/spec_helper'

include Gridify

describe 'Grid' do
  
  it "should create with default name :grid" do
    grid = Grid.new( Chicken )
    grid.name.should == :grid
  end
  
  it "should create with given name" do
    grid = Grid.new( Chicken, :mygrid )
    grid.name.should == :mygrid
  end
    
  it "should block eval" do
    grid = Grid.new Chicken do |g|
      g.width = 450
    end
    grid.width.should == 450
  end
  
  describe "column method" do
    it "should modify existing columns"
    
    it "should create columns" do
      grid = Grid.new Chicken do |g|
        g.column 'foo', :label => "FOOBAR"
      end
      col = grid.columns_hash['foo']
      col.should_not be_nil
      col.name.should == 'foo'
      col.label.should == 'FOOBAR'
    end
    
  end
end
