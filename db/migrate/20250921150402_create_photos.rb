class CreatePhotos < ActiveRecord::Migration[7.0]
  def change
    create_table :photos do |t|
      t.references :user, null:false, foreign_key: true
      t.integer :position, default: 0
      t.boolean :is_primary, default: false
      t.timestamps
    end
  end
end
