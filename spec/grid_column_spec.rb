require File.dirname(__FILE__) + '/spec_helper'
include Gridify

describe "Grid column model" do
  
  def new_grid( options={} )
    @grid = Grid.new( Chicken, options )
  end

  #------------------------------
  it "should build for all attributes" do
    new_grid
    names = @grid.columns.map {|col| col.name}
    names.should == ['id', 'name', 'age', 'created_at']
  end
  
  it "should handle :except option" do
    new_grid :except => 'age'
    names = @grid.columns.map {|col| col.name}
    names.should_not include('age')
  end
  
  it "should handle :only option" do
    new_grid :only => ['id', 'age']
    names = @grid.columns.map {|col| col.name}
    names.should_not include('name')
    names.should include('age')
  end
  
  it "should support searchable per model" do
    new_grid :searchable => false
    @grid.columns.each do |col|
      col.to_json.should include('"search": false')
    end
  end
    
  it "should support editable per model" do
    new_grid :editable => true
    @grid.columns.each do |col|
      unless col.key
        col.to_json.should include('"editable": true')
      end
    end
  end
  
  it "should support sortable per model" do
    new_grid :sortable => false
    @grid.columns.each do |col|
      col.to_json.should include('"sortable": false')
    end
  end
  
  #it "should support default column widths"

  it 'should get column_names' do
    new_grid
    @grid.column_names.should == ['Id', 'Name', 'Age', 'Created At']
  end
  
  it "should generate column_model" do
    new_grid
    @grid.columns[0].properties.should == {:name => "id", :label => "Id", :index => "id", :align => "right", :sorttype => "integer", :hidden => true}
    @grid.columns[1].properties.should == {:name => "name", :label => "Name", :index => "name", :sorttype => "text" }
    @grid.columns[2].properties.should == {:name => "age", :label => "Age", :index => "age", :align => "right", :sorttype => "integer"}
    @grid.columns[3].properties.should == {:name => "created_at", :label => "Created At", :index => "created_at", :sorttype => "date", :formatter=>"date", :formatoptions=>{:newformat=>"FullDateTime", :srcformat=>"UniversalSortableDateTime"} }
  end
  
  it "should set current visiblity"
  it "should set current width"
  it "should set current column order"
  
end
