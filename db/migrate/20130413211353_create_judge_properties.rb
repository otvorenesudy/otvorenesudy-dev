class CreateJudgeProperties < ActiveRecord::Migration
  def change
    create_table :judge_properties do |t|
      t.references :judge_property_list, null: false
      
      t.references :judge_property_acquisition_reason
      t.references :judge_property_ownership_form
      t.references :judge_property_change
      
      t.string  :description
      t.string  :acquisition_date
      t.integer :cost,             limit: 8
      t.string  :share_size
      
      t.timestamps
    end
    
    add_index :judge_properties, :judge_property_list_id
  end
end
