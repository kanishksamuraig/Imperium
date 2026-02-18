# Hybrid Connect - Backend API

Backend server for the Hybrid Connect healthcare monitoring system.

## Features

- **JWT Authentication** with role-based access control
- **Patient Registration** (Physical onboarding by doctors)
- **Symptom Logging** with disease-specific fields
- **Auto-flagging** of critical symptoms
- **Emergency SOS Alerts** with real-time notifications
- **MongoDB** for data persistence

## Tech Stack

- Node.js
- Express.js
- MongoDB (Mongoose)
- JWT for authentication
- Firebase Cloud Messaging (FCM) - optional

## Installation

1. Install dependencies:
```bash
cd backend
npm install
```

2. Create `.env` file:
```bash
cp .env.example .env
```

3. Update `.env` with your MongoDB URI and JWT secret:
```
PORT=5000
MONGODB_URI=mongodb+srv://your-connection-string
JWT_SECRET=your-secret-key
```

## Running the Server

### Development mode (with auto-reload):
```bash
npm run dev
```

### Production mode:
```bash
npm start
```

The server will run on `http://localhost:5000`

## API Endpoints

### Authentication
- `POST /api/auth/register` - Register new user
- `POST /api/auth/login` - Login user
- `POST /api/auth/fcm-token` - Update FCM token

### Patients
- `POST /api/patients/register` - Register patient (Doctor only)
- `GET /api/patients` - Get all patients
- `GET /api/patients/:id` - Get patient by ID
- `GET /api/patients/user/:userId` - Get patient by user ID
- `PUT /api/patients/:id` - Update patient

### Symptoms
- `POST /api/symptoms/log` - Log daily symptoms (Patient only)
- `GET /api/symptoms/patient/:patientId` - Get symptom history
- `GET /api/symptoms/flagged` - Get flagged symptoms (Doctor/Nurse)
- `PUT /api/symptoms/:id/review` - Review symptom (Doctor only)

### Emergency Alerts
- `POST /api/alerts/emergency` - Trigger SOS alert (Patient only)
- `GET /api/alerts/active` - Get active alerts (Nurse/Doctor)
- `GET /api/alerts/patient/:patientId` - Get alert history
- `PUT /api/alerts/:id/acknowledge` - Acknowledge alert
- `PUT /api/alerts/:id/resolve` - Resolve alert

## Database Schema

### User
```javascript
{
  name: String,
  email: String (unique),
  password: String (hashed),
  role: ['patient', 'nurse', 'doctor'],
  phone: String,
  fcmToken: String
}
```

### Patient
```javascript
{
  userId: ObjectId (ref: User),
  condition: ['diabetes', 'renal_failure', 'tb', 'thyroid', 'substance_abuse'],
  assignedDoctor: ObjectId (ref: User),
  assignedNurse: ObjectId (ref: User),
  baseline: {
    hba1c, creatinine, tbStage, tshLevel, rehabStage, notes
  },
  medicalHistory: {
    allergies, currentMedications, previousConditions
  }
}
```

### SymptomLog
```javascript
{
  patientId: ObjectId (ref: Patient),
  condition: String,
  symptoms: {
    // Disease-specific fields
    bloodSugarLevel, insulinDosage, dietAdherence,
    fluidIntake, swelling, bloodPressure, fatigue,
    coughFrequency, weight, nightSweats,
    cravingIntensity, moodRating, etc.
  },
  severity: ['normal', 'warning', 'critical'],
  flaggedBySystem: Boolean,
  reviewedByDoctor: Boolean,
  doctorNotes: String
}
```

### EmergencyAlert
```javascript
{
  patientId: ObjectId (ref: Patient),
  location: { latitude, longitude, address },
  status: ['active', 'acknowledged', 'resolved', 'cancelled'],
  responderId: ObjectId (ref: User),
  priority: ['low', 'medium', 'high', 'critical']
}
```

## Testing with Postman/Thunder Client

### 1. Register a Doctor
```
POST http://localhost:5000/api/auth/register
{
  "name": "Dr. Smith",
  "email": "doctor@test.com",
  "password": "password123",
  "role": "doctor",
  "phone": "1234567890"
}
```

### 2. Login
```
POST http://localhost:5000/api/auth/login
{
  "email": "doctor@test.com",
  "password": "password123"
}
```
Save the returned token for subsequent requests.

### 3. Register a Patient (use doctor token)
```
POST http://localhost:5000/api/patients/register
Headers: Authorization: Bearer <doctor-token>
{
  "userId": "<patient-user-id>",
  "condition": "diabetes",
  "baseline": {
    "hba1c": 7.5,
    "notes": "Type 2 diabetes, recently diagnosed"
  }
}
```

## Auto-Flagging Logic

The system automatically flags critical symptoms:

- **Diabetes**: Blood sugar < 70 or > 250 (critical), < 90 or > 180 (warning)
- **Renal Failure**: Severe swelling (critical)
- More conditions can be added in `routes/symptoms.js`

## License

MIT
