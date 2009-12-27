require File.dirname(__FILE__) + '/spec_helper'
include Gridify

describe "Grid view" do
  
  def new_grid( options={} )
    @grid = Grid.new( Chicken, { :build_model => false }.merge(options) )
  end
  
  #------------------------------
  describe 'default Grid view' do
    before :each do
      new_grid
    end
  
    describe "to_json" do
      it "should generate default json" do
        json = @grid.to_json
        @grid.to_json.should include('"gridview": true')
        @grid.to_json.should include('"autowidth": true')
        @grid.to_json.should include('"forceFit": true')
        @grid.to_json.should include('"hoverrows": false')
        @grid.to_json.should include('"url": "/chickens"')
        @grid.to_json.should include('"restful": true')
      end
      
      it "should extract embedded javascript:" do
        json = @grid.to_json        
        @grid.to_json.should include('"resizeStop":  gridify_fluid_recalc_width')
        @grid.to_json.should include('"beforeSelectRow":  function(){ false; }')
      end
    end
  
    describe "to_javascript" do
      it "should generate javascript" do
        @grid.to_javascript.should include('<script type="text/javascript">')
        @grid.to_javascript.should include('jQuery(document).ready(function(){')
        @grid.to_javascript.should include('jQuery("#chickens_grid").jqGrid')
      end
      it "should generate javascript without script tag" do
        @grid.to_javascript(:script => false).should_not include('<script type="text/javascript">')
      end
      it "should generate javascript without document ready" do
        @grid.to_javascript(:ready => false).should_not include('jQuery(document).ready(function(){')
      end
      it "should generate table_to_grid" do
        @grid = Grid.new( Chicken, :table_to_grid => true )
        @grid.to_javascript.should include('tableToGrid("#chickens_grid",')
      end
    end
  
    describe "to_s" do
      it "should be same as to_javascript" do
        @grid.should_receive(:to_javascript)
        @grid.to_s
      end
    end
    
    describe "dom_id" do
      it "should default to resource_name" do
        @grid.dom_id.should == "chickens_grid"
      end
    end
  end

  #------------------------------
  describe "native jqgrid_options" do
    it "should override any other set options" do
      new_grid :jqgrid_options => { :gridview => false }
      @grid.to_json.should include('"gridview": false')      
    end
    
    it "should set options not handled by Gridify" do
      new_grid :jqgrid_options => { :direction => 'rtl' }
      @grid.to_json.should include('"direction": "rtl"')
    end
  end
      
  #------------------------------
  describe "width and height options" do
    
    it "should be :width_fit => :fluid by default" do
       new_grid
       @grid.width_fit.should == :fluid
    end
    
    it "should set :width_fit => :fluid" do
      new_grid :width_fit => :fluid
      @grid.to_json.should include('"autowidth": true')
      @grid.to_json.should include('"forceFit": true')
      # recalc width after resizing columns      
      @grid.to_json.should include('"resizeStop":  gridify_fluid_recalc_width') 
      # tag the grid as fluid for the gridify_fluid_recalc_width function
      @grid.to_javascript.should include('.addClass("fluid")' )  
      # include the recalc function
      @grid.to_javascript.should include('function gridify_fluid_recalc_width(){')  
    end
    
    it "should set :width in pixels" do
      new_grid :width => 400, :width_fit => :scroll
      @grid.to_json.should include('"width": 400')
    end
    
    it "should set :width_fit => :scroll" do
      new_grid :width_fit => :scroll 
      @grid.to_json.should include('"shrinkToFit": false')            
    end
    
    it "should set :width_fit => :fitted" do
      new_grid :width_fit => :fitted 
      @grid.to_json.should include('"forceFit": true')      
    end
    
    it "should set height in pixels or :auto" do
      new_grid :height => 400 
      @grid.to_json.should include('"height": 400')
      
      new_grid :height => :auto
      @grid.to_json.should include('"height": "auto"')
    end
    
    it "should set :resizable => true width and height" do
      new_grid :width_fit => :fitted, :resizable => true
      # min width and height
      @grid.resizable.should include( "minWidth" => 150, "minHeight" => 80 )
      # set via method
      @grid.to_javascript.should include(".jqGrid('gridResize', {")
    end
    
    it "should set resizable height only when is fluid" do
      new_grid :width_fit => :fluid, :resizable => true 
      @grid.resizable.should include( "handles" => 's' )
    end
    
    it "should set resizable => new minimums" do
      new_grid :resizable => {"minWidth" => 200, "minHeight" => 250} 
      # min width and height
      @grid.resizable.should include( "minWidth" => 200, "minHeight" => 250 )
    end
      
  end
  
  #------------------------------
  describe "header options" do
    it "should set default title to model class pluralized" do
      new_grid :title => true
      @grid.to_json.should include('"caption": "Chickens"')
    end
    
    it "should set title given" do
      new_grid :title => "My Little Chickens"
      @grid.to_json.should include('"caption": "My Little Chickens"')
    end
    
    it "should set title blank when false and theres a header" do
      new_grid :collapsible => true, :title => false
      @grid.to_json.should include('"caption": "&nbsp;"')   
    end
    
    it "should set not collapsible by default" do
      new_grid :title => true
      @grid.to_json.should include('"hidegrid": false')
    end
    
    it "should set collapsible" do
      new_grid :collapsible => true
      @grid.to_json.should_not include('"hidegrid": false') #default is true      
    end
    
    it "should set collapsed state" do
      new_grid :collapsed => true
      @grid.to_json.should include('"hiddengrid": true')     
    end
  end
  
  #------------------------------
  describe "pager options" do
    
    it "should set pager with id {dom_id}_pager" do
      new_grid :pager => true
      @grid.to_json.should include('"pager": "#chickens_grid_pager"')
    end
    
    it "should set pager with id given" do
      new_grid :pager => 'other_pgr'
      @grid.to_json.should include('"pager": "#other_pgr"')
    end
    
    it "should set paging_choices default" do
      new_grid :pager => true
      @grid.to_json.should include('"rowList": [10, 25, 50, 100]')
    end
    
    it "should set paging_choices given" do
      new_grid :pager => true, :paging_choices => [25, 50, 150]
      @grid.to_json.should include('"rowList": [25, 50, 150]')
    end
    
    it "should set to hide paging_controls when false" do
      new_grid :pager => true, :paging_controls => false
      @grid.to_json.should include('"rowList": []')
      @grid.to_json.should include('"pgbuttons": false')
      @grid.to_json.should include('"pginput": false')
    end

    it "should override paging_controls when given" do
      new_grid :pager => true, :paging_controls => { :pgbuttons => false }
      @grid.to_json.should include('"pgbuttons": false')
      @grid.to_json.should_not include('"pginput":') #to assert not like paging_controls => false
    end
    
    it "should display records count text" do
      new_grid :pager => true
      @grid.to_json.should include('"viewrecords": true')
    end
    
    it "should not display page number when paging_controls false" do
      new_grid :pager => true, :paging_controls => false
      @grid.to_json.should include('"recordtext": "{2} records"')
    end
  end
  
  #------------------------------
  describe "columns arranger" do
    it "should set :arranger => :sortable to allow sortable with mouse" do
      new_grid :arranger => :sortable
      @grid.to_json.should include('"sortable": true')
    end
    
    it "should set :arranger => :hide_show a pager button for setColumns" do
      new_grid :arranger => :hide_show
      @grid.to_javascript.should include("navButtonAdd")
      @grid.to_javascript.should include("setColumns")
      # with this, we'll assume the actual js is there
    end
    
    it "should set :arranger => [:sortable, :hide_show]" do
      new_grid :arranger => [:sortable, :hide_show]
      @grid.to_json.should include('"sortable": true')
      @grid.to_javascript.should include("navButtonAdd")
      @grid.to_javascript.should include("setColumns")      
    end
    
    it "should set :arranger => :chooser" do
      new_grid :arranger => :chooser
      @grid.to_javascript.should include("navButtonAdd")
      @grid.to_javascript.should include("remapColumns")
      # with this, we'll assume the actual js is there
    end
    
    it "should set jqGrid native options when hash values" do
      new_grid :arranger => {:hide_show => {:title => "Use checkbox for column visiblity"}}
      @grid.to_javascript.should include('"title": "Use checkbox for column visiblity"') #not a wonderful test but something     
    end
  end
  
  #------------------------------
  describe "rows" do
    it "should set alt_rows => true with default class" do
      new_grid :alt_rows => true
      @grid.to_json.should include('"altrows": true')
    end
      
    it "should set alt_rows => css class" do
      new_grid :alt_rows => 'odd'
      @grid.to_json.should include('"altrows": true')
      @grid.to_json.should include('"altclass": "odd"')
    end
    
    it "should set row_numbers => true with default width" do
      new_grid :row_numbers => true
      @grid.to_json.should include('"rowNumbers": true')      
    end
    
    it "should set row_numbers => nn to set width" do
      new_grid :row_numbers => 24
      @grid.to_json.should include('"rowNumbers": true')      
      @grid.to_json.should include('"rownumWidth": 24')      
    end
    
    it "should set select_rows => false by default" do
      new_grid
      @grid.select_rows.should be_nil
    end
    
    it "should set select_rows => true when pager buttons for show, edit, or delete enabled"
    
    it "should set select_rows => javascript"
    
    
  end
  #------------------------------
  describe "nav buttons" do
    it "edit_button => true with default action parameters" do
      new_grid :pager => true, :edit_button => true
      @grid.to_javascript.should include(".navGrid('#chickens_grid_pager'")
      @grid.to_javascript.should include('"edit": true')
      #:reloadAfterSubmit => false, :closeAfterEdit => true
    end
    
    it "add_button => true with default action parameters" do
      new_grid :pager => true, :add_button => true
      @grid.to_javascript.should include(".navGrid('#chickens_grid_pager'")
      @grid.to_javascript.should include('"add": true')
      #:reloadAfterSubmit => false, :closeAfterEdit => true
    end
    
    it "delete_button => true with default action parameters" do
      new_grid :pager => true, :delete_button => true
      @grid.to_javascript.should include(".navGrid('#chickens_grid_pager'")
      @grid.to_javascript.should include('"del": true')
      #:reloadAfterSubmit => false
    end 
    
    it "search_button => true with default action parameters" do
      new_grid :pager => true, :search_button => true
      @grid.to_javascript.should include(".navGrid('#chickens_grid_pager'")
      @grid.to_javascript.should include('"search": true')
    end
    
    it "view_button => true with default action parameters" do
      new_grid :pager => true, :view_button => true
      @grid.to_javascript.should include(".navGrid('#chickens_grid_pager'")
      @grid.to_javascript.should include('"view": true')
    end
    # it "view_button => " do
    #   new_grid :pager => true, :show_button => {}
    #   @grid.to_json.should include('.navGrid("#chicken_grid_pager"')
    #   @grid.to_json.should include('view:true')
    # end
    
    it "refresh_button" do
      new_grid :pager => true, :refresh_button => true
      @grid.to_javascript.should include(".navGrid('#chickens_grid_pager'")
      @grid.to_javascript.should include('"refresh": true')
    end
  end
  
  #------------------------------
  describe "search" do
    it "should set search_toolbar" do
      new_grid :search_toolbar => true
      @grid.to_javascript.should include("filterToolbar")
      # test lacks details
    end
  end
  
  #------------------------------
  describe "data" do
    it "should set url to REST route based on resource" do
      new_grid
      @grid.to_json.should include('"url": "/chickens"')      
    end
    
    it "should enable restful requests" do
      new_grid
      @grid.to_json.should include('"restful": true')
    end
    
    it "should set data_type" do
      new_grid :data_type => :json
      @grid.to_json.should include('"datatype": "json"')
    end

    it "should set data_format" do
      new_grid :data_format => {:root => 'ducks', :page => 'ducks>page', :total => 'ducks>total_pages', :records => 'ducks>total_records', :row => 'duck', :repeatitems => :false, :id => :id}
      
      #@grid.to_json.should include('"xmlReader": {"records": "ducks>total_records", "row": "duck", "repeatitems": "false", "root": "ducks", "page": "ducks>page", "id": "id", "total": "ducks>total_pages"}')
      @grid.to_json.should include('xmlReader')
    end
    
    it "should omit data_format when false" do
      new_grid :data_format => false
      @grid.to_json.should_not include('xmlReader')
    end

    it "should set sort_by for next request" do
      new_grid :sort_by => :body
      @grid.to_json.should include('"sortname": "body"')
    end

    it "should set sort_order direction for next request" do
      new_grid :sort_by => :body, :sort_order => :desc
      @grid.to_json.should include('"sortorder": "desc"')
    end

    describe "rows_per_page" do
      it "should set rows_per_page for next request" do
        new_grid :pager => true, :rows_per_page => 18
        @grid.to_json.should include('"rowNum": 18')
      end
      it "should set rows_per_page to false for no paging" do
        new_grid :pager => true, :rows_per_page => false
        @grid.to_json.should include('"rowNum": -1')
      end
      it "should set rows_per_page to false when no pager" do
        new_grid
        @grid.to_json.should include('"rowNum": -1')
      end      
      it "should set rows_per_page to false when no pager controls" do
        new_grid :pager => true, :paging_controls => false
        @grid.to_json.should include('"rowNum": -1')
      end
    end
    
    it "should set load_once" do
      new_grid :load_once => true
      @grid.to_json.should include('"loadonce": true')
    end
    
    it "should include grid name in requests" do
      new_grid
      @grid.to_json.should include('"postData": {"grid": "grid"}')
      mygrid = Grid.new( Chicken, :mygrid )
      mygrid.to_json.should include('"postData": {"grid": "mygrid"}')
    end
    
    it "should set col_names"
    it "should set col_model"
  end
  #------------------------------

end