module Gridify
  class GridColumn
    
    attr_accessor :name,                    # attribute name (required)
                  :label,
                  :ar_column,               # active_record column
                  :value_type,                    # active_record data type :string, :text, :integer, :float, :boolean, + :currency
                  :key,                     # true if this is the key (only :id)
                  
                  # column formatting
                  :width,                   # initial width (150)
                  :fixed_width,             # true = not resized when recalc fit to width
                  #:formatter,               # see jqGrid doc (based on value_type)
                  #:format_options,          # hash, see jqGrid doc (based on value_type)
                  :align,                   # 'left', 'right', 'center' (left for strings, right for numerics)                  
                  #:classes,                 # optional classes to add to column 
                  
                  # column actions
                  :resizable,              # t/f (true)
                  :sortable,                # t/f (true) or jqGrid sorttype: :integer, :float, :currency, :date, :text (true)
                  :searchable,              # true/false (true) or text or select
                  #:search_options,
                  :editable,                # true/false (false) or text, textarea, select, checkbox, password, button, image and file (based on value_type)
                  #:edit_options,
                  
                  # select types
                  #:select_url,              # url to dynamically get select options
                  
                  # visiblity
                  #:always_hidden,           # (false)
                  :hidden                   # initial hide state (false)
    
    def initialize(options)
      update options
    end
    
    def update(options)
      options.each {|atr, val| send( "#{atr}=", val )}
    end
    
    def to_json
      properties.to_json #_with_js
    end
    
    def properties
      jqgrid_properties
    end
    
    def resizable
      if @resizable==false
        false
      else
        # true or nil
        true
      end
    end
    
    def fixed_width
      if @fixed_width==false
        false
      elsif @fixed_width.nil?
        !resizable
      else
        @fixed_width
      end
    end
        
    # ----------------
    private
    
    def jqgrid_type
      return sortable unless sortable==true
      case value_type
      when :string   : 'text'
      when :text     : 'text'
      when :integer  : 'integer'
      when :float    : 'float'
      when :boolean  : 'boolean'
      when :datetime : 'date'
      end
    end
    
    # note, we dont vals[:foo] = foo because dont want to bother generating key if its same as jqGrid default
    def jqgrid_properties
      vals = {
        :name           => name,
        :index          => name,
        :xmlmap         => name
      }
      vals[:label]      = label || name.titleize
      vals[:resizable]  = false         if resizable==false
      vals[:fixed]      = fixed_width   unless fixed_width==false
      vals[:sortable]   = false         if sortable==false
      vals[:sorttype]   = jqgrid_type   if sortable 
      vals[:search]     = false         if searchable==false  
      vals[:editable]   = true          if editable
      vals[:align]      = 'right'       if [:integer, :float, :currency].include?(value_type)
      case value_type
      when :datetime
        vals[:formatter] = 'date'
        vals[:formatoptions] = { :srcformat => 'UniversalSortableDateTime', :newformat => 'FullDateTime' }
      end
      vals[:hidden]     = true          if hidden
      vals[:width]      = width         if width
        # and more...
        
      vals
    end
    
  end
end

#<ActiveRecord::ConnectionAdapters::SQLiteColumn:0x2515a98 @sql_type="varchar(255)", @name="title", @precision=nil, @primary=false, @default=nil, @limit=255, @null=true, @type=:string, @scale=nil>

#    grid_col :title, :searchable => false
#    grid_col :id, :hidden => :always, :key => true
#    grid_col :created_at, :formatter => 'date', :format_options => { :source_format => 'UniversalSortableDateTime', new_format: 'FullDateTime' }
# grid_model attributes
#   grid_columns, searchable, sortable, editable



    #     colNames: ['Title', 'Body', 'Created'],
    #     colModel: [
    #       { name:'title', index:'title', xmlmap: "title", search: true, editable: true },
    #       { name:'body', index:'body', xmlmap: "body", search: true, editable: true },
    #       { name:'created', index:'created', xmlmap: "created_at", 
    #           formatter: 'date', 
    #           formatoptions: { srcformat: 'UniversalSortableDateTime', newformat: 'FullDateTime' }
    #       }
    #       ],
    # 
    #     sortname: 'title',          // sort column of initial data request
    #     sortorder: 'asc',           // sort direction of initial data request
    # 
    #     rowList: [10, 20, 30],
    # 
    #   });
    # });
