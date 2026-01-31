# sample data :

### Register a new user

```
curl -X POST http://localhost:8000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "username": "pruthvi",
    "email": "pruthvi@scout.com",
    "password": "pruthvipassword123",
    "full_name": "pruthvi kumar",
    "role": "admin",
    "post_type": "elected",
    "organization_level": "National",
    "phone": "+919916893441"
  }'
```

`output:`

## {"username":"pruthvi","email":"pruthvi@scout.com","phone":"+919916893441","full_name":"pruthvi kumar","role":"admin","post_type":"nominated","organization_level":"State","organization_path":null,"parent_incharge_id":null,"id":3,"profile_photo":null,"is_active":true,"is_verified":false,"created_at":"2026-01-29T11:34:08","updated_at":"2026-01-29T11:34:08","last_login":null}

### Login

```bash
curl -X POST http://localhost:8000/api/auth/login \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "username=pruthvi&password=pruthvipassword123"
```

`output:`

{"access_token":"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJwcnV0aHZpIiwicm9sZSI6ImFkbWluIiwiZXhwIjoxNzY5Njg4NDAzfQ.kFuvSTQmN4cEHL1ItlMLyQjXMTpCp_5UGmlUj7IHP3k","token_type":"bearer"}%

---

export TOKEN="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJwcnV0aHZpIiwicm9sZSI6ImFkbWluIiwiZXhwIjoxNzY5NzEyNDIzfQ.26Vi2guSePMxzvNFs7wRlloj3iyJBLpLME9s3SGGF7E"

---

### Get current user info (requires token)

```bash
# First login to get token, then use it:
TOKEN="your_access_token_here"

curl -X GET http://localhost:8000/api/auth/me \
  -H "Authorization: Bearer $TOKEN"
```

### List All users (requires admin/incharge role)

```bash
curl -X GET "http://localhost:8000/api/users?skip=0&limit=10" \
  -H "Authorization: Bearer $TOKEN"
```

### update user

curl -X PUT http://localhost:8000/api/users/3 \
 -H "Authorization: Bearer $TOKEN" \
 -H "Content-Type: application/json" \
 -d '{
"organization_path": ["State","MP_constituency","District"]
}'

`output`:
{"username":"pruthvi","email":"pruthvi@scout.com","phone":"+919916893441","full_name":"pruthvi kumar","role":"admin","post_type":"nominated","organization_level":"State","organization_path":["State","MP_constituency","District"],"parent_incharge_id":null,"id":3,"profile_photo":null,"is_active":true,"is_verified":false,"created_at":"2026-01-29T11:34:08","updated_at":"2026-01-29T11:58:35.583733","last_login":"2026-01-29T11:36:43.746099"}%

---

### Create Activity

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

`Output`:

{"id":4,"user_id":3,"activity_type":"meeting","title":"Community Meeting","description":"Monthly community gathering","location":{"lat":40.7128,"lng":-74.006,"address":"123 Main St, City"},"check_in_time":"2024-01-15T10:00:00","media_files":[],"status":"pending","verified_by":null,"verified_at":null,"organization_level":"State","tags":["community","meeting"],"created_at":"2026-01-29T12:36:31","updated_at":"2026-01-29T12:36:31"}%

---

### List Activities

curl -X GET "http://localhost:8000/api/activities?skip=0&limit=10&status=pending" \
 -H "Authorization: Bearer $TOKEN"

### Get user Activities

curl -X GET "http://localhost:8000/api/users/2/activities?skip=0&limit=10" \
 -H "Authorization: Bearer $TOKEN"

=====================<<<<<<<<<<<<Second user>>>>>>>>>>>>>===================

curl -X POST http://localhost:8000/api/auth/register \
 -H "Content-Type: application/json" \
 -d '{
"username": "john_doeeeeeeee",
"email": "john@exampleeeeeee.com",
"password": "securepassword123",
"full_name": "John Doeeeeeeeeee",
"role": "activist",
"post_type": "volunteer",
"organization_level": "district",
"organization_path": ["state1", "district1"],
"phone": "+1234567890"
}'

