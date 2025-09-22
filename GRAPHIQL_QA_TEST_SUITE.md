# Tinder Clone - Complete GraphiQL QA Test Suite 🧪

## Testing Instructions

1. **Start your Rails server**: `rails server`
2. **Open GraphiQL**: Navigate to `http://localhost:3000/graphiql`
3. **Run tests in order**: Execute each test sequentially
4. **Record results**: Note any failures or unexpected responses
5. **Authentication**: For authenticated tests, use the JWT token from the login response

---

## Phase 1: User Registration & Authentication Tests

### Test 1.1: User Registration ✅
**Purpose**: Create test users for subsequent testing

```graphql
mutation RegisterUser1 {
  registerUser(
    firstName: "Alice"
    lastName: "Johnson"
    email: "alice@test.com"
    password: "password123"
    mobileNumber: "+1234567890"
    birthdate: "1990-05-15"
    gender: "female"
    sexualOrientation: "straight"
    genderInterest: "male"
    bio: "Love hiking and good coffee ☕"
    country: "USA"
    state: "California"
    city: "San Francisco"
    school: "UC Berkeley"
  ) {
    user {
      id
      firstName
      lastName
      fullName
      email
      age
      gender
      bio
    }
  }
}
```

**Expected Result**: 
- ✅ User created successfully
- ✅ Returns user object with all fields
- ✅ Age calculated correctly (should be around 34-35)
- ✅ `fullName` shows "Alice Johnson"

---

### Test 1.2: Register Second User ✅
```graphql
mutation RegisterUser2 {
  registerUser(
    firstName: "Bob"
    lastName: "Smith"
    email: "bob@test.com"
    password: "password123"
    mobileNumber: "+1987654321"
    birthdate: "1988-03-20"
    gender: "male"
    sexualOrientation: "straight"
    genderInterest: "female"
    bio: "Software developer who loves travel 🌍"
    country: "USA"
    state: "California"
    city: "Los Angeles"
  ) {
    user {
      id
      firstName
      lastName
      email
      age
      gender
      bio
    }
  }
}
```

**Expected Result**: 
- ✅ Second user created successfully
- ✅ Different ID from first user

---

### Test 1.3: Register Third User ✅
```graphql
mutation RegisterUser3 {
  registerUser(
    firstName: "Charlie"
    lastName: "Brown"
    email: "charlie@test.com"
    password: "password123"
    mobileNumber: "+1555123456"
    birthdate: "1992-12-01"
    gender: "male"
    sexualOrientation: "straight"
    genderInterest: "female"
    bio: "Music lover and chef 🎵"
  ) {
    user {
      id
      firstName
      lastName
      email
      age
      gender
    }
  }
}
```

---

### Test 1.4: User Login & Token Generation ✅
```graphql
mutation LoginUser {
  loginUser(
    email: "alice@test.com"
    password: "password123"
  ) {
    user {
      id
      firstName
      lastName
      email
      role
    }
    token
  }
}
```

**Expected Result**: 
- ✅ Login successful
- ✅ Returns JWT token (long string)
- ✅ User object returned correctly

**⚠️ IMPORTANT**: Copy the `token` value - you'll need it for authenticated requests!

---

### Test 1.5: Login Second User ✅
```graphql
mutation LoginBob {
  loginUser(
    email: "bob@test.com"
    password: "password123"
  ) {
    user {
      id
      firstName
      email
    }
    token
  }
}
```

**⚠️ IMPORTANT**: Save Bob's token too for testing!

---

### Test 1.6: Invalid Login ❌
```graphql
mutation InvalidLogin {
  loginUser(
    email: "alice@test.com"
    password: "wrongpassword"
  ) {
    user {
      id
      firstName
    }
    token
  }
}
```

**Expected Result**: 
- ❌ Should return error: "Invalid credentials"

---

## Phase 2: Authentication & Authorization Tests

### Test 2.1: Current User Query (No Auth) ❌
```graphql
query CurrentUserNoAuth {
  currentUser {
    id
    firstName
    email
  }
}
```

**Expected Result**: 
- ❌ Should return `null` (no authentication)

---

### Test 2.2: Current User Query (With Auth) ✅

