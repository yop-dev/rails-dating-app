# Vue.js + Apollo Frontend Implementation Guide - Tinder Clone

This guide organizes the frontend implementation into development phases, allowing for an incremental approach to building the Tinder clone frontend with Vue.js 3 and Apollo GraphQL.

## Table of Contents
- [Setup Phase](#setup-phase)
- [Phase 1: Authentication & Profile](#phase-1-authentication--profile)
- [Phase 2: Core Dating Features](#phase-2-core-dating-features)
- [Phase 3: Messaging System](#phase-3-messaging-system)
- [Phase 4: Admin Dashboard](#phase-4-admin-dashboard)
- [Phase 5: Optimization & Deployment](#phase-5-optimization--deployment)

## Setup Phase

### Project Initialization
```bash
npm create vue@latest tinder-clone-frontend
cd tinder-clone-frontend

# Select these options:
# ✅ TypeScript
# ✅ Router
# ✅ Pinia (state management)
# ✅ ESLint
# ✅ Prettier
```

### Required Dependencies
```bash
# GraphQL & Apollo
npm install @apollo/client graphql @vue/apollo-composable graphql-tag

# UI Framework (choose one)
npm install @headlessui/vue @heroicons/vue tailwindcss postcss autoprefixer

# Utilities
npm install axios vue-toastification vueuse date-fns
```

### Apollo Client Setup
Create `src/apollo/client.ts`:
```typescript
import { ApolloClient, InMemoryCache, createHttpLink } from '@apollo/client/core'
import { setContext } from '@apollo/client/link/context'

const httpLink = createHttpLink({
  uri: 'http://localhost:3000/graphql',
})

const authLink = setContext((_, { headers }) => {
  const token = localStorage.getItem('authToken')
  return {
    headers: {
      ...headers,
      authorization: token ? `Bearer ${token}` : '',
    }
  }
})

export const apolloClient = new ApolloClient({
  link: authLink.concat(httpLink),
  cache: new InMemoryCache(),
  defaultOptions: {
    watchQuery: {
      fetchPolicy: 'cache-and-network',
    },
  },
})
```

### Vue-Apollo Setup
Create `src/plugins/apollo.ts`:
```typescript
import { createApolloProvider } from '@vue/apollo-option'
import { apolloClient } from '../apollo/client'

export const apolloProvider = createApolloProvider({
  defaultClient: apolloClient,
})
```

### App Configuration
Update `src/main.ts`:
```typescript
import { createApp } from 'vue'
import { createPinia } from 'pinia'
import App from './App.vue'
import router from './router'
import { apolloProvider } from './plugins/apollo'
import Toast from 'vue-toastification'
import 'vue-toastification/dist/index.css'
import './assets/main.css'

const app = createApp(App)

app.use(createPinia())
app.use(router)
app.use(apolloProvider)
app.use(Toast, {
  transition: "Vue-Toastification__bounce",
  maxToasts: 3,
  newestOnTop: true
})

app.mount('#app')
```

## Phase 1: Authentication & Profile

### 1.1 Authentication Store
Create `src/stores/auth.ts`:
```typescript
import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import { apolloClient } from '@/apollo/client'
import { LOGIN_USER, REGISTER_USER, CURRENT_USER } from '@/graphql/auth'

export const useAuthStore = defineStore('auth', () => {
  const user = ref(null)
  const token = ref(localStorage.getItem('authToken'))
  const loading = ref(false)
  const error = ref(null)

  const isAuthenticated = computed(() => !!token.value)
  const isAdmin = computed(() => user.value?.role === 'admin' || user.value?.role === 'superadmin')

  const login = async (email, password) => {
    loading.value = true
    error.value = null
    
    try {
      const { data } = await apolloClient.mutate({
        mutation: LOGIN_USER,
        variables: { email, password }
      })

      if (data.loginUser.token) {
        token.value = data.loginUser.token
        user.value = data.loginUser.user
        localStorage.setItem('authToken', data.loginUser.token)
        return { success: true }
      }
    } catch (err) {
      error.value = err.message
      return { success: false, error: err.message }
    } finally {
      loading.value = false
    }
  }

  const register = async (userData) => {
    loading.value = true
    error.value = null
    
    try {
      const { data } = await apolloClient.mutate({
        mutation: REGISTER_USER,
        variables: userData
      })

      if (data.registerUser.user) {
        // Auto-login after registration
        return await login(userData.email, userData.password)
      }
    } catch (err) {
      error.value = err.message
      return { success: false, error: err.message }
    } finally {
      loading.value = false
    }
  }

  const logout = () => {
    token.value = null
    user.value = null
    localStorage.removeItem('authToken')
    apolloClient.resetStore()
  }

  const getCurrentUser = async () => {
    if (!token.value) return

    try {
      const { data } = await apolloClient.query({
        query: CURRENT_USER
      })
      user.value = data.currentUser
    } catch (err) {
      console.error('Failed to get current user:', err)
      logout()
    }
  }

  return {
    user,
    token,
    loading,
    error,
    isAuthenticated,
    isAdmin,
    login,
    register,
    logout,
    getCurrentUser
  }
})
```

### 1.2 Authentication GraphQL Queries
Create `src/graphql/auth.ts`:
```typescript
import { gql } from '@apollo/client/core'

export const LOGIN_USER = gql`
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
`

export const REGISTER_USER = gql`
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
    $location: String!
    $school: String
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
      location: $location
      school: $school
    ) {
      user {
        id
        firstName
        lastName
        email
        location
        school
      }
    }
  }
`


export const CURRENT_USER = gql`
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
`
```

### 1.3 Login Page
Create `src/views/LoginView.vue`:
```vue
<template>
  <div class="min-h-screen bg-gradient-to-br from-pink-500 to-orange-400 flex items-center justify-center p-4">
    <div class="bg-white rounded-2xl shadow-2xl w-full max-w-md p-8">
      <div class="text-center mb-8">
        <h1 class="text-3xl font-bold text-gray-900 mb-2">Welcome Back</h1>
        <p class="text-gray-600">Sign in to your account</p>
      </div>

      <form @submit.prevent="handleSubmit" class="space-y-4">
        <div>
          <label class="block text-sm font-medium text-gray-700 mb-1">Email</label>
          <input
            v-model="form.email"
            type="email"
            required
            class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-pink-500 focus:border-transparent"
          />
        </div>

        <div>
          <label class="block text-sm font-medium text-gray-700 mb-1">Password</label>
          <input
            v-model="form.password"
            type="password"
            required
            class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-pink-500 focus:border-transparent"
          />
        </div>

        <div v-if="authStore.error" class="py-2 px-3 bg-red-50 text-red-600 text-sm rounded-lg">
          {{ authStore.error }}
        </div>

        <button
          type="submit"
          :disabled="authStore.loading"
          class="w-full bg-pink-500 text-white py-3 rounded-lg font-semibold hover:bg-pink-600 disabled:opacity-50 disabled:cursor-not-allowed transition-colors"
        >
          {{ authStore.loading ? 'Signing In...' : 'Sign In' }}
        </button>
      </form>

      <div class="text-center mt-6">
        <p class="text-gray-600">
          Don't have an account?
          <router-link to="/register" class="text-pink-500 hover:text-pink-600 font-medium">
            Create Account
          </router-link>
        </p>
      </div>
    </div>
  </div>
</template>

<script setup>
import { reactive } from 'vue'
import { useRouter } from 'vue-router'
import { useAuthStore } from '@/stores/auth'
import { useToast } from 'vue-toastification'

const router = useRouter()
const authStore = useAuthStore()
const toast = useToast()

const form = reactive({
  email: '',
  password: ''
})

const handleSubmit = async () => {
  const result = await authStore.login(form.email, form.password)
  
  if (result.success) {
    toast.success('Successfully signed in!')
    router.push('/swipe') // Redirect to main page
  }
}
</script>
```

### 1.4 Registration Page
Create `src/views/RegisterView.vue` (summarized - see full implementation in the repository)

### 1.5 Profile Page
Create `src/views/ProfileView.vue` (summarized - see full implementation in the repository)

### 1.6 Profile Management (GraphQL)
Create `src/graphql/profile.ts`:
```typescript
import { gql } from '@apollo/client/core'

export const UPDATE_PROFILE = gql`
  mutation UpdateProfile(
    $firstName: String
    $lastName: String
    $bio: String
    $school: String
    $genderInterest: String
  ) {
    updateProfile(
      firstName: $firstName
      lastName: $lastName
      bio: $bio
      school: $school
      genderInterest: $genderInterest
    ) {
      id
      firstName
      lastName
      bio
      school
      genderInterest
    }
  }
`

export const UPLOAD_PHOTO = gql`
  mutation UploadPhoto($url: String!) {
    uploadPhoto(url: $url) {
      id
      url
      position
      isPrimary
    }
  }
`

export const DELETE_PHOTO = gql`
  mutation DeletePhoto($photoId: ID!) {
    deletePhoto(photoId: $photoId) {
      success
    }
  }
`

export const SET_PRIMARY_PHOTO = gql`
  mutation SetPrimaryPhoto($photoId: ID!) {
    setPrimaryPhoto(photoId: $photoId) {
      success
    }
  }
`
```

## Phase 2: Core Dating Features

### 2.1 Swipe Feature (GraphQL)
Create `src/graphql/swipe.ts`:
```typescript
import { gql } from '@apollo/client/core'

export const POTENTIAL_USERS = gql`
  query PotentialUsers($limit: Int) {
    potentialUsers(limit: $limit) {
      id
      firstName
      lastName
      age
      bio
      city
      state
      country
      primaryPhotoUrl
      photos {
        id
        url
        isPrimary
      }
    }
  }
`

export const LIKE_USER = gql`
  mutation LikeUser($targetUserId: ID!) {
    likeUser(targetUserId: $targetUserId) {
      matchCreated
      match {
        id
        userOne {
          id
          firstName
          lastName
          primaryPhotoUrl
        }
        userTwo {
          id
          firstName
          lastName
          primaryPhotoUrl
        }
        createdAt
      }
    }
  }
`

export const DISLIKE_USER = gql`
  mutation DislikeUser($targetUserId: ID!) {
    dislikeUser(targetUserId: $targetUserId) {
      success
    }
  }
`
```

### 2.2 Swipe Page
Create `src/views/SwipeView.vue` with card swiping functionality (summarized - see full implementation in the repository)

### 2.3 Matches Feature (GraphQL)
Create `src/graphql/matches.ts`:
```typescript
import { gql } from '@apollo/client/core'

export const MATCHES = gql`
  query Matches($limit: Int, $offset: Int) {
    matches(limit: $limit, offset: $offset) {
      id
      userOne {
        id
        firstName
        lastName
        primaryPhotoUrl
      }
      userTwo {
        id
        firstName
        lastName
        primaryPhotoUrl
      }
      createdAt
      lastMessageAt
    }
  }
`

export const UNMATCH_USER = gql`
  mutation UnmatchUser($matchId: ID!) {
    unmatchUser(matchId: $matchId) {
      success
    }
  }
`
```

### 2.4 Matches Page
Create `src/views/MatchesView.vue` with match cards and actions (summarized - see full implementation in the repository)

### 2.5 Match Modal Component
Create `src/components/MatchModal.vue`:
```vue
<template>
  <div class="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/70">
    <div class="bg-white rounded-2xl overflow-hidden w-full max-w-md shadow-2xl transform transition-all">
      <!-- Match Header -->
      <div class="bg-gradient-to-r from-pink-500 to-purple-600 p-6 text-center">
        <h2 class="text-3xl font-bold text-white mb-2">It's a Match!</h2>
        <p class="text-white/90">You and {{ matchedUser.firstName }} liked each other</p>
      </div>

      <!-- Match Content -->
      <div class="p-6 text-center">
        <div class="flex items-center justify-center space-x-4 mb-8">
          <!-- Current User Photo -->
          <div class="w-24 h-24 bg-gray-200 rounded-full overflow-hidden border-4 border-white shadow-lg">
            <img 
              :src="currentUser.primaryPhotoUrl || '/placeholder-avatar.png'"
              :alt="currentUser.firstName"
              class="w-full h-full object-cover"
            />
          </div>

          <!-- Heart Icon -->
          <div class="text-pink-500 text-2xl">❤️</div>

          <!-- Matched User Photo -->
          <div class="w-24 h-24 bg-gray-200 rounded-full overflow-hidden border-4 border-white shadow-lg">
            <img 
              :src="matchedUser.primaryPhotoUrl || '/placeholder-avatar.png'"
              :alt="matchedUser.firstName"
              class="w-full h-full object-cover"
            />
          </div>
        </div>

        <!-- Action Buttons -->
        <div class="space-y-3">
          <button
            @click="$emit('send-message')"
            class="w-full bg-pink-500 text-white py-3 rounded-full font-semibold hover:bg-pink-600 transition-colors"
          >
            Send a Message
          </button>
          <button
            @click="$emit('close')"
            class="w-full bg-gray-100 text-gray-700 py-3 rounded-full font-semibold hover:bg-gray-200 transition-colors"
          >
            Keep Swiping
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { useAuthStore } from '@/stores/auth'

const props = defineProps({
  matchedUser: {
    type: Object,
    required: true
  }
})

const authStore = useAuthStore()
const currentUser = authStore.user

defineEmits(['close', 'send-message'])
</script>
```

## Phase 3: Messaging System

### 3.1 Messaging (GraphQL)
Create `src/graphql/messages.ts`:
```typescript
import { gql } from '@apollo/client/core'

export const CONVERSATIONS = gql`
  query Conversations {
    conversations {
      id
      matchId
      userA {
        id
        firstName
        lastName
        primaryPhotoUrl
      }
      userB {
        id
        firstName
        lastName
        primaryPhotoUrl
      }
      lastMessage {
        id
        content
        createdAt
        read
        sender {
          id
        }
      }
      updatedAt
    }
  }
`

export const MESSAGES = gql`
  query Messages($conversationId: ID!) {
    messages(conversationId: $conversationId) {
      id
      content
      createdAt
      read
      sender {
        id
        firstName
        lastName
      }
    }
  }
`

export const SEND_MESSAGE = gql`
  mutation SendMessage($matchId: ID!, $content: String!) {
    sendMessage(matchId: $matchId, content: $content) {
      id
      content
      createdAt
      sender {
        id
        firstName
      }
    }
  }
`

// Optional real-time subscription
export const NEW_MESSAGE_SUBSCRIPTION = gql`
  subscription OnNewMessage($matchId: ID!) {
    newMessage(matchId: $matchId) {
      id
      content
      createdAt
      read
      sender {
        id
        firstName
        lastName
      }
    }
  }
`
```

### 3.2 Messages Page
Create `src/views/MessagesView.vue` with conversation list and chat interface (summarized - see full implementation in the repository)

## Phase 4: Admin Dashboard

### 4.1 Admin Features (GraphQL)
Create `src/graphql/admin.ts`:
```typescript
import { gql } from '@apollo/client/core'

export const ADMIN_DASHBOARD = gql`
  query AdminDashboard {
    adminDashboard {
      totalUsers
      totalMatches
      totalMessages
      usersThisWeek
      matchesThisWeek
      messagesThisWeek
      averageMatchesPerUser
    }
  }
`

export const ALL_USERS_WITH_STATS = gql`
  query AllUsersWithStats($limit: Int, $offset: Int, $orderBy: String, $orderDirection: String) {
    allUsersWithStats(limit: $limit, offset: $offset, orderBy: $orderBy, orderDirection: $orderDirection) {
      id
      firstName
      lastName
      email
      age
      gender
      createdAt
      primaryPhotoUrl
      matchCount
    }
  }
`

export const ADMIN_CREATE_USER = gql`
  mutation AdminCreateUser(
    $firstName: String!
    $lastName: String!
    $email: String!
    $password: String!
    $birthdate: ISO8601Date!
    $gender: String!
    $role: String
  ) {
    adminCreateUser(
      firstName: $firstName
      lastName: $lastName
      email: $email
      password: $password
      birthdate: $birthdate
      gender: $gender
      role: $role
    ) {
      id
      firstName
      lastName
      email
    }
  }
`

export const ADMIN_UPDATE_USER = gql`
  mutation AdminUpdateUser(
    $id: ID!
    $firstName: String
    $lastName: String
    $email: String
    $role: String
  ) {
    adminUpdateUser(
      id: $id
      firstName: $firstName
      lastName: $lastName
      email: $email
      role: $role
    ) {
      id
      firstName
      lastName
      email
      role
    }
  }
`

export const ADMIN_DELETE_USER = gql`
  mutation AdminDeleteUser($id: ID!) {
    adminDeleteUser(id: $id) {
      success
    }
  }
`

export const ADMIN_DELETE_MATCH = gql`
  mutation AdminDeleteMatch($id: ID!) {
    adminDeleteMatch(id: $id) {
      success
    }
  }
`
```

### 4.2 Admin Dashboard Page
Create `src/views/admin/AdminDashboardView.vue` with statistics and quick actions (summarized - see full implementation in the repository)

### 4.3 Admin Users Page
Create `src/views/admin/AdminUsersView.vue` with user management (summarized - see full implementation in the repository)

### 4.4 Admin Layout Component
Create `src/components/AdminLayout.vue`:
```vue
<template>
  <div class="min-h-screen flex">
    <!-- Sidebar -->
    <div class="w-64 bg-gray-900 text-white fixed h-full overflow-y-auto">
      <div class="p-4 border-b border-gray-800">
        <h1 class="text-xl font-bold">Tinder Clone Admin</h1>
      </div>
      <nav class="p-4 space-y-2">
        <router-link
          to="/admin"
          class="block px-4 py-2 rounded hover:bg-pink-600 transition-colors"
          :class="{ 'bg-pink-700': $route.path === '/admin' }"
        >
          Dashboard
        </router-link>
        <router-link
          to="/admin/users"
          class="block px-4 py-2 rounded hover:bg-pink-600 transition-colors"
          :class="{ 'bg-pink-700': $route.path.includes('/admin/users') }"
        >
          Users
        </router-link>
        <router-link
          to="/admin/matches"
          class="block px-4 py-2 rounded hover:bg-pink-600 transition-colors"
          :class="{ 'bg-pink-700': $route.path.includes('/admin/matches') }"
        >
          Matches
        </router-link>
      </nav>
      <div class="absolute bottom-0 w-full p-4 border-t border-gray-800">
        <button 
          @click="logout"
          class="w-full flex items-center px-4 py-2 text-gray-400 hover:text-white transition-colors"
        >
          <span>Sign Out</span>
        </button>
      </div>
    </div>

    <!-- Main Content -->
    <div class="ml-64 flex-1 p-8 overflow-y-auto">
      <slot></slot>
    </div>
  </div>
</template>

<script setup>
import { useRouter } from 'vue-router'
import { useAuthStore } from '@/stores/auth'

const router = useRouter()
const authStore = useAuthStore()

const logout = () => {
  authStore.logout()
  router.push('/login')
}
</script>
```

## Phase 5: Optimization & Deployment

### 5.1 Route Configuration
Update `src/router/index.ts` with route guards:
```typescript
import { createRouter, createWebHistory } from 'vue-router'
import { useAuthStore } from '@/stores/auth'

const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes: [
    {
      path: '/',
      redirect: '/swipe'
    },
    {
      path: '/login',
      name: 'login',
      component: () => import('@/views/LoginView.vue'),
      meta: { requiresGuest: true }
    },
    {
      path: '/register',
      name: 'register',
      component: () => import('@/views/RegisterView.vue'),
      meta: { requiresGuest: true }
    },
    {
      path: '/swipe',
      name: 'swipe',
      component: () => import('@/views/SwipeView.vue'),
      meta: { requiresAuth: true }
    },
    {
      path: '/matches',
      name: 'matches',
      component: () => import('@/views/MatchesView.vue'),
      meta: { requiresAuth: true }
    },
    {
      path: '/messages',
      name: 'messages',
      component: () => import('@/views/MessagesView.vue'),
      meta: { requiresAuth: true }
    },
    {
      path: '/messages/:userId',
      name: 'conversation',
      component: () => import('@/views/MessagesView.vue'),
      meta: { requiresAuth: true }
    },
    {
      path: '/profile',
      name: 'profile',
      component: () => import('@/views/ProfileView.vue'),
      meta: { requiresAuth: true }
    },
    {
      path: '/admin',
      name: 'admin',
      component: () => import('@/views/admin/AdminDashboardView.vue'),
      meta: { requiresAuth: true, requiresAdmin: true }
    },
    {
      path: '/admin/users',
      name: 'admin-users',
      component: () => import('@/views/admin/AdminUsersView.vue'),
      meta: { requiresAuth: true, requiresAdmin: true }
    },
    {
      path: '/admin/matches',
      name: 'admin-matches',
      component: () => import('@/views/admin/AdminMatchesView.vue'),
      meta: { requiresAuth: true, requiresAdmin: true }
    },
    {
      path: '/:pathMatch(.*)*',
      name: 'not-found',
      component: () => import('@/views/NotFoundView.vue')
    }
  ]
})

router.beforeEach(async (to, from, next) => {
  const authStore = useAuthStore()
  
  // Load current user if authenticated but no user data
  if (authStore.isAuthenticated && !authStore.user) {
    await authStore.getCurrentUser()
  }

  // Redirect for auth/guest routes
  if (to.meta.requiresAuth && !authStore.isAuthenticated) {
    return next('/login')
  }

  if (to.meta.requiresGuest && authStore.isAuthenticated) {
    return next('/swipe')
  }

  // Redirect for admin-only routes
  if (to.meta.requiresAdmin && !authStore.isAdmin) {
    return next('/swipe')
  }

  next()
})

export default router
```

### 5.2 Error Boundary Component
Create `src/components/ErrorBoundary.vue`:
```vue
<template>
  <div>
    <div v-if="error" class="error-boundary">
      <div class="error-content">
        <h2>Something went wrong</h2>
        <p>{{ error.message }}</p>
        <button @click="resetError">Try again</button>
      </div>
    </div>
    <slot v-else></slot>
  </div>
</template>

<script setup>
import { ref, onErrorCaptured } from 'vue'

const error = ref(null)

onErrorCaptured((err) => {
  error.value = err
  return true
})

function resetError() {
  error.value = null
}
</script>

<style scoped>
.error-boundary {
  display: flex;
  justify-content: center;
  align-items: center;
  min-height: 200px;
  padding: 1rem;
  text-align: center;
  background-color: #fff3f3;
  border-radius: 0.5rem;
  color: #e53e3e;
}

.error-content {
  max-width: 400px;
}

button {
  margin-top: 1rem;
  padding: 0.5rem 1rem;
  background-color: #e53e3e;
  color: white;
  border: none;
  border-radius: 0.25rem;
  cursor: pointer;
}

button:hover {
  background-color: #c53030;
}
</style>
```

### 5.3 Performance Optimizations

#### Lazy Loading Components
Use dynamic imports for components when appropriate:
```typescript
// Example in router
component: () => import('@/views/SwipeView.vue')

// Example in a component
const MatchModal = defineAsyncComponent(() =>
  import('@/components/MatchModal.vue')
)
```

#### GraphQL Fragment Reuse
Create `src/graphql/fragments.ts`:
```typescript
import { gql } from '@apollo/client/core'

export const USER_FRAGMENT = gql`
  fragment UserFields on User {
    id
    firstName
    lastName
    age
    email
    primaryPhotoUrl
  }
`

export const PHOTO_FRAGMENT = gql`
  fragment PhotoFields on Photo {
    id
    url
    position
    isPrimary
  }
`

// Then import and use in queries:
// import { USER_FRAGMENT } from './fragments'
// export const MATCHES = gql`
//   query Matches {
//     matches {
//       id
//       userOne {
//         ...UserFields
//       }
//     }
//   }
//   ${USER_FRAGMENT}
// `
```

#### Apollo Cache Policies
Update cache policies for frequently changing data:
```typescript
cache: new InMemoryCache({
  typePolicies: {
    Query: {
      fields: {
        messages: {
          // Don't cache messages query
          keyArgs: false,
          merge(existing = [], incoming) {
            return [...existing, ...incoming];
          }
        },
        potentialUsers: {
          // Always fetch fresh potential users
          keyArgs: false,
        }
      }
    }
  }
})
```

### 5.4 Production Deployment

#### Environment Variables
Create `.env.production`:
```
VUE_APP_API_URL=https://production-api.example.com/graphql
VUE_APP_UPLOAD_URL=https://production-api.example.com/upload
```

#### Build Command
```bash
npm run build
```

#### Deployment Options
- Static hosting (Netlify, Vercel, AWS S3)
- Server-side rendering (SSR) with Node.js
- Docker containerization

## Summary

This phased approach to implementing a Vue.js + Apollo frontend for the Tinder clone allows for incremental development and testing. Each phase builds upon the previous one, adding new features while maintaining a cohesive codebase.

Key technical features implemented include:
- Authentication with JWT
- Real-time messaging capability
- Touch-optimized swipe interactions
- Responsive design for all devices
- Admin dashboard with analytics
- Profile management with photo uploads
- Error handling and performance optimizations

This implementation follows Vue.js best practices including composition API, Pinia for state management, and modular GraphQL queries. The application is production-ready with lazy loading, code splitting, and security features built in.
