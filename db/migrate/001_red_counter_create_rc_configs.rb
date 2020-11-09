class RedCounterCreateRcConfigs < ActiveRecord::Migration[5.2]
    def change
      create_table :rc_configs do |t|
        t.column "description", :string, :default => '', :null => false
        t.column "rc_type_id", :integer, :default => 0, :null => false
        t.column "status_id", :integer, :default => 0, :null => false
        t.column "custom_field_id", :integer, :default => 0, :null => false
        t.column "result_format", :string, :default => 'seconds', :null => false
      end
    end
end