# SCOUT-PMS

## Project Overview
Developing a political management system app with various modules covering real-time activity tracking, dynamic organization structure, notifications, and dashboard analytics.

## Core Features

### Activity Tracking and Updates
- Party activists log their ongoing activities via forms, location check-ins, or multimedia uploads.
- Admin and incharge roles can view live updates, filter by region/role, and verify submissions.
- Automated reminders for activists to submit periodic activity reports.

### Dynamic Organization Chart
- Support for multiple organizational structures (state, district, mandal, etc.) with hierarchy management.
- Real-time updating and viewing ability for admins; permissioned views for members.
- Option to link each org node to individual member profiles with activity summaries.

### Dashboard and Analytics
- Admin dashboard with stats: total members, recent activities, engagement level per unit, pending reports. (Stats can be customized to show different metrics based on the organization's needs)
- Filtering and drill-down by hierarchy, region, and activity type.
- Export and visualization tools for deeper data analysis.

### Notifications & Communications
- App push notifications, bulk/SMS fallback for non-app users.
- Segmentation for regional or topic-specific updates.
- Tracking who has seen each notification or alert.

### Member Profiles and Roles
- Profile management for all members: details, photos, posts, activation status.
- Support for multiple post types (nominated, elected, volunteer).
- Hierarchical role permissions, ensuring incharge access aligns with organization levels.

### Volunteer Coordination
- Assignments, event creation, attendance tracking, and performance scoring.

### Feedback and Grievance Redressal
- Members submit feedback or issues, which are tracked and resolved by admins.

### Security
- Role-based access control and authentication; encryption for sensitive member data.

### Content Management
- Admins can manage news, campaign media, event info, and announcement materials centrally.

## Technical Recommendations
- Backend: Python with FastAPI for server-side logic.
- Database: MongoDB for flexible data storage.
- Authentication: JWT for secure token-based authentication.
- Hosting: For now Localhost.
- Add Docker file for deployment.

## Integrations
- Optional SMS/Email services, mapping/location APIs for check-ins.
- Compliance: Ensure data privacy, opt-in consent for notifications, and reporting features.

## Example Workflow
- Activist submits activity update (e.g., meeting, social event) with location and photos.
- App syncs the update live; the relevant admin/incharge sees the update in dashboard and organization chart view.
- Dashboard auto-updates with new stats and triggers notifications to stakeholders.
- Organization chart autogenerates visual updates as personnel or structure changes are approved.