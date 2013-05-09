class CreateAttributeChangerAttributeChanges < ActiveRecord::Migration
  def change
    create_table :attribute_changer_attribute_changes do |t|
      t.string :obj_type
      t.integer :obj_id
      t.string :attrib
      t.string :value
      t.string :status
      
      t.timestamps
    end
  end
end