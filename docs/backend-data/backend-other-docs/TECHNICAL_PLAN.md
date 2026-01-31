# SCOUT-PMS Technical Implementation Plan

## Architecture Overview

### Technology Stack
- **Backend Framework**: FastAPI (Python 3.9+)
- **Database**: MongoDB (using Motor async driver)
- **Authentication**: JWT (python-jose, passlib)
- **Validation**: Pydantic models
- **File Storage**: Local filesystem (can be extended to S3/cloud storage)
- **Task Queue**: Background tasks with FastAPI BackgroundTasks (can extend to Celery)
- **API Documentation**: Auto-generated with FastAPI/Swagger

### Project Structure
```
scout-pms/
├── app/
│   ├── __init__.py
│   ├── main.py                 # FastAPI app entry point
│   ├── config.py               # Configuration settings
│   ├── database.py             # MongoDB connection
│   ├── models/                 # Pydantic models
│   │   ├── __init__.py
│   │   ├── user.py
│   │   ├── activity.py
│   │   ├── organization.py
│   │   ├── notification.py
│   │   ├── volunteer.py
│   │   ├── feedback.py
│   │   └── content.py
│   ├── schemas/                # MongoDB document schemas
│   │   ├── __init__.py
│   │   ├── user_schema.py
│   │   ├── activity_schema.py
│   │   ├── organization_schema.py
│   │   ├── notification_schema.py
│   │   ├── volunteer_schema.py
│   │   ├── feedback_schema.py
│   │   └── content_schema.py
│   ├── api/                    # API route handlers
│   │   ├── __init__.py
│   │   ├── deps.py             # Dependencies (auth, db)
│   │   ├── routes/
│   │   │   ├── __init__.py
│   │   │   ├── auth.py
│   │   │   ├── users.py
│   │   │   ├── activities.py
│   │   │   ├── organization.py
│   │   │   ├── dashboard.py
│   │   │   ├── notifications.py
│   │   │   ├── volunteers.py
│   │   │   ├── feedback.py
│   │   │   └── content.py
│   ├── services/               # Business logic
│   │   ├── __init__.py
│   │   ├── auth_service.py
│   │   ├── user_service.py
│   │   ├── activity_service.py
│   │   ├── organization_service.py
│   │   ├── dashboard_service.py
│   │   ├── notification_service.py
│   │   ├── volunteer_service.py
│   │   ├── feedback_service.py
│   │   └── content_service.py
│   ├── utils/                  # Utility functions
│   │   ├── __init__.py
│   │   ├── security.py         # Password hashing, JWT
│   │   ├── permissions.py      # RBAC helpers
│   │   └── file_upload.py      # File handling
│   └── middleware/             # Custom middleware
│       ├── __init__.py
│       └── auth_middleware.py
├── uploads/                    # File upload directory
├── tests/                      # Test files
├── requirements.txt
├── Dockerfile
├── docker-compose.yml
├── .env.example
└── README.md
```

## Database Schema Design

### Collections

#### 1. users
- `_id`: ObjectId
- `username`: str (unique)
- `email`: str (unique)
- `phone`: str (unique, optional)
- `password_hash`: str
- `full_name`: str
- `profile_photo`: str (file path)
- `role`: enum (admin, incharge, activist, volunteer)
- `post_type`: enum (nominated, elected, volunteer)
- `organization_level`: str (state, district, mandal, etc.)
- `organization_path`: list[str] (hierarchical path)
- `parent_incharge_id`: ObjectId (reference to user)
- `is_active`: bool
- `is_verified`: bool
- `created_at`: datetime
- `updated_at`: datetime
- `last_login`: datetime

#### 2. activities
- `_id`: ObjectId
- `user_id`: ObjectId (reference to user)
- `activity_type`: str (meeting, social_event, campaign, etc.)
- `title`: str
- `description`: str
- `location`: dict (lat, lng, address)
- `check_in_time`: datetime
- `media_files`: list[str] (file paths)
- `status`: enum (pending, verified, rejected)
- `verified_by`: ObjectId (reference to user, optional)
- `verified_at`: datetime (optional)
- `organization_level`: str
- `tags`: list[str]
- `created_at`: datetime
- `updated_at`: datetime

#### 3. organization_nodes
- `_id`: ObjectId
- `name`: str
- `type`: enum (state, district, mandal, village, etc.)
- `parent_id`: ObjectId (reference to organization_nodes, optional)
- `path`: list[str] (hierarchical path)
- `level`: int (depth in hierarchy)
- `assigned_member_id`: ObjectId (reference to user, optional)
- `member_count`: int
- `activity_summary`: dict (recent activities stats)
- `is_active`: bool
- `created_at`: datetime
- `updated_at`: datetime