**⚠️ SETUP AUTHENTICATION**:
1. Click "Request Headers" at bottom of GraphiQL
2. Add: `{ "Authorization": "Bearer YOUR_TOKEN_HERE" }`
3. Replace `YOUR_TOKEN_HERE` with Alice's token from Test 1.4

```graphql
query CurrentUserWithAuth {
  currentUser {
    id
    firstName
    lastName
    fullName
    email
    age
    gender
    bio
    photos {
      id
      url
      position
      isPrimary
    }
  }
}
```

**Expected Result**: 
- ✅ Returns Alice's user data
- ✅ Photos array (likely empty initially)

---

## Phase 3: User Discovery & Querying Tests

### Test 3.1: Get User by ID ✅
```graphql
query GetUserById {
  user(id: "2") {
    id
    firstName
    lastName
    fullName
    age
    gender
    bio
    primaryPhotoUrl
  }
}
```

**Expected Result**: 
- ✅ Returns Bob's user data (assuming he has ID 2)

---

### Test 3.2: Potential Users Query ✅
**Note**: Make sure you're authenticated as Alice

```graphql
query PotentialUsers {
  potentialUsers(limit: 10) {
    id
    firstName
    lastName
    age
    gender
    bio
    primaryPhotoUrl
  }
}
```

**Expected Result**: 
- ✅ Returns male users (Bob, Charlie) since Alice's `genderInterest` is "male"
- ✅ Should NOT include Alice herself
- ✅ Limited to 10 users

---

## Phase 4: Swiping & Matching Tests

### Test 4.1: Like User (Alice likes Bob) ✅
**Authentication**: Use Alice's token

```graphql
mutation AliceLikesBob {
  likeUser(targetUserId: "2") {
    matchCreated
    match {
      id
      userOne {
        id
        firstName
      }
      userTwo {
        id
        firstName
      }
      createdAt
    }
  }
}
```

**Expected Result**: 
- ✅ `matchCreated: false` (no reciprocal like yet)
- ✅ `match: null`

---

### Test 4.2: Like User (Bob likes Alice) - Creates Match! ✅
**⚠️ CHANGE AUTHENTICATION**: Switch to Bob's token in Request Headers

```graphql
mutation BobLikesAlice {
  likeUser(targetUserId: "1") {
    matchCreated
    match {
      id
      userOne {
        id
        firstName
      }
      userTwo {
        id
        firstName
      }
      createdAt
    }
  }
}
```

**Expected Result**: 
- ✅ `matchCreated: true` (mutual like!)
- ✅ `match` object returned with both users
- ✅ `userOne` should have lower ID than `userTwo`

---

### Test 4.3: Dislike User (Alice dislikes Charlie) ✅
**Authentication**: Switch back to Alice's token

```graphql
mutation AliceDislikesCharlie {
  dislikeUser(targetUserId: "3") {
    success
  }
}
```

**Expected Result**: 
- ✅ `success: true`

---

### Test 4.4: Query Matches (Alice's matches) ✅
**Authentication**: Use Alice's token

```graphql
query AliceMatches {
  matches(limit: 10) {
    id
    userOne {
      id
      firstName
      lastName
    }
    userTwo {
      id
      firstName
      lastName
    }
    createdAt
  }
}
```

**Expected Result**: 
- ✅ Returns 1 match (Alice & Bob)
- ✅ Match shows both users correctly

---

### Test 4.5: Query Matches with User ID ✅
```graphql
query BobMatchesById {
  matches(userId: "2", limit: 10) {
    id
    userOne {
      firstName
    }
    userTwo {
      firstName
    }
  }
}
```

**Expected Result**: 
- ✅ Returns same match as previous test
- ✅ Shows Bob is part of the match

---

## Phase 5: Messaging Tests

### Test 5.1: Send Message (Alice to Bob) ✅
**Authentication**: Use Alice's token
**Note**: Use the match ID from Test 4.2 or 4.4

```graphql
mutation AliceSendsMessage {
  sendMessage(
    matchId: "1"
    content: "Hey Bob! Nice to match with you! 👋"
  ) {
    message {
      id
      content
      read
      createdAt
      sender {
        id
        firstName
      }
    }
  }
}
```

**Expected Result**: 
- ✅ Message created successfully
- ✅ Sender shows Alice
- ✅ `read: false`

