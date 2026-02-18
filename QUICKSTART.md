# Hybrid Connect - Quick Start Guide

## 🚀 Quick Setup (5 Minutes)

### Step 1: Backend Setup

1. Open a terminal in the `backend` folder
2. Install dependencies:
   ```bash
   npm install
   ```

3. Create `.env` file (copy from `.env.example`):
   ```bash
   cp .env.example .env
   ```

4. **IMPORTANT**: Update `.env` with your MongoDB connection:
   ```
   MONGODB_URI=mongodb+srv://your-username:your-password@cluster.mongodb.net/hybrid-connect
   ```
   
   **Don't have MongoDB?** Get a free account at [MongoDB Atlas](https://www.mongodb.com/cloud/atlas/register)

5. Start the server:
   ```bash
   npm start
   ```
   
   You should see: `Server running on port 5000`

### Step 2: Mobile App Setup

1. Open a new terminal in the project root
2. Get Flutter dependencies:
   ```bash
   flutter pub get
   ```

3. **CRITICAL**: Update API endpoint in `lib/config/api_config.dart`:
   
   - **For Android Emulator**: `http://10.0.2.2:5000/api`
   - **For iOS Simulator**: `http://localhost:5000/api`
   - **For Physical Device**: `http://YOUR_COMPUTER_IP:5000/api`
     (Find your IP: Windows: `ipconfig`, Mac/Linux: `ifconfig`)

4. Run the app:
   ```bash
   flutter run
   ```

### Step 3: Test the App

1. **Register a Patient**:
   - Open the app
   - Click "Register"
   - Fill in details, select "Patient" role
   - Register

2. **Doctor Registers the Patient** (via API):
   - Use Postman/Thunder Client or the backend will auto-create a patient record
   - For demo, you can manually create a patient in MongoDB

3. **Log Symptoms**:
   - Login as patient
   - Click "Log Symptoms"
   - Fill disease-specific form
   - Submit

4. **Test Emergency SOS**:
   - Click the red SOS button
   - Confirm alert
   - Check backend logs

5. **Register a Nurse**:
   - Register with "Nurse" role
   - Login to see patient list and alerts

## 📱 Demo Flow for Hackathon Presentation

### Scenario 1: Diabetes Patient Monitoring
1. Show patient logging blood sugar (150 mg/dL) - Normal
2. Show patient logging blood sugar (280 mg/dL) - Auto-flagged as critical
3. Show nurse dashboard with flagged alert

### Scenario 2: Emergency Response
1. Patient hits SOS button
2. Nurse receives alert
3. Nurse acknowledges and resolves

### Scenario 3: Symptom History
1. Patient views symptom history
2. Show trend of improving/worsening condition
3. Show doctor's notes on reviewed symptoms

## 🔧 Troubleshooting

### Backend won't start
- **Error: MongoDB connection failed**
  - Check your `MONGODB_URI` in `.env`
  - Ensure MongoDB Atlas IP whitelist includes your IP (or use 0.0.0.0/0 for testing)

### Mobile app can't connect to backend
- **Error: Network error**
  - Check API endpoint in `lib/config/api_config.dart`
  - Ensure backend is running (`npm start`)
  - For physical device, use your computer's IP address
  - Disable firewall temporarily for testing

### Flutter dependencies error
- Run: `flutter clean && flutter pub get`

## 🎯 Key Features to Demonstrate

1. **Disease-Specific Forms** - Show different symptom forms for different conditions
2. **Auto-Flagging** - Log critical blood sugar to show automatic flagging
3. **Emergency SOS** - Demonstrate real-time alert system
4. **Role-Based Access** - Show patient vs nurse dashboards
5. **Symptom History** - Show longitudinal tracking

## 📊 MongoDB Atlas Setup (Free Tier)

1. Go to [mongodb.com/cloud/atlas/register](https://www.mongodb.com/cloud/atlas/register)
2. Create free account
3. Create a cluster (M0 Free tier)
4. Create database user (username/password)
5. Whitelist IP: `0.0.0.0/0` (for testing only!)
6. Get connection string: Click "Connect" → "Connect your application"
7. Copy connection string to `.env` file

## 🎨 Customization

### Add New Disease Condition
1. Add to `backend/models/Patient.js` enum
2. Add to `lib/models/patient.dart` enum
3. Create symptom form in `lib/screens/patient/symptom_logger.dart`
4. Add auto-flagging logic in `backend/routes/symptoms.js`

### Change Theme Colors
Edit `lib/main.dart`:
```dart
colorScheme: ColorScheme.fromSeed(
  seedColor: Colors.purple, // Change this
),
```

## 📞 Support

For issues or questions:
- Check README.md for detailed documentation
- Review API documentation in backend/README.md
- Check console logs for error messages

---

**Ready to present?** Make sure:
- ✅ Backend is running
- ✅ Mobile app is connected
- ✅ You have demo accounts ready
- ✅ You can demonstrate all key features