#### 4. notifications
- `_id`: ObjectId
- `title`: str
- `message`: str
- `type`: enum (info, alert, reminder, announcement)
- `target_audience`: dict (roles, organization_levels, specific_users)
- `sent_via`: list[enum] (app_push, sms, email)
- `status`: enum (draft, scheduled, sent)
- `scheduled_at`: datetime (optional)
- `sent_at`: datetime (optional)
- `created_by`: ObjectId (reference to user)
- `read_by`: list[dict] (user_id, read_at)
- `created_at`: datetime
- `updated_at`: datetime

#### 5. volunteers
- `_id`: ObjectId
- `user_id`: ObjectId (reference to user)
- `assignments`: list[dict] (assignment_id, title, description, status, assigned_at, completed_at)
- `events`: list[ObjectId] (reference to events)
- `attendance_records`: list[dict] (event_id, attended, check_in_time, check_out_time)
- `performance_score`: float
- `performance_history`: list[dict] (date, score, notes)
- `created_at`: datetime
- `updated_at`: datetime

#### 6. events
- `_id`: ObjectId
- `title`: str
- `description`: str
- `event_type`: str
- `location`: dict (lat, lng, address)
- `start_time`: datetime
- `end_time`: datetime
- `assigned_volunteers`: list[ObjectId] (reference to users)
- `attendance_count`: int
- `created_by`: ObjectId (reference to user)
- `status`: enum (scheduled, ongoing, completed, cancelled)
- `created_at`: datetime
- `updated_at`: datetime

#### 7. feedback
- `_id`: ObjectId
- `user_id`: ObjectId (reference to user)
- `type`: enum (feedback, grievance)
- `title`: str
- `description`: str
- `category`: str
- `priority`: enum (low, medium, high, urgent)
- `status`: enum (open, in_progress, resolved, closed)
- `assigned_to`: ObjectId (reference to user, optional)
- `resolution_notes`: str (optional)
- `resolved_at`: datetime (optional)
- `resolved_by`: ObjectId (reference to user, optional)
- `attachments`: list[str] (file paths)
- `created_at`: datetime
- `updated_at`: datetime

#### 8. content
- `_id`: ObjectId
- `type`: enum (news, campaign_media, event_info, announcement)
- `title`: str
- `content`: str (HTML/markdown)
- `media_files`: list[str] (file paths)
- `tags`: list[str]
- `target_audience`: dict (roles, organization_levels)
- `is_published`: bool
- `published_at`: datetime (optional)
- `created_by`: ObjectId (reference to user)
- `created_at`: datetime
- `updated_at`: datetime

#### 9. activity_reminders
- `_id`: ObjectId
- `user_id`: ObjectId (reference to user)
- `reminder_type`: str (daily, weekly, monthly)
- `last_sent_at`: datetime
- `next_due_at`: datetime
- `is_active`: bool

## API Endpoints Design

### Authentication & Authorization
- `POST /api/auth/register` - User registration
- `POST /api/auth/login` - User login (returns JWT)
- `POST /api/auth/refresh` - Refresh JWT token
- `POST /api/auth/logout` - Logout (token blacklisting)
- `GET /api/auth/me` - Get current user profile

### Users & Profiles
- `GET /api/users` - List users (with filters, pagination)
- `GET /api/users/{user_id}` - Get user details
- `PUT /api/users/{user_id}` - Update user profile
- `DELETE /api/users/{user_id}` - Deactivate user
- `POST /api/users/{user_id}/activate` - Activate user
- `GET /api/users/{user_id}/activities` - Get user's activities

### Activities
- `POST /api/activities` - Create activity (with file upload)
- `GET /api/activities` - List activities (with filters: region, role, status, date range)
- `GET /api/activities/{activity_id}` - Get activity details
- `PUT /api/activities/{activity_id}` - Update activity
- `DELETE /api/activities/{activity_id}` - Delete activity
- `POST /api/activities/{activity_id}/verify` - Verify activity (admin/incharge)
- `POST /api/activities/{activity_id}/reject` - Reject activity
- `GET /api/activities/export` - Export activities (CSV/JSON)

### Organization Chart
- `GET /api/organization/tree` - Get full organization tree
- `GET /api/organization/nodes` - List organization nodes (with filters)
- `POST /api/organization/nodes` - Create organization node
- `GET /api/organization/nodes/{node_id}` - Get node details
- `PUT /api/organization/nodes/{node_id}` - Update node
- `DELETE /api/organization/nodes/{node_id}` - Delete node
- `POST /api/organization/nodes/{node_id}/assign-member` - Assign member to node
- `GET /api/organization/nodes/{node_id}/members` - Get members in node
- `GET /api/organization/nodes/{node_id}/activities` - Get activities for node

