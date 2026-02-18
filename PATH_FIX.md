# Quick Fix - PATH Not Recognized Issue

## Problem
After installation, `node`, `npm`, and `flutter` commands are not recognized in your current terminal.

## Why This Happens
The PATH environment variable is only loaded when a terminal starts. Since you had the terminal open during installation, it doesn't have the updated PATH.

---

## ✅ SOLUTION - 3 Easy Options

### Option 1: Use the Startup Scripts (EASIEST) ⭐

I've created startup scripts that automatically refresh the PATH for you.

**For Backend:**
```powershell
cd a:\appdev\mobile\backend
.\start-backend.ps1
```

**For Mobile App:**
```powershell
cd a:\appdev\mobile
.\start-flutter.ps1
```

If you get an execution policy error, run this first:
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

---

### Option 2: Refresh PATH Manually

Run this command in your current terminal before using node/npm/flutter:

```powershell
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
```

Then you can use:
```powershell
node --version
npm --version
flutter --version
```

---

### Option 3: Restart Your Terminal (SIMPLEST)

1. **Close** all PowerShell/Terminal windows
2. **Open** a new PowerShell window
3. Navigate to your project:
   ```powershell
   cd a:\appdev\mobile\backend
   node server.js
   ```

---

## 🚀 Quick Start Commands

### After Fixing PATH:

**Start Backend:**
```powershell
cd a:\appdev\mobile\backend
node server.js
```

**Start Mobile App:**
```powershell
cd a:\appdev\mobile
flutter run -d chrome
```

---

## ✅ Verify Installation

Run these commands to verify everything is installed:

```powershell
# Refresh PATH first
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

# Check versions
node --version      # Should show: v24.13.1
npm --version       # Should show: 11.8.0
flutter --version   # Should show: Flutter 3.41.1
```

---

## 📝 Note

**Everything is installed correctly!** The issue is just that your current terminal session needs to be refreshed to see the new PATH entries.

Choose any of the 3 options above and you'll be good to go! 🎉
