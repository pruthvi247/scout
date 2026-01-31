# Backend 500 Error Troubleshooting Guide

## Error Summary

When creating an activity, the Flutter app receives a 500 Internal Server Error from the backend at `http://192.168.1.5:8000/api/activities`.

## Possible Causes

### 1. Backend Server Issues

**Check if backend is running:**

```bash
# In your backend terminal, you should see:
INFO:     Uvicorn running on http://0.0.0.0:8000 (Press CTRL+C to quit)
```

**Check backend logs:**
Look for Python stack traces or error messages in your backend terminal. Common errors:

- Database connection failed
- Missing environment variables
- Validation errors
- Missing dependencies

### 2. Database Issues

**MongoDB not running:**

```bash
# Check MongoDB status
sudo systemctl status mongod
# or
brew services list | grep mongodb
```

**Database connection string:**
Check your backend `.env` file has correct MongoDB URI:

```
MONGODB_URI=mongodb://localhost:27017
DATABASE_NAME=scout_pms
```

### 3. Request Data Format Issues

The Flutter app sends data in this format:

```json
{
  "activity_type": "meeting",
  "title": "Activity Title",
  "description": "Activity description",
  "location": {
    "lat": 0.0,
    "lng": 0.0,
    "address": "Location address"
  },
  "check_in_time": "2026-01-15T10:00:00.000",
  "organization_level": "district",
  "tags": ["tag1", "tag2"]
}
```

**Common backend validation issues:**

- `user_id` might be required but not sent (should be extracted from JWT token)
- DateTime format incompatibility
- Missing database indexes

### 4. Backend Code Issues

**Check your FastAPI route:**

```python
@router.post("/activities", response_model=Activity)
async def create_activity(
    activity: CreateActivityRequest,
    current_user: User = Depends(get_current_user),
    db = Depends(get_database)
):
    # Make sure user_id is set from current_user
    activity_data = activity.dict()
    activity_data["user_id"] = current_user.id
    activity_data["status"] = "pending"

    # Insert into database
    result = await db.activities.insert_one(activity_data)
    # ...
```

**Common mistakes:**

- Not extracting `user_id` from JWT token
- Not setting default `status = "pending"`
- DateTime serialization issues
- Missing async/await

## Debugging Steps

### Step 1: Check Backend Logs

Run your backend with verbose logging:

```bash
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000 --log-level debug
```

Look for:

- Python exceptions
- Database errors
- Validation errors

### Step 2: Test with curl

Test the endpoint directly:

```bash
# First, login to get token
curl -X POST http://192.168.1.5:8000/api/auth/login \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "username=your_username&password=your_password"

# Copy the access_token from response

# Then test create activity
curl -X POST http://192.168.1.5:8000/api/activities \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN" \
  -d '{
    "activity_type": "meeting",
    "title": "Test Activity",
    "description": "Test description",
    "location": {
      "lat": 17.385044,
      "lng": 78.486671,
      "address": "Test address"
    },
    "check_in_time": "2026-01-15T10:00:00",
    "organization_level": "district",
    "tags": ["test"]
  }'
```

### Step 3: Check Flutter Logs

The Flutter app now logs the request data. Check your console for:

```
I/flutter: Creating activity: Test Activity
I/flutter: Request data: {activity_type: meeting, title: Test Activity, ...}
```

This shows exactly what's being sent to the backend.

### Step 4: Check Backend Database Schema

Make sure your MongoDB activities collection expects these fields:

- `user_id` (ObjectId or int)
- `activity_type` (string)
- `title` (string)
- `description` (string)
- `location` (object with lat, lng, address)
- `check_in_time` (datetime)
- `organization_level` (string)
- `tags` (array of strings)
- `status` (string, defaults to "pending")
- `created_at`, `updated_at` (datetime)

## Common Fixes

### Fix 1: Add user_id from JWT Token

In your backend route:

```python
@router.post("/activities")
async def create_activity(
    activity: CreateActivityRequest,
    current_user: User = Depends(get_current_user),
):
    activity_dict = activity.dict()
    activity_dict["user_id"] = current_user.id  # Add user_id from token
    activity_dict["status"] = "pending"
    activity_dict["created_at"] = datetime.utcnow()
    activity_dict["updated_at"] = datetime.utcnow()
    # ... rest of code
```

### Fix 2: Handle DateTime Properly

```python
from datetime import datetime

# When receiving datetime from frontend
check_in_time = activity.check_in_time
if isinstance(check_in_time, str):
    check_in_time = datetime.fromisoformat(check_in_time.replace('Z', '+00:00'))
```

### Fix 3: Add Default Values

```python
activity_dict = {
    **activity.dict(),
    "user_id": current_user.id,
    "status": "pending",
    "verified_by": None,
    "verified_at": None,
    "media_files": [],
    "created_at": datetime.utcnow(),
    "updated_at": datetime.utcnow(),
}
```

### Fix 4: Check Authentication

Make sure JWT token is valid:

```python
from fastapi import HTTPException, status

async def get_current_user(token: str = Depends(oauth2_scheme)):
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        user_id = payload.get("sub")
        if user_id is None:
            raise HTTPException(status_code=401, detail="Invalid token")
        # ... get user from database
    except JWTError:
        raise HTTPException(status_code=401, detail="Invalid token")
```

## Flutter App Improvements

The app now has enhanced error logging. You'll see:

- Request data being sent
- Response data from server
- Status codes
- Detailed error messages

Check your Flutter console for lines like:

```
I/flutter: ⛔ Response data: {"detail": "Actual error message from backend"}
```

## Next Steps

1. **Check backend terminal** for Python stack trace
2. **Test with curl** to isolate Flutter vs backend issue
3. **Check MongoDB** is running and accessible
4. **Verify JWT token** is being sent correctly
5. **Review backend code** for missing user_id or status fields

Once you fix the backend issue, the Flutter app will work correctly!
