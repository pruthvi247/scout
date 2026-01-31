# SCOUT-PMS API Flow Guide

A comprehensive guide to all API endpoints with sample curl examples, dependencies, and workflow diagrams.

## 📋 Table of Contents

1. [API Overview](#api-overview)
2. [Authentication Flow](#authentication-flow)
3. [Organization Setup Flow](#organization-setup-flow)
4. [User Management Flow](#user-management-flow)
5. [Activity Workflow](#activity-workflow)
6. [Events Management](#events-management)
7. [Content Management](#content-management)
8. [Feedback System](#feedback-system)
9. [Volunteers Management](#volunteers-management)
10. [Notifications](#notifications)
11. [Dashboard & Analytics](#dashboard--analytics)
12. [Complete Workflow Example](#complete-workflow-example)

---

## 🌐 API Overview

**Base URL:** `http://localhost:8000/api`

### API Modules & Dependencies

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                              SCOUT-PMS API                                   │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  ┌──────────────┐                                                           │
│  │    AUTH      │ ◄─── Entry Point (No Dependencies)                        │
│  │  /api/auth   │                                                           │
│  └──────┬───────┘                                                           │
│         │                                                                    │
│         ▼ (Provides JWT Token)                                              │
│  ┌──────────────────────────────────────────────────────────────────────┐   │
│  │                     AUTHENTICATED ENDPOINTS                          │   │
│  ├──────────────────────────────────────────────────────────────────────┤   │
│  │                                                                      │   │
│  │  ┌─────────────────┐      ┌─────────────────┐                       │   │
│  │  │  ORGANIZATION   │◄────►│     USERS       │                       │   │
│  │  │ /api/organization│      │   /api/users    │                       │   │
│  │  └────────┬────────┘      └────────┬────────┘                       │   │
│  │           │                        │                                 │   │
│  │           ▼                        ▼                                 │   │
│  │  ┌─────────────────────────────────────────────────────────┐        │   │
│  │  │              CORE FEATURES (Depend on Users/Orgs)        │        │   │
│  │  ├─────────────────────────────────────────────────────────┤        │   │
│  │  │                                                         │        │   │
│  │  │  ┌────────────┐  ┌────────────┐  ┌────────────┐        │        │   │
│  │  │  │ ACTIVITIES │  │   EVENTS   │  │  CONTENT   │        │        │   │
│  │  │  │/api/activ..|  │/api/events │  │/api/content│        │        │   │
│  │  │  └────────────┘  └────────────┘  └────────────┘        │        │   │
│  │  │                                                         │        │   │
│  │  │  ┌────────────┐  ┌────────────┐  ┌────────────┐        │        │   │
│  │  │  │  FEEDBACK  │  │ VOLUNTEERS │  │NOTIFICATIONS│        │        │   │
│  │  │  │/api/feedb..│  │/api/volunt.│  │/api/notif..|        │        │   │
│  │  │  └────────────┘  └────────────┘  └────────────┘        │        │   │
│  │  │                                                         │        │   │
│  │  └─────────────────────────────────────────────────────────┘        │   │
│  │                                                                      │   │
│  │  ┌─────────────────────────────────────────────────────────┐        │   │
│  │  │                     ANALYTICS                            │        │   │
│  │  │                   /api/dashboard                         │        │   │
│  │  │            (Aggregates data from all modules)            │        │   │
│  │  └─────────────────────────────────────────────────────────┘        │   │
│  │                                                                      │   │
│  └──────────────────────────────────────────────────────────────────────┘   │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Role Hierarchy

```
ADMIN (Full Access)
  └── INCHARGE (Manage assigned region)
        └── ACTIVIST (Report activities)
              └── VOLUNTEER (Assigned tasks only)
```

---

## 🔐 Authentication Flow

### 1. Register a New User

```bash
# Register a new user (no auth required)
curl -X POST "http://localhost:8000/api/auth/register" \
  -H "Content-Type: application/json" \
  -d '{
    "username": "admin_user",
    "email": "admin@example.com",
    "phone": "9876543210",
    "password": "SecurePass123!",
    "full_name": "Admin User",
    "role": "admin",
    "organization_level": "national",
    "organization_path": ["1"]
  }'
```

**Response:**

```json
{
  "id": 1,
  "username": "admin_user",
  "email": "admin@example.com",
  "full_name": "Admin User",
  "role": "admin",
  "is_active": true,
  "is_verified": false,
  "created_at": "2026-01-31T10:00:00"
}
```

### 2. Login and Get Token

```bash
# Login to get JWT token
curl -X POST "http://localhost:8000/api/auth/login" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "username=admin_user&password=SecurePass123!"
```

**Response:**

```json
{
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "token_type": "bearer"
}
```

### 3. Get Current User Profile

```bash
# Get current logged-in user
curl -X GET "http://localhost:8000/api/auth/me" \
  -H "Authorization: Bearer <ACCESS_TOKEN>"
```

### 4. Token Refresh

```bash
# Refresh access token
curl -X POST "http://localhost:8000/api/auth/refresh" \
  -H "Authorization: Bearer <ACCESS_TOKEN>"
```

---

## 🏛️ Organization Setup Flow

**Dependency:** Authentication required

### Organization Hierarchy

```
National (Level 0)
  └── State (Level 1)
        └── District (Level 2)
              └── Constituency (Level 3)
                    └── MP (Level 4)
                          └── MLA (Level 5)
                                └── Mandal (Level 6)
                                      └── Panchayath/Ward (Level 7)
                                            └── Booth (Level 8)
```

### 1. Create Organization Tree (Top-Down)

```bash
# Step 1: Create National Level (Root)
curl -X POST "http://localhost:8000/api/organization/nodes" \
  -H "Authorization: Bearer <TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "National Party HQ",
    "type": "national"
  }'
# Returns: id=1

# Step 2: Create State under National
curl -X POST "http://localhost:8000/api/organization/nodes" \
  -H "Authorization: Bearer <TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Telangana",
    "type": "state",
    "parent_id": 1
  }'
# Returns: id=2

# Step 3: Create District under State
curl -X POST "http://localhost:8000/api/organization/nodes" \
  -H "Authorization: Bearer <TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Hyderabad",
    "type": "district",
    "parent_id": 2
  }'
# Returns: id=3

# Step 4: Create Constituency
curl -X POST "http://localhost:8000/api/organization/nodes" \
  -H "Authorization: Bearer <TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Secunderabad",
    "type": "constituency",
    "parent_id": 3
  }'
# Returns: id=4

# Continue for MP, MLA, Mandal, Ward/Panchayath, Booth...
```

### 2. Get Organization Tree

```bash
# Get full organization tree
curl -X GET "http://localhost:8000/api/organization/tree" \
  -H "Authorization: Bearer <TOKEN>"
```

**Response:**

```json
[
  {
    "id": 1,
    "name": "National Party HQ",
    "type": "national",
    "level": 0,
    "children": [
      {
        "id": 2,
        "name": "Telangana",
        "type": "state",
        "level": 1,
        "children": [...]
      }
    ]
  }
]
```

### 3. List Organization Nodes with Filters

```bash
# List all districts
curl -X GET "http://localhost:8000/api/organization/nodes?type=district" \
  -H "Authorization: Bearer <TOKEN>"

# List children of a specific parent
curl -X GET "http://localhost:8000/api/organization/nodes?parent_id=2" \
  -H "Authorization: Bearer <TOKEN>"
```

### 4. Get Specific Node

```bash
curl -X GET "http://localhost:8000/api/organization/nodes/5" \
  -H "Authorization: Bearer <TOKEN>"
```

### 5. Update Organization Node

```bash
curl -X PUT "http://localhost:8000/api/organization/nodes/5" \
  -H "Authorization: Bearer <TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Updated Mandal Name",
    "assigned_member_id": 10
  }'
```

---

## 👥 User Management Flow

**Dependencies:**

- Authentication required
- Organization nodes should exist for proper user assignment

### User Roles & Permissions

| Role      | Can Create Users      | Can View   | Can Manage |
| --------- | --------------------- | ---------- | ---------- |
| Admin     | All roles             | All users  | All users  |
| Incharge  | Activists, Volunteers | Own region | Own region |
| Activist  | None                  | Self only  | Self only  |
| Volunteer | None                  | Self only  | Self only  |

### 1. Create Users (Hierarchical)

```bash
# Create National Incharge (Admin only)
curl -X POST "http://localhost:8000/api/auth/register" \
  -H "Content-Type: application/json" \
  -d '{
    "username": "national_incharge",
    "email": "national@party.com",
    "phone": "9000000001",
    "password": "Password123!",
    "full_name": "Mohan Patel",
    "role": "incharge",
    "organization_level": "national",
    "organization_path": ["1"]
  }'
# Returns: id=2

# Create State Incharge (reports to national incharge)
curl -X POST "http://localhost:8000/api/auth/register" \
  -H "Content-Type: application/json" \
  -d '{
    "username": "state_incharge_ts",
    "email": "ts.incharge@party.com",
    "phone": "9000000002",
    "password": "Password123!",
    "full_name": "Prakash Rao",
    "role": "incharge",
    "organization_level": "state",
    "organization_path": ["1", "2"],
    "parent_incharge_id": 2
  }'
# Returns: id=3

# Create Activist under State Incharge
curl -X POST "http://localhost:8000/api/auth/register" \
  -H "Content-Type: application/json" \
  -d '{
    "username": "activist_hyd",
    "email": "activist.hyd@party.com",
    "phone": "9000000003",
    "password": "Password123!",
    "full_name": "Kavitha Singh",
    "role": "activist",
    "organization_level": "district",
    "organization_path": ["1", "2", "3"],
    "parent_incharge_id": 3
  }'
```

### 2. List Users

```bash
# List all users (Admin/Incharge only)
curl -X GET "http://localhost:8000/api/users" \
  -H "Authorization: Bearer <TOKEN>"

# Filter by role
curl -X GET "http://localhost:8000/api/users?role=activist" \
  -H "Authorization: Bearer <TOKEN>"

# Filter by organization level
curl -X GET "http://localhost:8000/api/users?organization_level=mandal" \
  -H "Authorization: Bearer <TOKEN>"

# Filter by active status with pagination
curl -X GET "http://localhost:8000/api/users?is_active=true&skip=0&limit=50" \
  -H "Authorization: Bearer <TOKEN>"
```

### 3. Get User Details

```bash
curl -X GET "http://localhost:8000/api/users/5" \
  -H "Authorization: Bearer <TOKEN>"
```

### 4. Update User

```bash
curl -X PUT "http://localhost:8000/api/users/5" \
  -H "Authorization: Bearer <TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{
    "full_name": "Updated Name",
    "phone": "9999999999"
  }'
```

### 5. Get User Hierarchy

```bash
# Get subordinates of a user
curl -X GET "http://localhost:8000/api/users/5/subordinates" \
  -H "Authorization: Bearer <TOKEN>"
```

---

## 📋 Activity Workflow

**Dependencies:**

- Authentication required
- User must exist with proper organization assignment

### Activity Types

- `meeting` - Meetings and gatherings
- `door_to_door` - Door-to-door campaigns
- `event` - Events organized
- `survey` - Survey conducted
- `rally` - Public rallies
- `social_service` - Social service activities

### Activity Status Flow

```
pending ──► verified ──► completed
    │
    └──► rejected
```

### 1. Create Activity

```bash
curl -X POST "http://localhost:8000/api/activities" \
  -H "Authorization: Bearer <TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{
    "activity_type": "door_to_door",
    "title": "Ward 5 Campaign",
    "description": "Door-to-door campaign covering 50 houses",
    "location": {
      "latitude": 17.4239,
      "longitude": 78.4738,
      "address": "Ward 5, Secunderabad",
      "city": "Hyderabad",
      "state": "Telangana"
    },
    "check_in_time": "2026-01-31T10:00:00",
    "tags": ["campaign", "ward5", "voter_awareness"]
  }'
```

**Response:**

```json
{
  "id": 1,
  "user_id": 5,
  "activity_type": "door_to_door",
  "title": "Ward 5 Campaign",
  "status": "pending",
  "organization_level": "ward",
  "created_at": "2026-01-31T10:00:00"
}
```

### 2. List Activities

```bash
# List all activities
curl -X GET "http://localhost:8000/api/activities" \
  -H "Authorization: Bearer <TOKEN>"

# Filter by status
curl -X GET "http://localhost:8000/api/activities?status=pending" \
  -H "Authorization: Bearer <TOKEN>"

# Filter by type
curl -X GET "http://localhost:8000/api/activities?activity_type=meeting" \
  -H "Authorization: Bearer <TOKEN>"

# Filter by date range
curl -X GET "http://localhost:8000/api/activities?start_date=2026-01-01T00:00:00&end_date=2026-01-31T23:59:59" \
  -H "Authorization: Bearer <TOKEN>"

# Filter by region (organization level)
curl -X GET "http://localhost:8000/api/activities?region=mandal" \
  -H "Authorization: Bearer <TOKEN>"
```

### 3. Get Activity Details

```bash
curl -X GET "http://localhost:8000/api/activities/1" \
  -H "Authorization: Bearer <TOKEN>"
```

### 4. Update Activity

```bash
curl -X PUT "http://localhost:8000/api/activities/1" \
  -H "Authorization: Bearer <TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{
    "description": "Updated description with more details",
    "tags": ["campaign", "ward5", "completed"]
  }'
```

### 5. Verify Activity (Incharge/Admin)

```bash
curl -X POST "http://localhost:8000/api/activities/1/verify" \
  -H "Authorization: Bearer <TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{
    "status": "verified"
  }'
```

### 6. Upload Media to Activity

```bash
curl -X POST "http://localhost:8000/api/activities/1/media" \
  -H "Authorization: Bearer <TOKEN>" \
  -F "file=@/path/to/photo.jpg"
```

---

## 📅 Events Management

**Dependencies:**

- Authentication required (Admin/Incharge for creation)
- Volunteers should exist for assignment

### Event Types

- `rally` - Public rallies
- `meeting` - Meetings
- `campaign` - Campaign events
- `training` - Training sessions
- `social_event` - Social events

### 1. Create Event

```bash
curl -X POST "http://localhost:8000/api/events" \
  -H "Authorization: Bearer <TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Youth Rally 2026",
    "description": "Annual youth rally at Tank Bund",
    "event_type": "rally",
    "location": "Tank Bund, Hyderabad",
    "start_time": "2026-02-15T10:00:00",
    "end_time": "2026-02-15T14:00:00",
    "assigned_volunteers": []
  }'
```

### 2. List Events

```bash
# List all events
curl -X GET "http://localhost:8000/api/events" \
  -H "Authorization: Bearer <TOKEN>"

# Filter by event type
curl -X GET "http://localhost:8000/api/events?event_type=rally" \
  -H "Authorization: Bearer <TOKEN>"

# Filter by status
curl -X GET "http://localhost:8000/api/events?status=scheduled" \
  -H "Authorization: Bearer <TOKEN>"
```

### 3. Assign Volunteers to Event

```bash
curl -X POST "http://localhost:8000/api/events/1/assign-volunteers" \
  -H "Authorization: Bearer <TOKEN>" \
  -H "Content-Type: application/json" \
  -d '[10, 11, 12, 13]'
```

### 4. Record Event Attendance

```bash
curl -X POST "http://localhost:8000/api/events/1/attendance" \
  -H "Authorization: Bearer <TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{
    "volunteer_ids": [10, 11, 12],
    "attendance_time": "2026-02-15T10:15:00"
  }'
```

### 5. Update Event Status

```bash
curl -X PUT "http://localhost:8000/api/events/1" \
  -H "Authorization: Bearer <TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{
    "status": "completed",
    "attendance_count": 150
  }'
```

---

## 📝 Content Management

**Dependencies:**

- Authentication required
- Admin/Incharge for creation and publishing

### Content Types

- `announcement` - Official announcements
- `news` - News articles
- `circular` - Internal circulars
- `training_material` - Training documents

### 1. Create Content

```bash
curl -X POST "http://localhost:8000/api/content" \
  -H "Authorization: Bearer <TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{
    "type": "announcement",
    "title": "Important Update for All Members",
    "content": "Details of the upcoming state-level meeting...",
    "tags": ["important", "meeting", "state"],
    "target_audience": {
      "roles": ["incharge", "activist"],
      "levels": ["state", "district"]
    }
  }'
```

### 2. List Content

```bash
# List published content
curl -X GET "http://localhost:8000/api/content?is_published=true" \
  -H "Authorization: Bearer <TOKEN>"

# Filter by type
curl -X GET "http://localhost:8000/api/content?type=announcement" \
  -H "Authorization: Bearer <TOKEN>"
```

### 3. Publish Content

```bash
curl -X POST "http://localhost:8000/api/content/1/publish" \
  -H "Authorization: Bearer <TOKEN>"
```

### 4. Update Content

```bash
curl -X PUT "http://localhost:8000/api/content/1" \
  -H "Authorization: Bearer <TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Updated Title",
    "content": "Updated content body..."
  }'
```

---

## 💬 Feedback System

**Dependencies:**

- Authentication required
- Any user can submit feedback

### Feedback Types

- `feedback` - General feedback
- `grievance` - Complaints/grievances
- `suggestion` - Suggestions

### Feedback Status Flow

```
open ──► in_progress ──► resolved
              │
              └──► escalated
```

### 1. Submit Feedback

```bash
curl -X POST "http://localhost:8000/api/feedback" \
  -H "Authorization: Bearer <TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{
    "type": "grievance",
    "title": "Issue with Event Organization",
    "description": "Details of the issue faced during the recent rally...",
    "category": "event_management",
    "priority": "high"
  }'
```

### 2. List Feedback

```bash
# List all feedback (Admin/Incharge see all, others see own)
curl -X GET "http://localhost:8000/api/feedback" \
  -H "Authorization: Bearer <TOKEN>"

# Filter by type and priority
curl -X GET "http://localhost:8000/api/feedback?type=grievance&priority=high" \
  -H "Authorization: Bearer <TOKEN>"

# Filter by status
curl -X GET "http://localhost:8000/api/feedback?status=open" \
  -H "Authorization: Bearer <TOKEN>"
```

### 3. Assign Feedback

```bash
curl -X POST "http://localhost:8000/api/feedback/1/assign?assign_to_id=5" \
  -H "Authorization: Bearer <TOKEN>"
```

### 4. Resolve Feedback

```bash
curl -X POST "http://localhost:8000/api/feedback/1/resolve" \
  -H "Authorization: Bearer <TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{
    "resolution_notes": "Issue has been addressed and resolved."
  }'
```

---

## 🤝 Volunteers Management

**Dependencies:**

- Authentication required
- Admin/Incharge roles for management operations

### 1. List Volunteers

```bash
# List all volunteers (Admin/Incharge only)
curl -X GET "http://localhost:8000/api/volunteers" \
  -H "Authorization: Bearer <TOKEN>"

# With pagination
curl -X GET "http://localhost:8000/api/volunteers?skip=0&limit=50" \
  -H "Authorization: Bearer <TOKEN>"
```

**Response:**

```json
[
  {
    "id": 1,
    "user_id": 15,
    "assignments": [],
    "events": [],
    "performance_score": 85.5,
    "created_at": "2024-01-15T10:00:00"
  }
]
```

### 2. Get Volunteer Details

```bash
curl -X GET "http://localhost:8000/api/volunteers/1" \
  -H "Authorization: Bearer <TOKEN>"
```

**Response:**

```json
{
  "id": 1,
  "user_id": 15,
  "assignments": [
    {
      "assignment_id": "a1b2c3d4",
      "title": "Door-to-door campaign",
      "status": "completed"
    }
  ],
  "events": ["Event A", "Event B"],
  "attendance_records": [],
  "performance_score": 85.5,
  "performance_history": [],
  "created_at": "2024-01-15T10:00:00",
  "updated_at": "2024-01-20T14:30:00"
}
```

### 3. Create Assignment for Volunteer

```bash
curl -X POST "http://localhost:8000/api/volunteers/1/assignments" \
  -H "Authorization: Bearer <TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Door-to-door voter awareness",
    "description": "Cover streets 1-5 in the ward",
    "due_date": "2024-02-15T18:00:00"
  }'
```

**Response:**

```json
{
  "assignment_id": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
  "title": "Door-to-door voter awareness",
  "description": "Cover streets 1-5 in the ward",
  "status": "pending",
  "assigned_at": "2024-01-25T10:00:00",
  "due_date": "2024-02-15T18:00:00"
}
```

### 4. Get Volunteer Assignments

```bash
curl -X GET "http://localhost:8000/api/volunteers/1/assignments" \
  -H "Authorization: Bearer <TOKEN>"
```

### 5. Update Assignment Status

```bash
curl -X PUT "http://localhost:8000/api/volunteers/1/assignments/a1b2c3d4-e5f6-7890?status=completed" \
  -H "Authorization: Bearer <TOKEN>"
```

### 6. Update Performance Score

```bash
curl -X POST "http://localhost:8000/api/volunteers/1/score?score=92.5&notes=Excellent%20work%20on%20campaign" \
  -H "Authorization: Bearer <TOKEN>"
```

**Response:**

```json
{
  "message": "Performance score updated"
}
```

### 7. Get Performance History

```bash
curl -X GET "http://localhost:8000/api/volunteers/1/performance" \
  -H "Authorization: Bearer <TOKEN>"
```

**Response:**

```json
{
  "performance_score": 92.5,
  "performance_history": [
    {
      "date": "2024-01-25T10:00:00",
      "score": 92.5,
      "notes": "Excellent work on campaign"
    }
  ]
}
```

---

## 🔔 Notifications

**Dependencies:**

- Authentication required
- Admin/Incharge roles for creating and sending notifications

### 1. Create Notification (Draft)

```bash
curl -X POST "http://localhost:8000/api/notifications" \
  -H "Authorization: Bearer <TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Important Meeting Tomorrow",
    "message": "All activists are requested to attend the meeting at 10 AM.",
    "type": "alert",
    "target_audience": {
      "roles": ["activist", "incharge"],
      "organization_levels": ["mandal", "ward"],
      "specific_users": []
    },
    "sent_via": ["push", "sms"],
    "scheduled_at": "2024-01-26T09:00:00"
  }'
```

**Response:**

```json
{
  "id": 1,
  "title": "Important Meeting Tomorrow",
  "message": "All activists are requested to attend...",
  "type": "alert",
  "target_audience": {
    "roles": ["activist", "incharge"],
    "organization_levels": ["mandal", "ward"],
    "specific_users": []
  },
  "sent_via": ["push", "sms"],
  "status": "draft",
  "scheduled_at": "2024-01-26T09:00:00",
  "sent_at": null,
  "created_by": 1,
  "read_by": [],
  "created_at": "2024-01-25T10:00:00",
  "updated_at": null
}
```

### 2. List Notifications

```bash
# List all notifications visible to current user
curl -X GET "http://localhost:8000/api/notifications" \
  -H "Authorization: Bearer <TOKEN>"

# Filter by type and status
curl -X GET "http://localhost:8000/api/notifications?type=alert&status=sent" \
  -H "Authorization: Bearer <TOKEN>"
```

### 3. Get Notification Details

```bash
curl -X GET "http://localhost:8000/api/notifications/1" \
  -H "Authorization: Bearer <TOKEN>"
```

### 4. Send Notification

```bash
# Send a draft notification (Admin/Incharge only)
curl -X POST "http://localhost:8000/api/notifications/1/send" \
  -H "Authorization: Bearer <TOKEN>"
```

**Response:**

```json
{
  "id": 1,
  "title": "Important Meeting Tomorrow",
  "status": "sent",
  "sent_at": "2024-01-25T10:30:00",
  "...": "..."
}
```

### 5. Mark Notification as Read

```bash
curl -X POST "http://localhost:8000/api/notifications/1/mark-read" \
  -H "Authorization: Bearer <TOKEN>"
```

### 6. Get Unread Notifications Count

```bash
curl -X GET "http://localhost:8000/api/notifications/unread/count" \
  -H "Authorization: Bearer <TOKEN>"
```

**Response:**

```json
{
  "unread_count": 5
}
```

---

## 📊 Dashboard & Analytics

**Dependencies:**

- Authentication required
- Aggregates data from activities, users, organizations

### 1. Get Dashboard Stats

```bash
# Get overall dashboard stats
curl -X GET "http://localhost:8000/api/dashboard/stats" \
  -H "Authorization: Bearer <TOKEN>"

# Filter by organization level
curl -X GET "http://localhost:8000/api/dashboard/stats?organization_level=district" \
  -H "Authorization: Bearer <TOKEN>"
```

**Response:**

```json
{
  "total_members": 735,
  "recent_activities": 156,
  "pending_reports": 23,
  "verified_activities": 120,
  "engagement_level": 21.22
}
```

### 2. Get Member Statistics

```bash
curl -X GET "http://localhost:8000/api/dashboard/members" \
  -H "Authorization: Bearer <TOKEN>"
```

**Response:**

```json
{
  "by_role": {
    "incharge": 96,
    "activist": 288,
    "volunteer": 351
  }
}
```

### 3. Get Activity Statistics

```bash
curl -X GET "http://localhost:8000/api/dashboard/activities?start_date=2026-01-01T00:00:00&end_date=2026-01-31T23:59:59" \
  -H "Authorization: Bearer <TOKEN>"
```

---

## 🔄 Complete Workflow Example

### Scenario: Setting up a new Mandal with team

```bash
# ================================================================
# Step 1: Admin Login
# ================================================================
TOKEN=$(curl -s -X POST "http://localhost:8000/api/auth/login" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "username=admin&password=admin123" | jq -r '.access_token')

echo "Token: $TOKEN"

# ================================================================
# Step 2: Create Organization Hierarchy (if not exists)
# ================================================================

# Create National (skip if exists)
curl -X POST "http://localhost:8000/api/organization/nodes" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"name": "Party HQ", "type": "national"}'

# Create State
curl -X POST "http://localhost:8000/api/organization/nodes" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"name": "Telangana", "type": "state", "parent_id": 1}'

# Create District
curl -X POST "http://localhost:8000/api/organization/nodes" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"name": "Hyderabad", "type": "district", "parent_id": 2}'

# Create Constituency
curl -X POST "http://localhost:8000/api/organization/nodes" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"name": "Secunderabad", "type": "constituency", "parent_id": 3}'

# Create MP
curl -X POST "http://localhost:8000/api/organization/nodes" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"name": "Secunderabad MP", "type": "mp", "parent_id": 4}'

# Create MLA
curl -X POST "http://localhost:8000/api/organization/nodes" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"name": "Cantonment", "type": "mla", "parent_id": 5}'

# Create Mandal
MANDAL_RESPONSE=$(curl -s -X POST "http://localhost:8000/api/organization/nodes" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"name": "Trimulgherry", "type": "mandal", "parent_id": 6}')

MANDAL_ID=$(echo $MANDAL_RESPONSE | jq -r '.id')
echo "Created Mandal ID: $MANDAL_ID"

# ================================================================
# Step 3: Create Mandal Incharge
# ================================================================
INCHARGE_RESPONSE=$(curl -s -X POST "http://localhost:8000/api/auth/register" \
  -H "Content-Type: application/json" \
  -d '{
    "username": "mandal_incharge_trim",
    "email": "trim.incharge@party.com",
    "phone": "9876543001",
    "password": "Password123!",
    "full_name": "Kavitha Sharma",
    "role": "incharge",
    "organization_level": "mandal",
    "organization_path": ["1", "2", "3", "4", "5", "6", "7"],
    "parent_incharge_id": 30
  }')

INCHARGE_ID=$(echo $INCHARGE_RESPONSE | jq -r '.id')
echo "Created Mandal Incharge ID: $INCHARGE_ID"

# ================================================================
# Step 4: Create Team Members (Activists)
# ================================================================
for i in 1 2 3 4; do
  curl -s -X POST "http://localhost:8000/api/auth/register" \
    -H "Content-Type: application/json" \
    -d "{
      \"username\": \"activist_trim_$i\",
      \"email\": \"activist$i@trim.party.com\",
      \"phone\": \"987654300$i\",
      \"password\": \"Password123!\",
      \"full_name\": \"Activist $i\",
      \"role\": \"activist\",
      \"organization_level\": \"mandal\",
      \"organization_path\": [\"1\", \"2\", \"3\", \"4\", \"5\", \"6\", \"7\"],
      \"parent_incharge_id\": $INCHARGE_ID
    }"
done

# ================================================================
# Step 5: Create Volunteers
# ================================================================
for i in 1 2 3 4 5; do
  curl -s -X POST "http://localhost:8000/api/auth/register" \
    -H "Content-Type: application/json" \
    -d "{
      \"username\": \"volunteer_trim_$i\",
      \"email\": \"volunteer$i@trim.party.com\",
      \"phone\": \"987654400$i\",
      \"password\": \"Password123!\",
      \"full_name\": \"Volunteer $i\",
      \"role\": \"volunteer\",
      \"organization_level\": \"mandal\",
      \"organization_path\": [\"1\", \"2\", \"3\", \"4\", \"5\", \"6\", \"7\"],
      \"parent_incharge_id\": $INCHARGE_ID
    }"
done

# ================================================================
# Step 6: Login as Activist and Create Activity
# ================================================================
ACTIVIST_TOKEN=$(curl -s -X POST "http://localhost:8000/api/auth/login" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "username=activist_trim_1&password=Password123!" | jq -r '.access_token')

curl -X POST "http://localhost:8000/api/activities" \
  -H "Authorization: Bearer $ACTIVIST_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "activity_type": "door_to_door",
    "title": "Voter Awareness Campaign",
    "description": "Conducted door-to-door campaign in Trimulgherry area",
    "location": {
      "latitude": 17.4839,
      "longitude": 78.4983,
      "address": "Trimulgherry, Secunderabad",
      "city": "Hyderabad",
      "state": "Telangana"
    },
    "check_in_time": "2026-01-31T10:00:00",
    "tags": ["voter_awareness", "door_to_door"]
  }'

# ================================================================
# Step 7: Login as Incharge and Verify Activity
# ================================================================
INCHARGE_TOKEN=$(curl -s -X POST "http://localhost:8000/api/auth/login" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "username=mandal_incharge_trim&password=Password123!" | jq -r '.access_token')

# Get pending activities
curl -X GET "http://localhost:8000/api/activities?status=pending" \
  -H "Authorization: Bearer $INCHARGE_TOKEN"

# Verify the activity
curl -X POST "http://localhost:8000/api/activities/1/verify" \
  -H "Authorization: Bearer $INCHARGE_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"status": "verified"}'

# ================================================================
# Step 8: Create an Event
# ================================================================
curl -X POST "http://localhost:8000/api/events" \
  -H "Authorization: Bearer $INCHARGE_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Monthly Review Meeting",
    "description": "Monthly review meeting for all mandal members",
    "event_type": "meeting",
    "location": "Mandal Office, Trimulgherry",
    "start_time": "2026-02-01T10:00:00",
    "end_time": "2026-02-01T12:00:00"
  }'

# ================================================================
# Step 9: Check Dashboard Stats
# ================================================================
curl -X GET "http://localhost:8000/api/dashboard/stats?organization_level=mandal" \
  -H "Authorization: Bearer $INCHARGE_TOKEN"

echo "✅ Complete workflow executed successfully!"
```

---

## 📌 Quick Reference

### All Endpoints Summary

| Module            | Endpoint                                     | Method | Auth Required | Role Required  |
| ----------------- | -------------------------------------------- | ------ | ------------- | -------------- |
| **Auth**          | `/api/auth/register`                         | POST   | ❌            | -              |
|                   | `/api/auth/login`                            | POST   | ❌            | -              |
|                   | `/api/auth/me`                               | GET    | ✅            | Any            |
|                   | `/api/auth/refresh`                          | POST   | ✅            | Any            |
| **Users**         | `/api/users`                                 | GET    | ✅            | Admin/Incharge |
|                   | `/api/users/{id}`                            | GET    | ✅            | Any (own)      |
|                   | `/api/users/{id}`                            | PUT    | ✅            | Any (own)      |
|                   | `/api/users/{id}/activate`                   | POST   | ✅            | Admin/Incharge |
|                   | `/api/users/{id}/activities`                 | GET    | ✅            | Any            |
| **Organization**  | `/api/organization/tree`                     | GET    | ✅            | Any            |
|                   | `/api/organization/nodes`                    | GET    | ✅            | Any            |
|                   | `/api/organization/nodes`                    | POST   | ✅            | Admin/Incharge |
|                   | `/api/organization/nodes/{id}`               | GET    | ✅            | Any            |
|                   | `/api/organization/nodes/{id}`               | PUT    | ✅            | Admin/Incharge |
|                   | `/api/organization/nodes/{id}/members`       | GET    | ✅            | Any            |
|                   | `/api/organization/nodes/{id}/assign-member` | POST   | ✅            | Admin/Incharge |
|                   | `/api/organization/nodes/{id}/activities`    | GET    | ✅            | Any            |
| **Activities**    | `/api/activities`                            | GET    | ✅            | Any            |
|                   | `/api/activities`                            | POST   | ✅            | Any            |
|                   | `/api/activities/{id}`                       | GET    | ✅            | Any            |
|                   | `/api/activities/{id}`                       | PUT    | ✅            | Owner          |
|                   | `/api/activities/{id}/verify`                | POST   | ✅            | Admin/Incharge |
|                   | `/api/activities/{id}/reject`                | POST   | ✅            | Admin/Incharge |
| **Events**        | `/api/events`                                | GET    | ✅            | Any            |
|                   | `/api/events`                                | POST   | ✅            | Admin/Incharge |
|                   | `/api/events/{id}`                           | GET    | ✅            | Any            |
|                   | `/api/events/{id}/assign-volunteers`         | POST   | ✅            | Admin/Incharge |
|                   | `/api/events/{id}/attendance`                | POST   | ✅            | Admin/Incharge |
| **Content**       | `/api/content`                               | GET    | ✅            | Any            |
|                   | `/api/content`                               | POST   | ✅            | Admin/Incharge |
|                   | `/api/content/{id}`                          | GET    | ✅            | Any            |
|                   | `/api/content/{id}/publish`                  | POST   | ✅            | Admin/Incharge |
|                   | `/api/content/{id}/unpublish`                | POST   | ✅            | Admin/Incharge |
| **Feedback**      | `/api/feedback`                              | GET    | ✅            | Any            |
|                   | `/api/feedback`                              | POST   | ✅            | Any            |
|                   | `/api/feedback/{id}`                         | GET    | ✅            | Any            |
|                   | `/api/feedback/{id}/assign`                  | POST   | ✅            | Admin/Incharge |
|                   | `/api/feedback/{id}/resolve`                 | POST   | ✅            | Admin/Incharge |
|                   | `/api/feedback/stats/summary`                | GET    | ✅            | Admin/Incharge |
| **Volunteers**    | `/api/volunteers`                            | GET    | ✅            | Admin/Incharge |
|                   | `/api/volunteers/{id}`                       | GET    | ✅            | Any            |
|                   | `/api/volunteers/{id}/assignments`           | GET    | ✅            | Any            |
|                   | `/api/volunteers/{id}/assignments`           | POST   | ✅            | Admin/Incharge |
|                   | `/api/volunteers/{id}/assignments/{aid}`     | PUT    | ✅            | Any            |
|                   | `/api/volunteers/{id}/score`                 | POST   | ✅            | Admin/Incharge |
|                   | `/api/volunteers/{id}/performance`           | GET    | ✅            | Any            |
| **Notifications** | `/api/notifications`                         | GET    | ✅            | Any            |
|                   | `/api/notifications`                         | POST   | ✅            | Admin/Incharge |
|                   | `/api/notifications/{id}`                    | GET    | ✅            | Any            |
|                   | `/api/notifications/{id}/send`               | POST   | ✅            | Admin/Incharge |
|                   | `/api/notifications/{id}/mark-read`          | POST   | ✅            | Any            |
|                   | `/api/notifications/unread/count`            | GET    | ✅            | Any            |
| **Dashboard**     | `/api/dashboard/stats`                       | GET    | ✅            | Any            |
|                   | `/api/dashboard/members`                     | GET    | ✅            | Any            |
|                   | `/api/dashboard/activities`                  | GET    | ✅            | Any            |
|                   | `/api/dashboard/engagement`                  | GET    | ✅            | Any            |
|                   | `/api/dashboard/pending-reports`             | GET    | ✅            | Admin/Incharge |

---

## 🔧 Environment Variables

```bash
# Required for API
DATABASE_URL=sqlite+aiosqlite:///./data/scout_pms.db
SECRET_KEY=your-super-secret-key-here
ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=30
CORS_ORIGINS=http://localhost:3000,http://localhost:8080
```

---

## 🧪 Health Check

```bash
# Check API health
curl http://localhost:8000/api/health

# Response: {"status": "healthy"}
```

---

## 📚 Additional Resources

- **API Docs (Swagger):** http://localhost:8000/api/docs
- **API Docs (ReDoc):** http://localhost:8000/api/redoc
- **Visualization Dashboard:** http://localhost:8080 (from seed-data/visualizations)

---

_Generated: January 31, 2026_
