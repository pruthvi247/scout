## 🎯 Coding Agent Prompt: Flutter App for Political Management System

### Context

You are a senior Flutter engineer working on a **Political Management System (PMS)** mobile application.

I already have:

- A **sample Flutter project scaffold** created (routing, basic theming, pubspec ready)
- A **fully functional backend API** built using FastAPI
- Complete **API documentation**, **project plan**, and **technical plan**

Your task is to **study the provided documents**, understand the domain and APIs, and **build the Flutter UI and client-side architecture accordingly**.

---

### Documents Provided (Read Carefully)

1. **API Documentation**
   → Contains all REST endpoints, request/response formats, authentication, roles, and permissions.

2. **Project Plan**
   → Describes business features, user workflows, roles (Admin, Incharge, Activist, Volunteer), and functional expectations.

3. **Technical Plan**
   → Defines domain models, entity structure, permissions, and backend architecture.

Treat these as **source of truth**.

---

### Application Goal

Build a **role-aware Flutter mobile app** where party members can:

- Log in
- View organization hierarchy
- Create and track activities
- View dashboards and statistics
- Receive notifications
- Manage volunteers, events, and feedback (based on role)

---

### Core Functional Requirements

#### 1. Authentication & Session

- Login using `/api/auth/login`
- Securely store JWT token
- Auto-attach token to all API calls
- Fetch current user via `/api/auth/me`
- Persist session across app restarts
- Logout support

#### 2. Role-Based Navigation

After login, route users based on role:

- **Admin**
- **Incharge**
- **Activist**
- **Volunteer**

Navigation, screens, and actions must respect RBAC rules defined in API docs.

---

### Required Screens (Initial Scope)

#### Common

- Login Screen
- Profile Screen (view/edit own profile)
- Notifications List
- Organization Tree Viewer (read-only for non-admins)

#### Activist

- Create Activity
- My Activities List
- Activity Details (status: pending/verified/rejected)

#### Admin / Incharge

- Dashboard (stats, engagement, pending activities)
- Activity Verification
- Organization Tree Management (view/edit)
- Member List & Profiles

#### Volunteer

- Assigned Tasks
- Event Attendance
- Performance View

---

### UI & UX Expectations

- Clean, professional, political/enterprise style UI
- Use Material 3
- Responsive for mobile screens
- Clear empty states and loading states
- Graceful error handling for API failures

---

### Flutter Architecture Requirements

Follow **clean architecture** principles:

```
lib/
 ├── core/
 │   ├── network/        # API client, interceptors
 │   ├── storage/        # Token/session storage
 │   ├── constants/
 │   └── utils/
 ├── features/
 │   ├── auth/
 │   ├── dashboard/
 │   ├── activities/
 │   ├── organization/
 │   ├── notifications/
 │   ├── volunteers/
 │   └── feedback/
 ├── models/             # API DTOs
 ├── routes/
 └── main.dart
```

- Strongly typed API models
- Centralized API service layer
- Proper separation of UI, logic, and data
- Avoid business logic inside widgets

(State management: choose **Riverpod / Provider** — justify choice briefly)

---

### API Integration Rules

- Follow API request/response exactly as documented
- Use pagination where supported
- Handle `401` by forcing logout
- Show meaningful messages for validation errors
- Assume backend is running at configurable `BASE_URL`

---

### Implementation Phases (Follow This Order)

1. Authentication + Token handling
2. Base app navigation + role routing
3. Activity module (most critical)
4. Dashboard (read-only metrics)
5. Organization tree (read-only first)
6. Notifications
7. Volunteer & feedback modules (basic views)

Deliver **incremental, compilable code** after each phase.

---

### What You Should Produce

- Flutter UI code integrated into the existing project
- API service classes
- Data models mapped to backend schemas
- Navigation & routing logic
- Basic theming
- Clear TODOs for future enhancements

Do **not** invent backend APIs.
If something is missing, **use the closest existing endpoint** and leave a TODO.

---

### Working Style

- Be explicit and structured
- Prefer correctness over speed
- Explain architectural decisions briefly
- Keep code production-ready

---

### Final Objective

By the end, the Flutter app should allow a real party member to:

1. Log in
2. See their role-appropriate dashboard
3. Log or manage activities
4. Navigate the organization structure
5. Receive notifications

This app will be used in **real political field operations**, so correctness and clarity matter.
