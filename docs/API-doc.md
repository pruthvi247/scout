# SCOUT-PMS - Political Management System

A comprehensive backend API for managing political organization activities, members, volunteers, and communications.

## Features

- **Activity Tracking**: Log and track activities with location check-ins and media uploads
- **Organization Chart**: Dynamic hierarchical organization structure management
- **Dashboard & Analytics**: Real-time statistics and engagement metrics
- **Notifications**: Push notifications with segmentation and read tracking
- **Member Profiles**: Complete member management with role-based access
- **Volunteer Coordination**: Assignment tracking, event management, and performance scoring
- **Feedback & Grievances**: Issue tracking and resolution workflow
- **Content Management**: Centralized content publishing and management

## Tech Stack

- **FastAPI**: Modern Python web framework
- **SQLite Cloud**: Cloud-hosted SQLite database
- **SQLAlchemy**: SQL toolkit and ORM
- **JWT**: Token-based authentication
- **Pydantic**: Data validation

## Prerequisites

- Python 3.9+
- Docker and Docker Compose
- SQLite Cloud account (or use local SQLite)

## Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd scout-pms
```

2. Create virtual environment:
```bash
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
```

3. Install dependencies:
```bash
pip install -r requirements.txt
```

4. Set up environment variables:
```bash
cp .env.example .env
# Edit .env with your SQLite Cloud credentials and other settings
# IMPORTANT: Update SQLITECLOUD_HOST, SQLITECLOUD_DATABASE, and SQLITECLOUD_APIKEY
```

5. Configure SQLite Cloud connection in `.env` file:
```bash
# Required SQLite Cloud settings - update these with your actual credentials
SQLITECLOUD_HOST=your-host.sqlite.cloud
SQLITECLOUD_PORT=8860
SQLITECLOUD_DATABASE=your-database-name
SQLITECLOUD_APIKEY=your-api-key-here

# Also set SECRET_KEY for JWT tokens (use a strong random string in production)
SECRET_KEY=your-secret-key-change-in-production
```

**Note:** The `.env` file is gitignored and will not be committed to the repository. Always use `.env.example` as a template.

6. Run the application:
```bash
uvicorn app.main:app --reload
```

The API will be available at `http://localhost:8000`
API documentation at `http://localhost:8000/api/docs`

## Docker Setup

1. Create `.env` file from `.env.example`:
```bash
cp .env.example .env
# Edit .env with your SQLite Cloud credentials
```

2. Build and run with Docker Compose:
```bash
docker-compose up --build
```

This will start:
- API server on port 8000

3. Access the API:
- API: http://localhost:8000
- API Docs: http://localhost:8000/api/docs
- ReDoc: http://localhost:8000/api/redoc

**Note:** Docker Compose will automatically load environment variables from the `.env` file.

## API Endpoints

### Authentication

#### Register User
```bash
curl -X POST http://localhost:8000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "username": "john_doe",
    "email": "john@example.com",
    "password": "securepassword123",
    "full_name": "John Doe",
    "role": "activist"
  }'
```

#### Login
```bash
curl -X POST http://localhost:8000/api/auth/login \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "username=john_doe&password=securepassword123"
```

#### Get Current User
```bash
TOKEN="your_access_token_here"
curl -X GET http://localhost:8000/api/auth/me \
  -H "Authorization: Bearer $TOKEN"
```

### Users

#### List Users
```bash
TOKEN="your_access_token_here"
curl -X GET "http://localhost:8000/api/users?skip=0&limit=10" \
  -H "Authorization: Bearer $TOKEN"
```

#### Get User Details
```bash
TOKEN="your_access_token_here"
curl -X GET http://localhost:8000/api/users/1 \
  -H "Authorization: Bearer $TOKEN"
```

#### Update User
```bash
TOKEN="your_access_token_here"
curl -X PUT http://localhost:8000/api/users/1 \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "full_name": "John Updated",
    "phone": "+1234567890"
  }'
```

### Activities

#### Create Activity
```bash
TOKEN="your_access_token_here"
curl -X POST http://localhost:8000/api/activities \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "activity_type": "meeting",
    "title": "Community Meeting",
    "description": "Monthly community gathering",
    "location": {
      "lat": 40.7128,
      "lng": -74.0060,
      "address": "123 Main St, City"
    },
    "check_in_time": "2024-01-15T10:00:00Z",
    "organization_level": "district"
  }'
```

#### List Activities
```bash
TOKEN="your_access_token_here"
curl -X GET "http://localhost:8000/api/activities?skip=0&limit=10&status=pending" \
  -H "Authorization: Bearer $TOKEN"
```

#### Get Activity Details
```bash
TOKEN="your_access_token_here"
curl -X GET http://localhost:8000/api/activities/1 \
  -H "Authorization: Bearer $TOKEN"
```