### Dashboard & Analytics
- `GET /api/dashboard/stats` - Get dashboard statistics
- `GET /api/dashboard/members` - Member statistics
- `GET /api/dashboard/activities` - Activity statistics
- `GET /api/dashboard/engagement` - Engagement metrics
- `GET /api/dashboard/pending-reports` - Pending activity reports
- `GET /api/dashboard/export` - Export dashboard data

### Notifications
- `POST /api/notifications` - Create notification
- `GET /api/notifications` - List notifications (with filters)
- `GET /api/notifications/{notification_id}` - Get notification details
- `PUT /api/notifications/{notification_id}` - Update notification
- `DELETE /api/notifications/{notification_id}` - Delete notification
- `POST /api/notifications/{notification_id}/send` - Send notification
- `POST /api/notifications/{notification_id}/mark-read` - Mark as read
- `GET /api/notifications/unread` - Get unread notifications count

### Volunteers
- `GET /api/volunteers` - List volunteers
- `GET /api/volunteers/{volunteer_id}` - Get volunteer details
- `POST /api/volunteers/{volunteer_id}/assignments` - Create assignment
- `GET /api/volunteers/{volunteer_id}/assignments` - Get assignments
- `PUT /api/volunteers/{volunteer_id}/assignments/{assignment_id}` - Update assignment
- `POST /api/volunteers/{volunteer_id}/score` - Update performance score
- `GET /api/volunteers/{volunteer_id}/performance` - Get performance history

### Events
- `POST /api/events` - Create event
- `GET /api/events` - List events (with filters)
- `GET /api/events/{event_id}` - Get event details
- `PUT /api/events/{event_id}` - Update event
- `DELETE /api/events/{event_id}` - Delete event
- `POST /api/events/{event_id}/assign-volunteers` - Assign volunteers
- `POST /api/events/{event_id}/attendance` - Record attendance
- `GET /api/events/{event_id}/attendance` - Get attendance list

### Feedback & Grievances
- `POST /api/feedback` - Submit feedback/grievance
- `GET /api/feedback` - List feedback (with filters)
- `GET /api/feedback/{feedback_id}` - Get feedback details
- `PUT /api/feedback/{feedback_id}` - Update feedback
- `POST /api/feedback/{feedback_id}/assign` - Assign to admin/incharge
- `POST /api/feedback/{feedback_id}/resolve` - Resolve feedback
- `GET /api/feedback/stats` - Feedback statistics

### Content Management
- `POST /api/content` - Create content (with file upload)
- `GET /api/content` - List content (with filters)
- `GET /api/content/{content_id}` - Get content details
- `PUT /api/content/{content_id}` - Update content
- `DELETE /api/content/{content_id}` - Delete content
- `POST /api/content/{content_id}/publish` - Publish content
- `POST /api/content/{content_id}/unpublish` - Unpublish content

### File Upload
- `POST /api/upload` - Upload file (images, documents)
- `DELETE /api/upload/{file_path}` - Delete file

## Security & Permissions

### Role-Based Access Control (RBAC)
- **Admin**: Full access to all features
- **Incharge**: Access to their organization level and below
- **Activist**: Can create/view own activities, limited view access
- **Volunteer**: Can view assignments, record attendance

### Permission Matrix
| Feature | Admin | Incharge | Activist | Volunteer |
|---------|-------|----------|----------|-----------|
| View all users | ✓ | Limited | ✗ | ✗ |
| Create activities | ✓ | ✓ | ✓ | ✗ |
| Verify activities | ✓ | Limited | ✗ | ✗ |
| Manage org chart | ✓ | Limited | ✗ | ✗ |
| View dashboard | ✓ | Limited | Limited | ✗ |
| Send notifications | ✓ | Limited | ✗ | ✗ |
| Manage volunteers | ✓ | Limited | ✗ | ✗ |
| Resolve feedback | ✓ | Limited | ✗ | ✗ |
| Manage content | ✓ | Limited | ✗ | ✗ |

## Implementation Phases

### Phase 1: Core Setup
1. Project structure
2. Database connection (MongoDB)
3. Authentication (JWT)
4. Basic user management

### Phase 2: Core Features
1. Activity tracking
2. Organization chart
3. Member profiles

### Phase 3: Advanced Features
1. Dashboard & analytics
2. Notifications
3. Volunteer coordination

### Phase 4: Additional Features
1. Feedback & grievances
2. Content management
3. File uploads

### Phase 5: Polish & Deploy
1. Error handling
2. Logging
3. Testing
4. Docker setup
5. Documentation

