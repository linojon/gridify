require File.dirname(__FILE__) + '/spec_helper'
include Gridify

describe "Grid finder" do
  
  def new_grid( options={} )
    @grid = Grid.new( Chicken, options )
  end
  
  def params( p={} )
    # this is like what we get in a request for grid with all default options
    {
      "controller"=>"chickens", 
      "action"=>"index", 
      "grid"=>"grid", 
      "nd"=>"1261595921149", 
      "page"=>"1", 
      "rows"=>"-1", 
      "sidx"=>"", 
      "sord"=>"asc", 
      "_search"=>"false" 
    }.merge( p )
  end
  
  describe "params" do
    it "should process sort" do
      new_grid :sortable => true
      @grid.update_from_params params(
        "sidx"=>"age", 
        "sord"=>"desc" 
      )
      @grid.sort_by.should == 'age'
      @grid.sort_order.should == 'desc'
    end
    
    it "should process page" do
      new_grid :pager => true
      @grid.update_from_params params(
        "page"=>"3", 
        "rows"=>"25" 
      )
      @grid.current_page.should == 3
      @grid.rows_per_page.should == 25
    end
    
    it "should process simple search" do
      new_grid :search_button => true
      @grid.update_from_params params(
        "_search"=>"true",
        "searchField"=>"name",
        "searchOper"=>"cn", 
        "searchString"=>"a" 
      )
      @grid.search_rules.should == [{ "field" => "name", "op" => "cn", "data" => "a"}]      
    end
    
    it "should process multiple search" do
      #debugger
      new_grid :search_advanced => true
      @grid.update_from_params params(
        "_search"=>"true",
        "filters"=> %Q^ {
          "groupOp":"OR",
          "rules":[
            {"field":"name","op":"cn","data":"a"},
            {"field":"age","op":"eq","data":"12"}
          ]}^
        )
        @grid.search_rules.should == [
          { "field" => "name", "op" => "cn", "data" => "a"},
          { "field" => "age", "op" => "eq", "data" => "12"}
          ]      
    end
    
    it "should process toolbar search" do
      new_grid :search_toolbar => true
      @grid.update_from_params params(
        "_search"=>"true",
        "name"=>"b",
        "age" => "1"
      )
      @grid.search_rules.should == [
        { "field" => "name", "op" => "cn", "data" => "b"},
        { "field" => "age", "op" => "cn", "data" => "1"}
        ]            
    end
    
  end
  
  describe "find" do
    before :each do
      Chicken.stub!(:find)
    end
    
    it "should find" do
      new_grid
      Chicken.should_receive(:find).with( :all, {} )
      @grid.find params
    end
    
    it "should find with paging" do
      new_grid :pager => true
      Chicken.should_receive(:find).with( :all, { :limit => 25, :offset => 50 })
      @grid.find params( "page"=>"3", "rows"=>"25" )      
    end
    
    it "should find with sort" do
      new_grid :sortable => true
      Chicken.should_receive(:find).with( :all, { :order => 'age desc' })
      @grid.find params( "sidx"=>"age", "sord"=>"desc" )            
    end
    
    it "should find with search" do
      # just do toolbar search, others tested above anyway
      new_grid :search_toolbar => true
      Chicken.should_receive(:find).with( :all, { :conditions => ["name LIKE ?", "%b%"] })
      @grid.find params( "_search"=>true, "name"=>"b" )                 
    end
  end
  
  describe "encode" do
    before :each do
      @records = [ 
        Chicken.create( :name => 'Achick', :age => 10 ),
        Chicken.create( :name => 'Bchick', :age => 20 )
      ]
    end
    
    it "should encode xml" do
      new_grid :pager => true, :current_page => 1, :data_type => :xml
      xml = @grid.encode_records @records
      xml.should == %Q^<?xml version="1.0" encoding="UTF-8"?>
<chickens>
  <page>1</page>
  <total_pages>1</total_pages>
  <total_records>2</total_records>
  <chicken>
    <age>10</age>
    <created_at>#{@records[0].created_at.iso8601}</created_at>
    <id>1</id>
    <name>Achick</name>
  </chicken>
  <chicken>
    <age>20</age>
    <created_at>#{@records[1].created_at.iso8601}</created_at>
    <id>2</id>
    <name>Bchick</name>
  </chicken>
</chickens>
^
    end
    
    it "should encode json" do
      new_grid :pager => true, :current_page => 1, :data_type => :json
      json = @grid.encode_records @records
#       json.should == %Q^{"total_records": 2, "page": 1, \
# "chickens": [\
# {"chicken": {"name": "Achick", "created_at": "#{@records[0].created_at.iso8601}", "id": 1, "age": 10}}, \
# {"chicken": {"name": "Bchick", "created_at": "#{@records[1].created_at.iso8601}", "id": 2, "age": 20}}\
# ], \
# "total_pages": 1}^
      json.should include('"total_records": 2')
      json.should include('"page": 1')
      json.should include('"total_pages": 1')
      json.should include(
%Q^"chickens": [\
{"name": "Achick", "created_at": "#{@records[0].created_at.iso8601}", "id": 1, "age": 10}, \
{"name": "Bchick", "created_at": "#{@records[1].created_at.iso8601}", "id": 2, "age": 20}\
]^)
    end
    
  end


  describe "member_params" do
    it "should collect attributes" do
      new_grid
      p = params(
        "name" => 'Aaa',
        "age" => '11'
      )
      @grid.member_params(p).should == { "name" => 'Aaa', "age" => '11'}
    end
  end
  
  #describe "create"
  
  #describe "update"
  
  #describe "delete"
  
end