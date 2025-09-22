class CreateUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :users do |t|
      t.string :first_name, null:false
      t.string :last_name, null:false
      t.string :mobile_number, null:false
      t.string :email, null:false, index: { unique: true }
      t.date   :birthdate, null:false
      t.string :gender, null:false
      t.string :sexual_orientation, null:false
      t.string :gender_interest, null:false
      t.string :country
      t.string :state
      t.string :city
      t.string :school
      t.text   :bio, null:false
      t.string :password_digest, null:false
      t.string :role, default: "user", null:false
      t.timestamps
    end
  end
end
