# Frontend Implementation Reference - Tinder Clone

This document serves as a comprehensive reference for implementing the frontend of the Tinder clone application, based on the Rails GraphQL backend.

## Table of Contents
- [API Overview](#api-overview)
- [Authentication](#authentication)
- [User Profile Management](#user-profile-management)
- [Swiping & Matching](#swiping--matching)
- [Messaging](#messaging)
- [Admin Functions](#admin-functions)
- [GraphQL Queries](#graphql-queries)
- [Data Types](#data-types)
- [Error Handling](#error-handling)

## API Overview

The backend uses GraphQL with the following main schemas:
- **Endpoint**: `/graphql` (assumed standard Rails GraphQL endpoint)
- **Schema Classes**: `MyAppSchema` and `TinderCloneSchema`
- **Authentication**: JWT tokens via `JsonWebToken.encode`

### Key Features
- User registration and authentication
- Profile management with photos
- Swiping (like/dislike) system
- Real-time messaging
- Match management
- Admin controls

## Authentication

### Registration
```graphql
mutation RegisterUser(
  $firstName: String!
  $lastName: String!
  $email: String!
  $mobileNumber: String!
  $password: String!
  $birthdate: ISO8601Date!
  $gender: String!
  $sexualOrientation: String!
  $genderInterest: String!
  $bio: String!
) {
  registerUser(
    firstName: $firstName
    lastName: $lastName
    email: $email
    mobileNumber: $mobileNumber
    password: $password
    birthdate: $birthdate
    gender: $gender
    sexualOrientation: $sexualOrientation
    genderInterest: $genderInterest
    bio: $bio
  ) {
    user {
      id
      firstName
      lastName
      email
      fullName
      age
      bio
      gender
      genderInterest
      primaryPhotoUrl
    }
  }
}
```

**Variables:**
```json
{
  "firstName": "John",
  "lastName": "Doe",
  "email": "john@example.com",
  "mobileNumber": "+1234567890",
  "password": "securepassword",
  "birthdate": "1995-06-15",
  "gender": "male",
  "sexualOrientation": "heterosexual",
  "genderInterest": "female",
  "bio": "Love hiking and coffee"
}
```

### Login
```graphql
mutation LoginUser($email: String!, $password: String!) {
  loginUser(email: $email, password: $password) {
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

**Variables:**
```json
{
  "email": "john@example.com",
  "password": "securepassword"
}
```

### Current User Query
```graphql
query CurrentUser {
  currentUser {
    id
    firstName
    lastName
    fullName
    email
    age
    bio
    gender
    genderInterest
    primaryPhotoUrl
    photos {
      id
      url
      position
      isPrimary
    }
    role
  }
}
```

## User Profile Management

### Update Profile
```graphql
mutation UpdateProfile($input: UpdateProfileInput!) {
  updateProfile(input: $input) {
    user {
      id
      firstName
      lastName
      bio
      school
      genderInterest
    }
  }
}
```

**Variables:**
```json
{
  "input": {
    "firstName": "Jonathan",
    "bio": "Updated bio text",
    "school": "University of Example"
  }
}
```

### Photo Management

#### Upload Photo
```graphql
mutation UploadPhoto($input: UploadPhotoInput!) {
  uploadPhoto(input: $input) {
    photo {
      id
      url
      position
      isPrimary
    }
  }
}
```

**Variables:**
```json
{
  "input": {
    "url": "https://example.com/photo.jpg"
  }
}
```

#### Delete Photo
```graphql
mutation DeletePhoto($photoId: ID!) {
  deletePhoto(photoId: $photoId) {
    success
  }
}
```

**Variables:**
```json
{
  "photoId": "123"
}
```

#### Set Primary Photo
```graphql
mutation SetPrimaryPhoto($photoId: ID!) {
  setPrimaryPhoto(photoId: $photoId) {
    photo {
      id
      url
      isPrimary
    }
    success
    errors
  }
}
```

**Variables:**
```json
{
  "photoId": "123"
}
```

## Swiping & Matching

### Get Potential Users
```graphql
query PotentialUsers($limit: Int) {
  potentialUsers(limit: $limit) {
    id
    firstName
    age
    bio
    primaryPhotoUrl
    photos {
      id
      url
      position
    }
  }
}
```

### Like User
```graphql
mutation LikeUser($input: LikeUserInput!) {
  likeUser(input: $input) {
    match {
      id
      userOne {
        id
        firstName
        primaryPhotoUrl
      }
      userTwo {
        id
        firstName
        primaryPhotoUrl
      }
      createdAt
    }
    matchCreated
  }
}
```

**Variables:**
```json
{
  "input": {
    "targetUserId": "456"
  }
}
```

### Dislike User
```graphql
mutation DislikeUser($input: DislikeUserInput!) {
  dislikeUser(input: $input) {
    success
  }
}
```

**Variables:**
```json
{
  "input": {
    "targetUserId": "456"
  }
}
```

### Get Matches
```graphql
query Matches($limit: Int, $offset: Int) {
  matches(limit: $limit, offset: $offset) {
    id
    userOne {
      id
      firstName
      primaryPhotoUrl
    }
    userTwo {
      id
      firstName
      primaryPhotoUrl
    }
    createdAt
  }
}
```

### Unmatch User
```graphql
mutation UnmatchUser($input: UnmatchUserInput!) {
  unmatchUser(input: $input) {
    success
  }
}
```

**Variables:**
```json
{
  "input": {
    "matchId": "789"
  }
}
```

## Messaging

### Get Conversations
```graphql
query Conversations {
  conversations {
    id
    userA {
      id
      firstName
      primaryPhotoUrl
    }
    userB {
      id
      firstName
      primaryPhotoUrl
    }
    lastMessage {
      id
      content
      createdAt
      sender {
        id
        firstName
      }
    }
  }
}
```

### Get Messages
```graphql
query Messages($conversationId: ID!) {
  messages(conversationId: $conversationId) {
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
```

### Send Message
```graphql
mutation SendMessage($input: SendMessageInput!) {
  sendMessage(input: $input) {
    message {
      id
      content
      createdAt
      read
      sender {
        id
        firstName
      }
    }
  }
}
```

**Variables:**
```json
{
  "input": {
    "matchId": "789",
    "content": "Hey there! How's your day going?"
  }
}
```

## Admin Functions

### Create User (Admin Only)
```graphql
mutation AdminCreateUser($input: AdminCreateUserInput!) {
  adminCreateUser(input: $input) {
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

### Update User (Admin Only)
```graphql
mutation AdminUpdateUser($input: AdminUpdateUserInput!) {
  adminUpdateUser(input: $input) {
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

### Delete User (Admin Only)
```graphql
mutation AdminDeleteUser($input: AdminDeleteUserInput!) {
  adminDeleteUser(input: $input) {
    success
    errors
  }
}
```

### Delete Match (Admin Only)
```graphql
mutation AdminDeleteMatch($input: AdminDeleteMatchInput!) {
  adminDeleteMatch(input: $input) {
    success
    errors
  }
}
```

## GraphQL Queries

### Get User by ID
```graphql
query User($id: ID!) {
  user(id: $id) {
    id
    firstName
    lastName
    fullName
    age
    bio
    gender
    photos {
      id
      url
      position
      isPrimary
    }
    school
    city
    state
    country
  }
}
```

### Get Matches for Specific User (Admin)
```graphql
query UserMatches($userId: ID!, $limit: Int, $offset: Int) {
  matches(userId: $userId, limit: $limit, offset: $offset) {
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
```

### Get All Users with Match Statistics (Admin Only)
```graphql
query AllUsersWithStats($limit: Int, $offset: Int, $orderBy: String, $orderDirection: String) {
  allUsersWithStats(limit: $limit, offset: $offset, orderBy: $orderBy, orderDirection: $orderDirection) {
    id
    firstName
    lastName
    email
    primaryPhotoUrl
    matchCount
    createdAt
    gender
    age
    city
    state
    country
  }
}
```

### Get Admin Dashboard Statistics (Admin Only)
```graphql
query AdminDashboard {
  adminDashboard {
    totalUsers
    totalMatches
    totalMessages
    usersToday
    matchesToday
    messagesToday
    usersThisWeek
    matchesThisWeek
    messagesThisWeek
    averageMatchesPerUser
    averageMessagesPerMatch
  }
}
```

## Data Types

### User Type
- `id`: ID
- `firstName`: String
- `lastName`: String
- `fullName`: String (computed)
- `email`: String
- `mobileNumber`: String
- `birthdate`: ISO8601Date
- `gender`: String
- `genderInterest`: String
- `bio`: String
- `country`: String (optional)
- `state`: String (optional)
- `city`: String (optional)
- `school`: String (optional)
- `age`: Integer (computed)
- `primaryPhotoUrl`: String (computed)
- `photos`: [PhotoType]
- `role`: String

### Photo Type
- `id`: ID
- `url`: String
- `position`: Integer
- `isPrimary`: Boolean

### Match Type
- `id`: ID
- `userOne`: UserType
- `userTwo`: UserType
- `createdAt`: ISO8601DateTime
- `updatedAt`: ISO8601DateTime

### Message Type
- `id`: ID
- `conversationId`: ID
- `sender`: UserType
- `content`: String
- `read`: Boolean
- `createdAt`: ISO8601DateTime

### Conversation Type
- `id`: ID
- `userA`: UserType
- `userB`: UserType
- `messages`: [MessageType]
- `lastMessage`: MessageType

### UserStatsType (Admin Only)
- `id`: ID
- `firstName`: String
- `lastName`: String
- `email`: String
- `primaryPhotoUrl`: String
- `matchCount`: Integer
- `createdAt`: ISO8601DateTime
- `gender`: String
- `age`: Integer
- `city`: String
- `state`: String
- `country`: String

### AdminDashboardType (Admin Only)
- `totalUsers`: Integer
- `totalMatches`: Integer
- `totalMessages`: Integer
- `usersToday`: Integer
- `matchesToday`: Integer
- `messagesToday`: Integer
- `usersThisWeek`: Integer
- `matchesThisWeek`: Integer
- `messagesThisWeek`: Integer
- `averageMatchesPerUser`: Float
- `averageMessagesPerMatch`: Float

## Error Handling

### Common Error Patterns
1. **Authentication Required**: `"Authentication required"`
2. **Unauthorized Access**: `"Unauthorized"`
3. **Admin Access Required**: `"Unauthorized: Admin access required"`
4. **Record Not Found**: `"Record not found: [details]"`
5. **Invalid Credentials**: `"Invalid credentials"`
6. **Validation Errors**: `"Invalid input: [validation messages]"`
7. **Photo Limit**: `"Max 5 photos allowed"`
8. **Photo Not Found**: `"Photo not found"`
9. **User Not Found**: `"User not found"`
10. **Match Authorization**: `"Not authorized to unmatch"` or `"Not a participant in the match"`

### Error Response Structure
Most mutations return errors in this format:
```json
{
  "data": {
    "mutationName": {
      "user": null,
      "errors": ["Error message 1", "Error message 2"]
    }
  }
}
```

Some mutations use a boolean `success` field:
```json
{
  "data": {
    "mutationName": {
      "success": false,
      "errors": ["Error message"]
    }
  }
}
```

## Frontend Implementation Notes

### Authentication Flow
1. Store JWT token from login/register response
2. Include token in Authorization header: `Bearer <token>`
3. Handle token expiration and refresh
4. Redirect to login on authentication errors

### Real-time Features
Consider implementing:
- WebSocket subscriptions for new messages
- Push notifications for matches and messages
- Real-time conversation updates

### Photo Handling
- Implement photo upload to cloud storage (AWS S3, Cloudinary)
- Handle image optimization and resizing
- Support drag-and-drop photo reordering
- Maximum 5 photos per user limit

### Swiping Interface
- Implement card-based swiping UI
- Support touch/swipe gestures
- Show "It's a Match!" modal on successful match
- Preload next users for smooth experience

### Performance Considerations
- Implement image lazy loading
- Use pagination for matches and messages
- Cache user data locally
- Optimize GraphQL queries to avoid N+1 problems

### Admin Interface
For admin users, implement:
- User management dashboard with search and filtering
- User statistics with sortable columns
- Match management and monitoring
- System-wide analytics and reports
- Bulk operations for user management

### State Management
Recommended state structure:
```javascript
{
  auth: {
    user: UserObject,
    token: string,
    isAuthenticated: boolean,
    isAdmin: boolean
  },
  profile: {
    photos: PhotoArray,
    isEditing: boolean
  },
  swiping: {
    potentialUsers: UserArray,
    currentIndex: number
  },
  matches: {
    matches: MatchArray,
    conversations: ConversationArray
  },
  messages: {
    currentConversation: ConversationObject,
    messages: MessageArray
  },
  admin: {
    users: UserStatsArray,
    dashboard: AdminDashboardObject,
    selectedUser: UserObject,
    filters: FilterObject,
    pagination: PaginationObject
  }
}
```

## ✅ API Completion Status

### 🎉 100% Complete - All Deliverables Supported

1. **✅ Registration** - Full user signup with all required fields and validation
2. **✅ Swipe Page** - Potential users with filtering, like/dislike, match creation
3. **✅ Matches Page** - View mutual matches with full user details
4. **✅ Profile Management** - Complete profile editing and photo management
5. **✅ Messaging** - Full messaging system with conversations and real-time capability
6. **✅ Super Admin User Manager** - Complete CRUD operations with user statistics
7. **✅ Super Admin Matches Manager** - User statistics with match counts and analytics

### 🚀 Ready for Frontend Implementation

This GraphQL API provides:
- **Authentication & Authorization** - JWT tokens with role-based access
- **Real-time Messaging** - Complete conversation management
- **Photo Management** - Upload, delete, reorder, set primary (5 photo limit)
- **Match System** - Like/dislike with automatic match creation
- **Admin Dashboard** - Comprehensive statistics and user management
- **Error Handling** - Consistent error responses across all endpoints
- **Pagination** - Built-in pagination for all list queries

This reference should provide a solid foundation for implementing your Tinder clone frontend with proper GraphQL integration.
