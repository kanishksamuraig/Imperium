# Running Hybrid Connect - Complete Guide

## ✅ Current Status

**Backend Server**: ✅ Running on port 5000  
**MongoDB**: ✅ Connected  
**Dependencies**: ✅ All installed  

---

## 🚀 How to Start the Application

### Method 1: Using the Helper Scripts (Recommended)

**Terminal 1 - Backend:**
```powershell
cd a:\appdev\mobile\backend
.\start-backend.ps1
```

**Terminal 2 - Mobile App:**
```powershell
cd a:\appdev\mobile
.\start-flutter.ps1
```

### Method 2: Manual Commands

**Terminal 1 - Backend:**
```powershell
cd a:\appdev\mobile\backend
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
node server.js
```

**Terminal 2 - Mobile App:**
```powershell
cd a:\appdev\mobile
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
flutter run -d chrome
```

---

## 🛑 How to Stop the Servers

### Stop Backend Server
Press `Ctrl + C` in the terminal running the backend

### Stop All Node Processes (if needed)
```powershell
Get-Process -Name node -ErrorAction SilentlyContinue | Stop-Process -Force
```

### Check What's Running on Port 5000
```powershell
netstat -ano | findstr :5000
```

---

## ⚠️ Common Issues & Solutions

### Issue 1: "EADDRINUSE: address already in use :::5000"

**Cause**: Another instance of the backend is already running on port 5000

**Solution A - Stop the existing process:**
```powershell
Get-Process -Name node -ErrorAction SilentlyContinue | Stop-Process -Force
```

**Solution B - Use a different port:**
Edit `backend/.env` and change:
```env
PORT=3000
```

### Issue 2: "node is not recognized" or "flutter is not recognized"

**Cause**: PATH not refreshed in current terminal

**Solution A - Refresh PATH:**
```powershell
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
```

**Solution B - Restart Terminal:**
Close and reopen your terminal window

**Solution C - Use the helper scripts:**
The `start-backend.ps1` and `start-flutter.ps1` scripts automatically refresh PATH

### Issue 3: MongoDB Connection Error

**Cause**: MongoDB is not running

**Solution A - Install MongoDB locally:**
1. Download from: https://www.mongodb.com/try/download/community
2. Install and start MongoDB service

**Solution B - Use MongoDB Atlas (Cloud):**
1. Create free account at: https://www.mongodb.com/cloud/atlas
2. Get connection string
3. Update `backend/.env`:
   ```env
   MONGODB_URI=mongodb+srv://username:password@cluster.mongodb.net/hybrid-connect
   ```

### Issue 4: Flutter Compilation Failed

**Cause**: Various reasons (dependency issues, cache problems)

**Solution:**
```powershell
cd a:\appdev\mobile
flutter clean
flutter pub get
flutter run -d chrome
```

---

## 📊 Verify Everything is Working

### Check Backend
Visit in browser: http://localhost:5000

Expected response:
```json
{
  "message": "Welcome to Hybrid Connect API",
  "version": "1.0.0",
  "status": "running"
}
```

### Check API Endpoints
- Auth: http://localhost:5000/api/auth
- Patients: http://localhost:5000/api/patients
- Symptoms: http://localhost:5000/api/symptoms
- Alerts: http://localhost:5000/api/alerts

### Check Flutter App
The app should open in Chrome browser automatically when you run `flutter run -d chrome`

---

## 🔧 Development Workflow

### 1. Start Development Session
```powershell
# Terminal 1 - Backend
cd a:\appdev\mobile\backend
.\start-backend.ps1

# Terminal 2 - Mobile App
cd a:\appdev\mobile
.\start-flutter.ps1
```

### 2. Make Changes
- Backend code changes: Server auto-restarts (if using nodemon)
- Flutter code changes: Hot reload automatically

### 3. Test Changes
- Backend: Use Postman or browser to test API endpoints
- Mobile: Changes reflect immediately in the running app

### 4. Stop Development Session
- Press `Ctrl + C` in both terminals

---

## 📝 Quick Reference Commands

### Backend Commands
```powershell
# Start server
node server.js

# Start with auto-reload (development)
npm run dev

# Check Node version
node --version

# Check npm version
npm --version

# Install new package
npm install package-name

# List installed packages
npm list --depth=0
```

### Flutter Commands
```powershell
# Run app in Chrome
flutter run -d chrome

# Run app on Android device/emulator
flutter run

# Check Flutter installation
flutter doctor

# Check Flutter version
flutter --version

# Clean build files
flutter clean

# Get dependencies
flutter pub get

# Update dependencies
flutter pub upgrade

# List available devices
flutter devices
```

---

## 🎯 Next Steps

1. ✅ Backend is running
2. ✅ Dependencies installed
3. ⏳ Start Flutter app with `.\start-flutter.ps1`
4. ⏳ Test the complete system
5. ⏳ Create test accounts (patient, nurse, doctor)
6. ⏳ Test symptom logging
7. ⏳ Test emergency alerts

---

## 📚 Additional Resources

- **Project Summary**: `PROJECT_SUMMARY.md`
- **Installation Guide**: `INSTALLATION_COMPLETE.md`
- **PATH Fix Guide**: `PATH_FIX.md`
- **Backend API Docs**: `backend/README.md`
- **Quick Start**: `QUICKSTART.md`

---

## 🆘 Need Help?

If you encounter any issues:

1. Check this guide first
2. Review the error message carefully
3. Try the solutions in the "Common Issues" section
4. Check the documentation files
5. Run `flutter doctor -v` for detailed diagnostics

---

**Happy Coding! 🚀**
