class CreateMessages < ActiveRecord::Migration[7.0]
  def change
    create_table :messages do |t|
      t.references :conversation, null:false, foreign_key: true
      t.references :sender, null:false
      t.text :content, null:false
      t.boolean :read, default: false
      t.timestamps
    end
    add_foreign_key :messages, :users, column: :sender_id
  end
end
