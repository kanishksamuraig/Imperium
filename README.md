# Hybrid Connect - Healthcare Monitoring System

A comprehensive mobile healthcare monitoring application for chronic disease patients, built with Flutter and Node.js.

## 🎯 Problem Statement

Patients with chronic conditions (Diabetes, Renal Failure, TB, Thyroid, Substance Abuse) require continuous monitoring. However, constant physical hospital visits:
- Expose vulnerable patients to infections
- Overwhelm doctors with routine check-ups
- Create gaps in health data between appointments

## 💡 Solution: "Physical-First, Digital-Follow-up"

**Hybrid Connect** implements a three-phase workflow:

1. **Physical Onboarding**: Patient visits doctor for initial diagnosis and registration
2. **Remote Monitoring**: Patient logs daily symptoms via mobile app
3. **Doctor Triage**: Doctor reviews data remotely, prescribes tests or adjusts medication

## 🏗️ Architecture

```
┌─────────────────────────────────────────┐
│     Flutter Mobile App (Patient/Nurse)  │
│     - Symptom Logging                   │
│     - Emergency SOS                     │
│     - History Tracking                  │
└──────────────┬──────────────────────────┘
               │ REST API (JWT Auth)
┌──────────────▼──────────────────────────┐
│     Node.js + Express Backend           │
│     - Authentication                    │
│     - Patient Management                │
│     - Symptom Auto-Flagging             │
│     - Emergency Alerts                  │
└──────────────┬──────────────────────────┘
               │
┌──────────────▼──────────────────────────┐
│     MongoDB Atlas                       │
│     - User Data                         │
│     - Patient Records                   │
│     - Symptom Logs                      │
│     - Emergency Alerts                  │
└─────────────────────────────────────────┘
```

## 📱 Features

### For Patients
- ✅ Disease-specific symptom logging (Diabetes, Renal, TB, etc.)
- ✅ View symptom history and trends
- ✅ Emergency SOS button
- ✅ Doctor feedback on flagged symptoms

### For Nurses
- ✅ View assigned patients
- ✅ Monitor active emergency alerts
- ✅ Acknowledge and resolve alerts
- ✅ Emergency SOS button

### Backend
- ✅ JWT authentication with role-based access
- ✅ Auto-flagging of critical symptoms
- ✅ RESTful API design
- ✅ MongoDB data persistence

## 🚀 Getting Started

### Prerequisites
- **Flutter SDK** (3.0.0 or higher)
- **Node.js** (v16 or higher)
- **MongoDB** (Atlas account or local installation)

### Backend Setup

1. Navigate to backend directory:
```bash
cd backend
```

2. Install dependencies:
```bash
npm install
```

3. Create `.env` file:
```bash
cp .env.example .env
```

4. Update `.env` with your MongoDB URI:
```
PORT=5000
MONGODB_URI=mongodb+srv://your-connection-string
JWT_SECRET=your-secret-key-here
```

5. Start the server:
```bash
npm start
```

The API will run on `http://localhost:5000`

### Mobile App Setup

1. Install Flutter dependencies:
```bash
flutter pub get
```

2. Update API endpoint in `lib/config/api_config.dart`:
```dart
// For Android emulator
static const String baseUrl = 'http://10.0.2.2:5000/api';

// For iOS simulator
static const String baseUrl = 'http://localhost:5000/api';

// For physical device (use your computer's IP)
static const String baseUrl = 'http://192.168.x.x:5000/api';
```

3. Run the app:
```bash
flutter run
```

## 📊 Tech Stack

### Mobile App
- **Flutter** - Cross-platform UI framework
- **Provider** - State management
- **HTTP** - API communication
- **SharedPreferences** - Local storage

### Backend
- **Node.js** - Runtime environment
- **Express.js** - Web framework
- **MongoDB** - NoSQL database
- **Mongoose** - ODM
- **JWT** - Authentication
- **bcryptjs** - Password hashing

## 🔐 Demo Accounts

After setting up the backend, you can create test accounts or use:

```
Patient: patient@test.com / password123
Nurse: nurse@test.com / password123
```

## 📖 API Documentation

### Authentication
- `POST /api/auth/register` - Register new user
- `POST /api/auth/login` - Login user

### Patients
- `GET /api/patients` - Get all patients (Doctor/Nurse only)
- `GET /api/patients/user/:userId` - Get patient by user ID
- `POST /api/patients/register` - Register patient (Doctor only)

### Symptoms
- `POST /api/symptoms/log` - Log daily symptoms (Patient only)
- `GET /api/symptoms/patient/:patientId` - Get symptom history
- `GET /api/symptoms/flagged` - Get flagged symptoms (Doctor/Nurse)

### Emergency Alerts
- `POST /api/alerts/emergency` - Trigger SOS alert (Patient only)
- `GET /api/alerts/active` - Get active alerts (Nurse/Doctor)
- `PUT /api/alerts/:id/acknowledge` - Acknowledge alert
- `PUT /api/alerts/:id/resolve` - Resolve alert

## 🎨 Disease-Specific Symptom Forms

### Diabetes
- Blood sugar level (mg/dL)
- Insulin dosage
- Diet adherence

### Renal Failure
- Fluid intake (ml)
- Swelling level
- Blood pressure
- Fatigue level

### Tuberculosis (TB)
- Cough frequency
- Weight
- Night sweats
- Medication adherence

### Substance Abuse Rehabilitation
- Craving intensity (0-10)
- Mood rating (0-10)
- Support group attendance

## 🚨 Auto-Flagging Logic

The system automatically flags critical symptoms:

- **Diabetes**: Blood sugar < 70 or > 250 (critical), < 90 or > 180 (warning)
- **Renal Failure**: Severe swelling (critical)
- More conditions can be customized in backend

## 📁 Project Structure

```
mobile/
├── backend/                 # Node.js backend
│   ├── config/             # Database configuration
│   ├── models/             # Mongoose models
│   ├── routes/             # API routes
│   ├── middleware/         # Auth middleware
│   └── server.js           # Entry point
│
├── lib/                    # Flutter app
│   ├── config/             # API configuration
│   ├── models/             # Data models
│   ├── services/           # API & Auth services
│   ├── providers/          # State management
│   ├── screens/            # UI screens
│   │   ├── auth/           # Login/Register
│   │   ├── patient/        # Patient dashboard
│   │   └── nurse/          # Nurse dashboard
│   ├── widgets/            # Reusable widgets
│   └── main.dart           # App entry point
│
└── README.md
```

## 🎯 Hackathon Highlights

1. **Real-World Problem**: Addresses actual healthcare inefficiencies
2. **Complete Solution**: Full-stack implementation with backend + mobile
3. **Smart Features**: Auto-flagging, disease-specific forms, emergency alerts
4. **Scalable Architecture**: RESTful API, JWT auth, role-based access
5. **Modern Tech Stack**: Flutter, Node.js, MongoDB

## 🔮 Future Enhancements

- [ ] Firebase Cloud Messaging for real-time push notifications
- [ ] Data visualization with charts (symptom trends)
- [ ] React web dashboard for doctors
- [ ] Telemedicine video calls
- [ ] Prescription management
- [ ] Appointment scheduling
- [ ] Multi-language support

## 📄 License

MIT License - feel free to use this project for learning or hackathons!

## 👥 Contributors

Built for healthcare innovation and chronic disease management.

---

**Note**: This is a prototype for demonstration purposes. For production use, implement additional security measures, HIPAA compliance, and proper medical data handling protocols.