curl -X POST http://localhost:8000/api/auth/login \
 -H "Content-Type: application/x-www-form-urlencoded" \
 -d "username=john_doeeeeeeee&password=securepassword123"

curl -X POST http://localhost:8000/api/activities \
 -H "Authorization: Bearer $TOKEN" \
 -H "Content-Type: application/json" \
 -d '{
"activity_type": "meetingggggg",
"title": "Community Meetinggggg",
"description": "Monthly community gatheringgggg",
"location": {
"lat": 40.7128,
"lng": -74.0060,
"address": "123 Main St, City"
},
"check_in_time": "2024-01-15T10:00:00Z",
"media_files": [],
"tags": ["community", "meeting"]
}'

=====================<<<<<<<<<<<<Third user>>>>>>>>>>>>>===================

curl -X POST http://localhost:8000/api/auth/register \
 -H "Content-Type: application/json" \
 -d '{
"username": "rajshekar",
"email": "rajshekarreddy@ycp.com",
"password": "securepassword123",
"full_name": "Rajshekar Reddy",
"role": "admin",
"post_type": "elected",
"organization_level": "National",
"organization_path": ["state1", "district1"],
"phone": "+12345678908"
}'

curl -X POST http://localhost:8000/api/auth/login \
 -H "Content-Type: application/x-www-form-urlencoded" \
 -d "username=rajshekar&password=securepassword123"

curl -X POST http://localhost:8000/api/activities \
 -H "Authorization: Bearer $TOKEN" \
 -H "Content-Type: application/json" \
 -d '{
"activity_type": "meetingggggg",
"title": "Community Meetinggggg",
"description": "Monthly community gatheringgggg",
"location": {
"lat": 40.7128,
"lng": -74.0060,
"address": "123 Main St, City"
},
"check_in_time": "2024-01-15T10:00:00Z",
"media_files": [],
"tags": ["community", "meeting"]
}'

==============================
Organisatin nodes
==============================

---

=====================<<<<<<<<<<<<YCP>>>>>>>>>>>>>===================

## YCP

### Create organization node (admin/incharge only)

```bash
curl -X POST http://localhost:8000/api/organization/nodes \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "YCP",
    "type": "state",
    "parent_id": null,
    "assigned_member_id": 4
  }'
```

`output`:

{"id":1,"name":"YCP","type":"state","parent_id":null,"path":[],"level":0,"assigned_member_id":4,"member_count":0,"activity_summary":{},"is_active":true,"created_at":"2026-01-31T10:42:29","updated_at":"2026-01-31T10:42:29"}

---

### Create or node

curl -X POST http://localhost:8000/api/organization/nodes \
 -H "Authorization: Bearer $TOKEN" \
 -H "Content-Type: application/json" \
 -d '{
"name": "YCP Center 5D",
"type": "district",
"parent_id": 5,
"assigned_member_id": null
}'

=====================<<<<<<<<<<<<JSP>>>>>>>>>>>>>===================

## JSP

### Create organization node (admin/incharge only)

```bash
curl -X POST http://localhost:8000/api/organization/nodes \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "JSP",
    "type": "state",
    "parent_id": null,
    "assigned_member_id": 1
  }'
```

`output`:
{"id":2,"name":"JSP","type":"state","parent_id":null,"path":[],"level":0,"assigned_member_id":1,"member_count":0,"activity_summary":{},"is_active":true,"created_at":"2026-01-31T10:45:00","updated_at":"2026-01-31T10:45:00"}

---

### Create or node

curl -X POST http://localhost:8000/api/organization/nodes \
 -H "Authorization: Bearer $TOKEN" \
 -H "Content-Type: application/json" \
 -d '{
"name": "JSP Center 5D",
"type": "district",
"parent_id": 5,
"assigned_member_id": null
}'