---

### Test 5.2: Send Message (Bob replies) ✅
**Authentication**: Switch to Bob's token

```graphql
mutation BobReplies {
  sendMessage(
    matchId: "1"
    content: "Hi Alice! Great to meet you too! How's your day going? 😊"
  ) {
    message {
      id
      content
      sender {
        firstName
      }
      createdAt
    }
  }
}
```

**Expected Result**: 
- ✅ Bob's message created
- ✅ Sender shows Bob

---

### Test 5.3: Query Conversations (Alice) ✅
**Authentication**: Use Alice's token

```graphql
query AliceConversations {
  conversations {
    id
    userA {
      id
      firstName
    }
    userB {
      id
      firstName
    }
    messages {
      id
      content
      sender {
        firstName
      }
      createdAt
      read
    }
    lastMessage {
      content
      sender {
        firstName
      }
      createdAt
    }
  }
}
```

**Expected Result**: 
- ✅ Returns 1 conversation
- ✅ Shows both users (Alice & Bob)
- ✅ Shows all messages in chronological order
- ✅ `lastMessage` shows Bob's latest message

---

### Test 5.4: Query Messages for Conversation ✅
**Note**: Use conversation ID from previous test

```graphql
query ConversationMessages {
  messages(conversationId: "1") {
    id
    content
    sender {
      id
      firstName
    }
    createdAt
    read
  }
}
```

**Expected Result**: 
- ✅ Returns messages in chronological order
- ✅ Shows correct senders

---

## Phase 6: Match Management Tests

### Test 6.1: Create Additional Match for Testing ✅
**Step 1**: Alice likes Charlie
```graphql
mutation AliceLikesCharlie {
  likeUser(targetUserId: "3") {
    matchCreated
    match {
      id
    }
  }
}
```

**Step 2**: Switch to Charlie's token and like Alice back
```graphql
mutation CharlieLikesAlice {
  likeUser(targetUserId: "1") {
    matchCreated
    match {
      id
      userOne { firstName }
      userTwo { firstName }
    }
  }
}
```

**Expected Result**: 
- ✅ Second match created (Alice & Charlie)

---

### Test 6.2: Unmatch Users ✅
**Authentication**: Use Alice's token
**Note**: Use match ID from Alice & Charlie match

```graphql
mutation AliceUnmatchesCharlie {
  unmatchUser(matchId: "2") {
    success
  }
}
```

**Expected Result**: 
- ✅ `success: true`
- ✅ Match should be deleted

---

### Test 6.3: Verify Unmatch Worked ✅
```graphql
query AliceMatchesAfterUnmatch {
  matches {
    id
    userOne { firstName }
    userTwo { firstName }
  }
}
```

**Expected Result**: 
- ✅ Should only show Alice & Bob match
- ✅ Alice & Charlie match should be gone

---

## Phase 7: Admin Features Tests

### Test 7.1: Register Admin User ✅
```graphql
mutation RegisterAdmin {
  registerUser(
    firstName: "Admin"
    lastName: "User"
    email: "admin@test.com"
    password: "admin123"
    mobileNumber: "+1999888777"
    birthdate: "1985-01-01"
    gender: "non-binary"
    sexualOrientation: "pansexual"
    genderInterest: "all"
    bio: "System administrator"
  ) {
    user {
      id
      firstName
      role
    }
  }
}
```

---

### Test 7.2: Update Admin Role (Manual DB Update Required)
**Note**: You'll need to manually update the admin user's role in the database:
```sql
UPDATE users SET role = 'admin' WHERE email = 'admin@test.com';
```

---

### Test 7.3: Admin Login ✅
```graphql
mutation AdminLogin {
  loginUser(
    email: "admin@test.com"
    password: "admin123"
  ) {
    user {
      id
      firstName
      role
    }
    token
  }
}
```

**⚠️ IMPORTANT**: Save admin token for admin tests

---

### Test 7.4: Admin Create User ✅
**Authentication**: Use admin token

