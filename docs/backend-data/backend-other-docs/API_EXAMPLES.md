# SCOUT-PMS API - cURL Examples

Base URL: `http://localhost:8000`

## Health Check

```bash
# Health check
curl -X GET http://localhost:8000/api/health

# Root endpoint
curl -X GET http://localhost:8000/
```

## Authentication

### Register a new user
```bash
curl -X POST http://localhost:8000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "username": "john_doe",
    "email": "john@example.com",
    "password": "securepassword123",
    "full_name": "John Doe",
    "role": "activist",
    "post_type": "volunteer",
    "organization_level": "district",
    "organization_path": ["state1", "district1"],
    "phone": "+1234567890"
  }'
```

### Login
```bash
curl -X POST http://localhost:8000/api/auth/login \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "username=john_doe&password=securepassword123"
```

### Get current user info (requires token)
```bash
# First login to get token, then use it:
TOKEN="your_access_token_here"

curl -X GET http://localhost:8000/api/auth/me \
  -H "Authorization: Bearer $TOKEN"
```

## Users

### List users (requires admin/incharge role)
```bash
curl -X GET "http://localhost:8000/api/users?skip=0&limit=10" \
  -H "Authorization: Bearer $TOKEN"
```

### Get user by ID
```bash
curl -X GET http://localhost:8000/api/users/1 \
  -H "Authorization: Bearer $TOKEN"
```

### Update user
```bash
curl -X PUT http://localhost:8000/api/users/1 \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "full_name": "John Updated",
    "phone": "+9876543210"
  }'
```

### Get user activities
```bash
curl -X GET "http://localhost:8000/api/users/1/activities?skip=0&limit=10" \
  -H "Authorization: Bearer $TOKEN"
```

## Activities

### Create activity
```bash
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
    "media_files": [],
    "tags": ["community", "meeting"]
  }'
```

### List activities
```bash
curl -X GET "http://localhost:8000/api/activities?skip=0&limit=10&status=pending" \
  -H "Authorization: Bearer $TOKEN"
```

### Get activity by ID
```bash
curl -X GET http://localhost:8000/api/activities/1 \
  -H "Authorization: Bearer $TOKEN"
```

### Verify activity (admin/incharge only)
```bash
curl -X POST http://localhost:8000/api/activities/1/verify \
  -H "Authorization: Bearer $TOKEN"
```

### Reject activity (admin/incharge only)
```bash
curl -X POST http://localhost:8000/api/activities/1/reject \
  -H "Authorization: Bearer $TOKEN"
```

## Organization

### Get organization tree
```bash
curl -X GET http://localhost:8000/api/organization/tree \
  -H "Authorization: Bearer $TOKEN"
```

### List organization nodes
```bash
curl -X GET "http://localhost:8000/api/organization/nodes?skip=0&limit=10" \
  -H "Authorization: Bearer $TOKEN"
```

### Create organization node (admin/incharge only)
```bash
curl -X POST http://localhost:8000/api/organization/nodes \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "District 1",
    "type": "district",
    "parent_id": null,
    "assigned_member_id": null
  }'
```

## Dashboard

### Get dashboard stats
```bash
curl -X GET "http://localhost:8000/api/dashboard/stats?organization_level=district" \
  -H "Authorization: Bearer $TOKEN"
```

### Get member statistics
```bash
curl -X GET "http://localhost:8000/api/dashboard/members?organization_level=district" \
  -H "Authorization: Bearer $TOKEN"
```

### Get activity statistics
```bash
curl -X GET "http://localhost:8000/api/dashboard/activities?organization_level=district" \
  -H "Authorization: Bearer $TOKEN"
```

### Get engagement metrics
```bash
curl -X GET "http://localhost:8000/api/dashboard/engagement?organization_level=district" \
  -H "Authorization: Bearer $TOKEN"
```

### Get pending reports (admin/incharge only)
```bash
curl -X GET "http://localhost:8000/api/dashboard/pending-reports?skip=0&limit=10" \
  -H "Authorization: Bearer $TOKEN"
```

## Complete Example Workflow

```bash
# 1. Register a user
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
  -d "username=testuser&password=testpass123" | jq -r '.access_token')

echo "Token: $TOKEN"

# 3. Get current user info
curl -X GET http://localhost:8000/api/auth/me \
  -H "Authorization: Bearer $TOKEN" | jq

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
    "check_in_time": "2024-01-15T10:00:00Z"
  }' | jq

# 5. List activities
curl -X GET "http://localhost:8000/api/activities?skip=0&limit=10" \
  -H "Authorization: Bearer $TOKEN" | jq
```

## API Documentation

Interactive API documentation is available at:
- Swagger UI: http://localhost:8000/api/docs
- ReDoc: http://localhost:8000/api/redoc

## Notes

- Replace `$TOKEN` with your actual access token from login
- All endpoints except `/api/auth/register` and `/api/auth/login` require authentication
- Some endpoints require specific roles (admin, incharge)
- Use `jq` for pretty JSON output (optional): `curl ... | jq`

