require File.dirname(__FILE__) + '/spec_helper'


describe "Gridify" do
  class Chicken < ActiveRecord::Base
    gridify
  end
  describe "default" do
    it "should create one grid named :grid" do
      Chicken.grids.size.should == 1
      Chicken.grid.name.should == :grid
    end
  end

  describe "named" do
    class ChickenNamed < ActiveRecord::Base
      set_table_name :chickens
      gridify :mygrid
    end
    it "should create one grid named :grid" do
      ChickenNamed.grids.size.should == 1
      ChickenNamed.grids[:mygrid].name.should == :mygrid
    end
  end
  
  it "should find_for_grid named scope" do
    Chicken.should respond_to(:find_for_grid)
  end

  
  ## could use something like acts_as_fu to test all variations 
  ## but mostly they're all delegated to Grid class
end
 