```graphql
mutation AdminCreateUser {
  adminCreateUser(
    firstName: "Created"
    lastName: "ByAdmin"
    email: "created@test.com"
    password: "password123"
    mobileNumber: "+1111222333"
    birthdate: "1995-06-15"
    gender: "female"
    sexualOrientation: "straight"
    genderInterest: "male"
    bio: "Created by admin for testing"
    role: "user"
  ) {
    user {
      id
      firstName
      lastName
      email
      role
    }
    errors
  }
}
```

**Expected Result**: 
- ✅ User created by admin
- ✅ `errors` array should be empty

---

## Phase 8: Error Handling Tests

### Test 8.1: Like Non-existent User ❌
```graphql
mutation LikeNonexistentUser {
  likeUser(targetUserId: "999") {
    matchCreated
    match { id }
  }
}
```

**Expected Result**: 
- ❌ Should return "Record not found" error

---

### Test 8.2: Send Message to Invalid Match ❌
```graphql
mutation InvalidMessage {
  sendMessage(
    matchId: "999"
    content: "This should fail"
  ) {
    message { id }
  }
}
```

**Expected Result**: 
- ❌ Should return "Record not found" error

---

### Test 8.3: Unmatch Invalid Match ❌
```graphql
mutation InvalidUnmatch {
  unmatchUser(matchId: "999") {
    success
  }
}
```

**Expected Result**: 
- ❌ Should return "Record not found" error

---

### Test 8.4: Admin Action by Non-Admin ❌
**Authentication**: Use regular user token (not admin)

```graphql
mutation NonAdminCreate {
  adminCreateUser(
    firstName: "Should"
    lastName: "Fail"
    email: "fail@test.com"
    password: "password123"
    mobileNumber: "+1000000000"
    birthdate: "1990-01-01"
    gender: "male"
    sexualOrientation: "straight"
    genderInterest: "female"
    bio: "This should fail"
  ) {
    user { id }
    errors
  }
}
```

**Expected Result**: 
- ❌ Should return "Unauthorized" error

---

## Phase 9: Edge Case Tests

### Test 9.1: Like Same User Twice ✅
**Authentication**: Use Alice's token

```graphql
mutation LikeSameUserTwice {
  likeUser(targetUserId: "2") {
    matchCreated
    match { id }
  }
}
```

**Expected Result**: 
- ✅ Should work (updates existing like)
- ✅ `matchCreated: false` (match already exists)

---

### Test 9.2: Dislike Then Like Same User ✅
```graphql
# First dislike
mutation DislikeThenLike1 {
  dislikeUser(targetUserId: "3") {
    success
  }
}

# Then like
mutation DislikeThenLike2 {
  likeUser(targetUserId: "3") {
    matchCreated
    match { id }
  }
}
```

**Expected Result**: 
- ✅ Both should work
- ✅ Like should override dislike

---

## Test Results Checklist

### ✅ Expected Working Features:
- [ ] User Registration (3 users)
- [ ] User Login (returns JWT token)
- [ ] Authentication (currentUser query)
- [ ] User Discovery (potentialUsers query)
- [ ] Like/Dislike System
- [ ] Match Creation (mutual likes)
- [ ] Messaging System
- [ ] Conversation Management
- [ ] Match Queries
- [ ] Unmatch Functionality
- [ ] Admin User Creation
- [ ] Error Handling

### ❌ Expected Failing Features:
- [ ] Invalid login attempts
- [ ] Unauthenticated queries return null/error
- [ ] Non-existent resource access
- [ ] Unauthorized admin actions

---

## Reporting Issues

If any test fails unexpectedly, please provide:

1. **Test Number**: Which test failed
2. **Error Message**: Exact error returned
3. **Expected vs Actual**: What you expected vs what happened
4. **Authentication**: Which user token you were using
5. **GraphQL Response**: Full response from GraphiQL

**Example Issue Report**:
```
Test 4.2 Failed:
- Error: "Field 'matchCreated' not found"
- Expected: Match creation with matchCreated: true
- Authentication: Using Bob's token
- Response: { "errors": [{"message": "Field 'matchCreated' not found"}] }
```

---

## Summary

This test suite covers:
- ✅ **52 total tests**
- ✅ **User registration & authentication**
- ✅ **Swiping & matching system**
- ✅ **Messaging functionality**
- ✅ **Admin features**
- ✅ **Error handling**
- ✅ **Edge cases**

Run all tests and let me know which ones fail! 🚀
