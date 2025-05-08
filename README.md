# University Management System

## Project Overview

This University Management System is a comprehensive Flutter application designed to streamline academic processes for students, instructors, and administrators. The application connects to Firebase Firestore for data storage and management, providing a real-time, cloud-based solution for university operations.

## Key Features

### For Students
- **Course Registration**: Browse and register for available courses
- **Attendance Tracking**: View attendance records for enrolled courses
- **Grade Viewing**: Access approved course grades and GPA calculations
- **Exam Schedule**: View upcoming exams with locations and times
- **Payment Management**: Make payments and view financial status
- **Support & Help Desk**: Submit support tickets and access FAQs

### For Instructors
- **Course Management**: View and manage assigned courses
- **Attendance Recording**: Take and edit attendance for classes
- **Grade Management**: Record, edit, and submit student grades for approval
- **Results Submission**: Submit course results for administrative approval
- **Schedule Viewing**: Access teaching schedule and classroom information

### For Administrators
- **Student Management**: Add, edit, and manage student records
- **Instructor Management**: Add, edit, and manage instructor profiles
- **Course Administration**: Create and manage course offerings
- **Results Approval**: Review and approve/reject submitted grades
- **Announcement Management**: Create and publish announcements
- **Support Ticket Management**: Handle student and instructor support requests

## Technical Architecture

### Frontend
- **Framework**: Flutter for cross-platform mobile development
- **State Management**: Stateful widgets with setState for UI updates
- **Navigation**: Tab-based navigation with context-based routing
- **UI Components**: Custom widgets for consistent design language

### Backend
- **Database**: Firebase Firestore for NoSQL document storage
- **Authentication**: Firebase Authentication for secure user access
- **Storage**: Firebase Storage for document and image storage
- **Cloud Functions**: For complex backend operations (future implementation)

### Data Models
- **User Models**: Student, Instructor, and Admin profiles
- **Academic Models**: Courses, Registrations, Attendance, and Results
- **Support Models**: Tickets, Announcements, and Payments

## Database Structure

### Collections
- **students**: Student profiles and academic information
- **instructors**: Instructor profiles and teaching assignments
- **admins**: Administrative user accounts
- **courses**: Course details, schedules, and instructor assignments
- **courseRegistrations**: Student course enrollments
- **attendance**: Student attendance records
- **studentResults**: Course grades and academic performance
- **announcements**: System-wide and targeted announcements
- **supportTickets**: Help requests and their resolution status
- **payments**: Student payment records and financial transactions

## Key Workflows

### Grade Management Workflow
1. Instructors enter grades for students in their courses
2. Instructors submit grades for administrative approval
3. Administrators review submitted grades
4. Administrators approve or reject grades with feedback
5. Approved grades become visible to students
6. Grade data is used to calculate student GPA and academic standing

### Attendance Management Workflow
1. Instructors record attendance for each class session
2. Students can view their attendance records
3. Attendance data is analyzed for reporting and intervention

### Course Registration Workflow
1. Administrators create and publish course offerings
2. Students browse available courses
3. Students register for courses within credit limits
4. Registration data populates class rosters for instructors

## Implementation Details

### Authentication System
- Role-based access control (Student, Instructor, Admin)
- Secure login with email/password
- Session management with token-based authentication

### Real-time Updates
- Firestore listeners for immediate UI updates
- Optimistic UI updates for responsive user experience

### Offline Capability
- Data caching for offline access to critical information
- Synchronization when connection is restored

## Project Structure

```
lib/
├── main.dart                  # Application entry point
├── models/                    # Data models
│   ├── firestore_models.dart  # Firestore data models
│   └── ...
├── pages/                     # UI screens
│   ├── admin_home.dart        # Admin dashboard
│   ├── instructor_home.dart   # Instructor dashboard
│   ├── student_home.dart      # Student dashboard
│   └── ...
├── services/                  # Business logic and API services
│   ├── firestore_service.dart # Firebase interactions
│   └── ...
└── widgets/                   # Reusable UI components
    └── ...
```

## Future Enhancements

### Planned Features
- **Advanced Analytics**: Dashboards for academic performance trends
- **Mobile Notifications**: Push notifications for important updates
- **Calendar Integration**: Sync academic events with device calendars
- **Document Management**: Upload and manage academic documents
- **Chat System**: Direct messaging between users
- **Biometric Authentication**: Fingerprint and face recognition login

### Technical Improvements
- **State Management Upgrade**: Implement Provider or Bloc pattern
- **Performance Optimization**: Implement pagination and lazy loading
- **Testing Coverage**: Expand unit and integration test coverage
- **Accessibility Enhancements**: Improve screen reader support and keyboard navigation

## Installation and Setup

### Prerequisites
- Flutter SDK (2.0 or higher)
- Dart SDK (2.12 or higher)
- Firebase project with Firestore enabled
- Android Studio or VS Code with Flutter extensions

### Setup Steps
1. Clone the repository
2. Run `flutter pub get` to install dependencies
3. Configure Firebase project settings
4. Update `google-services.json` and `GoogleService-Info.plist` files
5. Run `flutter run` to launch the application

## Firebase Configuration

### Firestore Rules
```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Allow admin access to all documents
    match /{document=**} {
      allow read, write: if request.auth != null &&
        exists(/databases/$(database)/documents/admins/$(request.auth.uid));
    }

    // Student access rules
    match /students/{studentId} {
      allow read: if request.auth != null && request.auth.uid == studentId;
    }

    // Course access rules
    match /courses/{courseId} {
      allow read: if request.auth != null;
    }

    // Results access rules
    match /studentResults/{resultId} {
      allow read: if request.auth != null &&
        (resultId.split('_')[0] == request.auth.uid ||
         exists(/databases/$(database)/documents/instructors/$(request.auth.uid)));
    }
  }
}
```

## Contact
For support or inquiries, please contact the development team.
