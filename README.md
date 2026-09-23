# 🏋️ Gym Management System

A modern Flutter + Firebase application for managing gym operations — staff, members, announcements, and role-based dashboards — built with clean architecture and production-ready patterns.

## 📖 Overview

Gym Management System is a mobile application designed for gym owners, receptionists, trainers, and members. It provides dedicated dashboards for each role, ensuring users only see features relevant to their responsibilities.

The app is built with a **feature-first architecture**, **MVVM pattern**, and **repository pattern**, making the codebase scalable and maintainable.

## 👥 User Roles

| Role | Responsibilities |
|------|------------------|
| **Admin / Owner** | Manage staff, oversee members, publish announcements |
| **Receptionist** | Create and manage member accounts |
| **Trainer** | Mark own attendance, manage diet plans for members |
| **Member** | View profile, membership status, and assigned diet plan |

## ✨ Features

### 🔐 Authentication

- Firebase Email/Password authentication
- Role-based routing after login via AuthGate
- Persistent session across app restarts
- Secure profile lookup using Firebase UID as Firestore document ID

### 🎛️ Admin Dashboard

- **Home** — Greeting, live stats (members, active, staff, new this month), latest announcement
- **Staff Management** — View all staff, search by name/ID/role, create receptionist and trainer accounts
- **Members** — View all members (in progress)
- **Announcements** — Create, update, and delete the current gym announcement
- **Profile** — Admin details and logout (in progress)

### 👔 Staff Management

- Create receptionist and trainer accounts
- Uses secondary Firebase App instance so the admin session is preserved during staff creation
- Firestore document ID equals Firebase Auth UID (industry standard)
- Auto-generated staff profile IDs (STF001, STF002, ...)
- Client-side search — instant filtering without extra Firestore reads

### 📢 Announcements

- Single active announcement (no history — cleaner UX)
- Paragraph-style content visible to all logged-in users
- Real-time refresh after create / edit / delete
- Dark themed card for visual emphasis

## 🛠️ Tech Stack

**Frontend**

- Flutter 3.32.5 (stable)
- Dart 3.8.1
- Provider (state management)

**Backend**

- Firebase Authentication
- Cloud Firestore
- Firebase Storage (planned)

**Architecture**

- Feature-first folder structure
- MVVM (Model – View – ViewModel)
- Repository pattern
- ChangeNotifier state management
- Secondary Firebase App for admin-preserving user creation

## 📁 Project Structure

lib/
├── core/
│   └── theme/
├── features/
│   ├── authentication/
│   ├── admin/
│   ├── announcements/
│   └── staff/
└── main.dart

Each feature follows the same internal structure:

- **model/** — Data classes (Firestore to Dart)
- **repository/** — Firebase operations only
- **viewmodel/** — State and business logic
- **view/** — UI screens and widgets

**Data flow:** View → ViewModel → Repository → Firebase → Repository → ViewModel → View

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (3.32.5 or later)
- Android Studio / VS Code
- Firebase project with Authentication and Firestore enabled

### Setup

1. Clone the repository

git clone https://github.com/Danyalkhan21555/gym-management-system.git
cd gym-management-system

2. Install dependencies

flutter pub get

3. Firebase Setup
   - Create a Firebase project
   - Enable Email/Password authentication
   - Create a Cloud Firestore database
   - Download google-services.json and place it in android/app/
   - Run flutterfire configure to regenerate firebase_options.dart

4. Create the first admin account
   - In Firebase Authentication, manually create an admin user
   - In Firestore, create a staff document with the Firebase Auth UID as the document ID and the following fields:
     - uid: Firebase Auth UID
     - profileId: STF001
     - name: Admin
     - role: admin
     - status: active

5. Run the app

flutter run

## 🔒 Security

- Firestore Security Rules enforce role-based access
- Only admins can create, update, or delete staff and announcements
- Staff can read only their own profile
- No plaintext passwords stored in Firestore
- Firebase Auth UID used as Firestore document ID (industry standard)
- Secondary Firebase App used to prevent admin logout during staff creation

## 🗺️ Roadmap

- [x] Firebase setup and Authentication
- [x] Role-based routing (AuthGate)
- [x] Admin dashboard with bottom navigation
- [x] Announcement CRUD
- [x] Staff list and search
- [x] Create staff (receptionist / trainer)
- [ ] Admin profile tab and logout
- [ ] Member management
- [ ] Membership plans and activation logic
- [ ] Trainer attendance
- [ ] Diet plans
- [ ] Receptionist dashboard
- [ ] Trainer dashboard
- [ ] Member dashboard
- [ ] Final Firestore security rules
- [ ] Screenshots and demo video

## 📸 Screenshots

Coming soon

## 🤝 Contributing

This is a personal learning project. Suggestions and feedback are welcome — feel free to open an issue.

## 📄 License

This project is licensed under the MIT License.

## 👨‍💻 Author

**Danyal Khan**

- GitHub: [@Danyalkhan21555](https://github.com/Danyalkhan21555)
- Email: md7428758@gmail.com

---

If you find this project useful, consider giving it a star!

Built with ❤️ using Flutter and Firebase.