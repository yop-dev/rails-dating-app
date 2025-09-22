class CreateMatches < ActiveRecord::Migration[7.0]
  def change
    create_table :matches do |t|
      t.references :user_one, null:false
      t.references :user_two, null:false
      t.timestamps
    end

    add_foreign_key :matches, :users, column: :user_one_id
    add_foreign_key :matches, :users, column: :user_two_id
    add_index :matches, [:user_one_id, :user_two_id], unique: true
  end
end
