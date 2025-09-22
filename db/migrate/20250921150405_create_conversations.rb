class CreateConversations < ActiveRecord::Migration[7.0]
  def change
    create_table :conversations do |t|
      t.references :user_a, null:false
      t.references :user_b, null:false
      t.timestamps
    end
    add_foreign_key :conversations, :users, column: :user_a_id
    add_foreign_key :conversations, :users, column: :user_b_id
    add_index :conversations, [:user_a_id, :user_b_id], unique: true
  end
end
