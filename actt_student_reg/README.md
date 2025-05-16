ACTT Student Registration App

Main Features

1.  Student Management
    a.  Register new students with personal details and course information
    b.  View student list with search functionality
    c.  Track course progress and completion
    d.  Identify graduated students based on course end dates
2.  Payment Tracking
    a.  Record student payments
    b.  Track outstanding balances
    c.  Create payment receipts
    d.  Generate payment reports
3.  Course Management
    a.  Add and update course details
    b.  Set course pricing
    c.  Manage course duration
4.  User Roles & Access
    a.  Admin: Full access to all features
    b.  Teacher: View student information and update course progress
    c.  Accounting/Sales: Handle payments and financial reports
5.  Data Sync & Backup
    a.  Work offline with local storage
    b.  Upload data to Google Sheets when online
    c.  Maintain local history (up to 3 entries) before syncing
    d.  Auto-sync option to prevent data loss
6.  Statistics & Reporting
    a.  Dashboard with key performance indicators
    b.  Financial summaries
    c.  Course enrollment statistics
    d.  Graduation rates

How To Use

1.  Setting Up Google Sheets
    a.  Create a Google Sheet with the following columns:
        i.    Student (ID)
        ii.   fullName
        iii.  dob (Date of Birth)
        iv.   gender
        v.    postalAddress
        vi.   phone
        vii.  emergencyPhone
        viii. educationLevel
        ix.   courseName
        x.    trainerName
        xi.   admissionDate
        xii.  completionDate
        xiii. duration
        xiv.  price
        xv.   amountPaid
        xvi.  remainingPrice
    b.  Create a Google Apps Script to connect with the app:
        i.    Go to Extensions > Apps Script in your Google Sheet
        ii.   Set up a script to handle GET and POST requests
        iii.  Deploy as a web app and copy the URL
        iv.   Update the URL in the app settings
2.  Basic Operations
    a.  Home Screen: Navigate to different sections of the app
    b.  Student List: View, search, and manage student records
    c.  Student Form: Add or edit student information
    d.  Payment Tracking: Record and monitor student payments
    e.  Statistics: View charts and reports about your students and courses
3.  Working Offline
    a.  The app automatically saves data locally
    b.  When you're back online, sync your data to Google Sheets
    c.  The app keeps track of local changes (up to 3 sets) before requiring upload
4.  Data Management
    a.  Settings: Access app configuration
    b.  Sync History: View local data history and upload status
    c.  Import/Export: Backup or restore your data

For Developers

Key Technical Components

1.  Local Storage: JSON files to store data offline
2.  Google Sheets API: Remote data storage and sharing
3.  User Authentication: Role-based access control
4.  Date Calculations: For determining graduation status
5.  Payment Processing: For tracking financial transactions

Adding New Features

1.  New Fields: Update both the local models and Google Sheet columns
2.  New Screens: Add to the navigation drawer and app routes
3.  New Reports: Modify the statistics service and dashboard components

Common Customizations

1.  Change the course types in `courses.json`
2.  Modify the payment calculation logic in `payment_calculator.dart`
3.  Update the user roles and permissions in `role_permissions.dart`

Troubleshooting

1.  Sync Issues: Check internet connection and Google Sheet permissions
2.  Missing Data: Look in Settings > Sync History for pending uploads
3.  Login Problems: Verify user credentials in the admin panel

Data Privacy

This app stores student data locally on the device and in Google Sheets. Make sure you:

1.  Have appropriate permissions to collect student information
2.  Secure access to your Google account
3.  Only grant app access to authorized personnel



lib/
├── main.dart
├── app.dart
├── screens/
│   ├── home.dart
│   ├── studentlist.dart
│   ├── setting.dart
│   ├── sync_history.dart
│   ├── student_form.dart
│   ├── statistics_dashboard.dart       # Dashboard for all statistics
│   ├── payment_tracking.dart           # For tracking outstanding payments
│   ├── payment_records.dart            # For recording and viewing payment history
│   ├── graduated_students.dart         # List of students who completed courses
│   ├── login.dart                      # Authentication screen
│   ├── admin_panel.dart                # Admin-specific controls and views
│   ├── teacher_dashboard.dart          # Teacher-specific view
│   ├── sales_dashboard.dart            # Sales/accounting specific view
│   ├── course_management.dart          # For adding/editing course information
│   └── user_management.dart            # For managing app users (admins, teachers, sales)
├── components/
│   ├── datasyc_manager.dart
│   ├── datasyc.dart
│   ├── nofticationtheme.dart
│   ├── student_card.dart
│   ├── app_drawer.dart
│   ├── payment_status_card.dart        # Component to display payment status
│   ├── statistics_chart.dart           # Reusable chart component for statistics
│   ├── payment_form.dart               # Form for recording payments
│   ├── course_form.dart                # Form for course management
│   ├── user_role_badge.dart            # Visual indicator of user role
│   └── graduated_badge.dart            # Visual indicator for graduated students
├── models/
│   ├── student.dart
│   ├── sync_event.dart
│   ├── payment.dart                    # Model for payment records
│   ├── statistics.dart                 # Model for statistics calculations
│   ├── course.dart                     # Model for course information
│   ├── user.dart                       # Model for app users with roles
│   └── app_role.dart                   # Enums and permissions for different roles
├── services/
│   ├── google_sheets_service.dart
│   ├── local_storage_service.dart
│   ├── statistics_service.dart         # For calculating different statistics
│   ├── auth_service.dart               # Authentication and user management
│   ├── course_service.dart             # Managing course data
│   └── graduation_service.dart         # Logic for determining graduated status
├── utils/
│   ├── constants.dart
│   ├── formatters.dart
│   ├── payment_calculator.dart         # Utility for payment calculations
│   ├── date_utils.dart                 # Utilities for working with dates
│   ├── role_permissions.dart           # Define what each role can access
│   └── graduation_calculator.dart      # Calculate graduation status based on dates
├── localstorage/
│   ├── students.json
│   ├── payments.json                   # Store payment records locally
│   ├── courses.json                    # Store course information locally
│   └── users.json                      # Store user accounts locally
└── images/
    └── acttlogo.png


    For more help, contact the developer: mujeeb