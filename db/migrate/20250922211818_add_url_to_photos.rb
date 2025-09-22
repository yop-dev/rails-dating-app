class AddUrlToPhotos < ActiveRecord::Migration[7.1]
  def change
    add_column :photos, :url, :string
  end
end