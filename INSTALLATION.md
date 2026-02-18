# Installation Guide - Hybrid Connect

## Current Status

### ✅ What's Ready
- Backend code (15 files)
- Mobile app code (16+ files)
- Environment configuration
- Documentation

### ⏳ What's Installing
- **Backend dependencies** (npm install) - Running now
- **Flutter SDK** - Downloading now

---

## Backend Dependencies Installation

### Currently Running:
```bash
cd backend
npm install
```

### Dependencies Being Installed:
- express (^4.18.2) - Web framework
- mongoose (^8.0.0) - MongoDB ODM
- jsonwebtoken (^9.0.2) - JWT authentication
- bcryptjs (^2.4.3) - Password hashing
- cors (^2.8.5) - CORS middleware
- dotenv (^16.3.1) - Environment variables
- firebase-admin (^12.0.0) - Push notifications
- nodemon (^3.0.1) - Dev server (dev dependency)

### After Installation Completes:
1. Verify installation:
   ```bash
   cd backend
   npm list
   ```

2. Start the server:
   ```bash
   npm start
   ```

---

## Flutter Installation

### Option 1: Automatic (Currently Attempting)
Flutter SDK is being downloaded to your temp folder.

### Option 2: Manual Installation (Recommended)

1. **Download Flutter SDK**:
   - Go to: https://docs.flutter.dev/get-started/install/windows
   - Download: Flutter SDK (Stable channel)
   - Or direct link: https://storage.googleapis.com/flutter_infra_release/releases/stable/windows/flutter_windows_3.24.5-stable.zip

2. **Extract Flutter**:
   ```powershell
   # Extract to C:\src\flutter (recommended location)
   Expand-Archive -Path "flutter_windows_3.24.5-stable.zip" -DestinationPath "C:\src"
   ```

3. **Add to PATH**:
   ```powershell
   # Add Flutter to PATH (run as Administrator)
   [Environment]::SetEnvironmentVariable(
       "Path",
       [Environment]::GetEnvironmentVariable("Path", "User") + ";C:\src\flutter\bin",
       "User"
   )
   ```

   Or manually:
   - Open "Edit the system environment variables"
   - Click "Environment Variables"
   - Under "User variables", select "Path"
   - Click "Edit" → "New"
   - Add: `C:\src\flutter\bin`
   - Click OK

4. **Restart Terminal** (Important!)
   Close and reopen your terminal/PowerShell

5. **Verify Installation**:
   ```bash
   flutter doctor
   ```

6. **Accept Android Licenses** (if using Android):
   ```bash
   flutter doctor --android-licenses
   ```

---

## Flutter Dependencies Installation

Once Flutter is installed, install the mobile app dependencies:

```bash
cd c:/Users/PAUL NEHEMIAH/OneDrive/Desktop/mobile
flutter pub get
```

### Dependencies Being Installed:
- provider (^6.1.1) - State management
- http (^1.1.0) - HTTP client
- shared_preferences (^2.2.2) - Local storage
- firebase_core (^2.24.2) - Firebase core
- firebase_messaging (^14.7.9) - Push notifications
- geolocator (^10.1.0) - Location services
- intl (^0.18.1) - Internationalization
- fl_chart (^0.65.0) - Charts

---

## Verification Steps

### 1. Backend Verification
```bash
cd backend
npm start
```

Expected output:
```
✅ MongoDB Connected: localhost
🏥 Hybrid Connect API Server
Server running on port 5000
```

Test endpoints:
- http://localhost:5000 (Welcome message)
- http://localhost:5000/health (Health check)

### 2. Flutter Verification
```bash
flutter doctor
```

Expected output:
```
[✓] Flutter (Channel stable, 3.24.5)
[✓] Windows Version
[✓] Android toolchain (if installed)
[✓] Chrome (for web development)
[✓] Visual Studio (for Windows development)
```

### 3. Mobile App Verification
```bash
flutter pub get
flutter run
```

---

## Troubleshooting

### Backend Issues

**npm install fails**:
```bash
# Clear npm cache
npm cache clean --force

# Try again
npm install
```

**Port 5000 already in use**:
Edit `backend/.env`:
```
PORT=3000
```

### Flutter Issues

**Flutter not recognized**:
- Restart terminal after adding to PATH
- Verify PATH: `echo $env:Path` (PowerShell)
- Check Flutter location: `where flutter`

**Flutter doctor shows issues**:
```bash
# Accept Android licenses
flutter doctor --android-licenses

# Install missing components
flutter doctor
```

**pub get fails**:
```bash
# Clear Flutter cache
flutter clean
flutter pub cache repair
flutter pub get
```

---

## Quick Start After Installation

### Terminal 1 - Backend:
```bash
cd backend
npm start
```

### Terminal 2 - Mobile App:
```bash
flutter run
```

---

## Alternative: Use Pre-built APK (If Flutter Installation Fails)

If Flutter installation is problematic, you can:

1. **Build on another machine** with Flutter installed
2. **Use Android Studio** to build the APK
3. **Use online Flutter builders** (not recommended for production)

---

## What to Do While Waiting

1. **Set up MongoDB**:
   - Create MongoDB Atlas account
   - Get connection string
   - Update `backend/.env`

2. **Review Documentation**:
   - Read `README.md`
   - Check `QUICKSTART.md`
   - Review `PROJECT_SUMMARY.md`

3. **Prepare Test Data**:
   - Plan test scenarios
   - Prepare demo accounts
   - Create test symptom data

---

## Estimated Installation Times

- **Backend npm install**: 5-10 minutes (currently running)
- **Flutter SDK download**: 10-15 minutes (currently running)
- **Flutter pub get**: 2-3 minutes (after Flutter is installed)
- **Total**: ~20-30 minutes

---

## Next Steps After Installation

1. ✅ Verify backend is running
2. ✅ Verify Flutter is installed
3. ✅ Install mobile app dependencies
4. ✅ Configure API endpoint in Flutter app
5. ✅ Run mobile app
6. ✅ Test the complete system

---

## Need Help?

Check these files:
- `README.md` - Full documentation
- `QUICKSTART.md` - Quick setup
- `WALKTHROUGH.md` - Complete guide
- `backend/README.md` - API docs

---

**Current Status**: 
- ⏳ Backend dependencies installing...
- ⏳ Flutter SDK downloading...
- ✅ Project code ready
- ✅ Documentation complete

**Estimated time to completion**: 15-20 minutes
