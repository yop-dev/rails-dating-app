class CreateLikes < ActiveRecord::Migration[7.0]
  def change
    create_table :likes do |t|
      t.references :liker, null:false
      t.references :liked, null:false
      t.boolean :is_like, default: true
      t.timestamps
    end

    add_foreign_key :likes, :users, column: :liker_id
    add_foreign_key :likes, :users, column: :liked_id
    add_index :likes, [:liker_id, :liked_id], unique: true
  end
end
