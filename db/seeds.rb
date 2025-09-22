u1 = User.create!(
  first_name: "Alice",
  last_name: "Smith",
  email: "alice@example.com",
  password: "password123",
  birthdate: "1995-01-01",
  gender: "Female",
  sexual_orientation: "Female",
  gender_interest: "Male",
  bio: "Hello, I’m Alice!",
  mobile_number: "09171234567"   # ✅ added
)

u2 = User.create!(
  first_name: "Bob",
  last_name: "Johnson",
  email: "bob@example.com",
  password: "password123",
  birthdate: "1992-05-05",
  gender: "Male",
  sexual_orientation: "Male",
  gender_interest: "Female",
  bio: "Hey, I’m Bob!",
  mobile_number: "09181234567"   # ✅ added
)

Match.create!(user_one: u1, user_two: u2)