#### Verify Activity (Admin/Incharge only)
```bash
TOKEN="your_access_token_here"
curl -X POST http://localhost:8000/api/activities/1/verify \
  -H "Authorization: Bearer $TOKEN"
```

### Organization
- `GET /api/organization/tree` - Get organization tree
- `POST /api/organization/nodes` - Create organization node
- `GET /api/organization/nodes` - List nodes
- `PUT /api/organization/nodes/{node_id}` - Update node

### Dashboard

#### Get Dashboard Statistics
```bash
TOKEN="your_access_token_here"
curl -X GET "http://localhost:8000/api/dashboard/stats?organization_level=district" \
  -H "Authorization: Bearer $TOKEN"
```

#### Get Member Statistics
```bash
TOKEN="your_access_token_here"
curl -X GET "http://localhost:8000/api/dashboard/members?organization_level=district" \
  -H "Authorization: Bearer $TOKEN"
```

#### Get Engagement Metrics
```bash
TOKEN="your_access_token_here"
curl -X GET "http://localhost:8000/api/dashboard/engagement?organization_level=district" \
  -H "Authorization: Bearer $TOKEN"
```

### Notifications
- `POST /api/notifications` - Create notification
- `GET /api/notifications` - List notifications
- `POST /api/notifications/{notification_id}/send` - Send notification
- `POST /api/notifications/{notification_id}/mark-read` - Mark as read

### Volunteers
- `GET /api/volunteers` - List volunteers
- `POST /api/volunteers/{volunteer_id}/assignments` - Create assignment
- `POST /api/volunteers/{volunteer_id}/score` - Update performance score

### Events
- `POST /api/events` - Create event
- `GET /api/events` - List events
- `POST /api/events/{event_id}/attendance` - Record attendance

### Feedback
- `POST /api/feedback` - Submit feedback/grievance
- `GET /api/feedback` - List feedback
- `POST /api/feedback/{feedback_id}/resolve` - Resolve feedback

### Content
- `POST /api/content` - Create content
- `GET /api/content` - List content
- `POST /api/content/{content_id}/publish` - Publish content

## Roles & Permissions

- **Admin**: Full access to all features
- **Incharge**: Access to their organization level and below
- **Activist**: Can create/view own activities, limited view access
- **Volunteer**: Can view assignments, record attendance

## Database Tables

- `users` - User accounts and profiles
- `activities` - Activity logs and submissions
- `organization_nodes` - Organization hierarchy
- `notifications` - Notifications and messages
- `volunteers` - Volunteer records and assignments
- `events` - Event information
- `feedback` - Feedback and grievances
- `content` - Content management

## Quick Start Example

```bash
# 1. Register a new user
curl -X POST http://localhost:8000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "username": "testuser",
    "email": "test@example.com",
    "password": "testpass123",
    "full_name": "Test User",
    "role": "activist"
  }'

# 2. Login and save token
TOKEN=$(curl -s -X POST http://localhost:8000/api/auth/login \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "username=testuser&password=testpass123" | \
  python3 -c "import sys, json; print(json.load(sys.stdin)['access_token'])")

# 3. Get current user info
curl -X GET http://localhost:8000/api/auth/me \
  -H "Authorization: Bearer $TOKEN" | python3 -m json.tool

# 4. Create an activity
curl -X POST http://localhost:8000/api/activities \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "activity_type": "meeting",
    "title": "Test Activity",
    "description": "This is a test activity",
    "location": {
      "lat": 40.7128,
      "lng": -74.0060,
      "address": "Test Location"
    },
    "check_in_time": "2024-01-15T10:00:00Z",
    "organization_level": "district"
  }' | python3 -m json.tool

# 5. Get dashboard stats
curl -X GET http://localhost:8000/api/dashboard/stats \
  -H "Authorization: Bearer $TOKEN" | python3 -m json.tool
```

## Development

### Project Structure
```
scout-pms/
├── app/
│   ├── main.py              # FastAPI app
│   ├── config.py            # Configuration
│   ├── database.py          # SQLite Cloud connection
│   ├── db_models.py         # SQLAlchemy models
│   ├── models/              # Pydantic models
│   ├── schemas/             # Schema converters
│   ├── api/                 # API routes
│   └── utils/               # Utilities
├── uploads/                 # File uploads
├── requirements.txt
├── Dockerfile
└── docker-compose.yml
```

## Testing

API documentation includes interactive testing via Swagger UI at `/api/docs`

## Security Notes

- Change `SECRET_KEY` in production
- Use environment variables for sensitive data
- Implement rate limiting in production
- Use HTTPS in production
- Regularly update dependencies

## License

[Your License Here]

