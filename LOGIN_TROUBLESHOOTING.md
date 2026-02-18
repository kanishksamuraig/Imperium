# 🔍 Login Troubleshooting Guide

## ✅ Backend is Working!

I just tested the backend API and it's working perfectly:
```
✅ Backend running on port 5000
✅ Login API responding correctly
✅ Test accounts exist and work
```

---

## 🐛 Debugging Steps

### Step 1: Check Browser Console

1. **Open Chrome DevTools**:
   - Press `F12` or `Ctrl+Shift+I`
   - Click on the "Console" tab

2. **Look for errors**:
   - Red error messages
   - Network errors
   - CORS errors

3. **Check Network tab**:
   - Click "Network" tab
   - Try logging in
   - Look for the login request to `http://localhost:5000/api/auth/login`
   - Check if it's failing or succeeding

### Step 2: Try These Credentials

Make sure you're using the **correct** passwords:

```
Email: patient@test.com
Password: patient123
```

**NOT** `password123` - that was wrong!

The login screen should now show the correct credentials.

### Step 3: Check for Error Messages

After clicking "Login", look for:
- A red snackbar at the bottom of the screen
- Any error message displayed
- The loading spinner should appear briefly

### Step 4: Hot Reload the App

In the Flutter terminal, press:
```
r
```
This will hot reload the app with the updated credentials.

### Step 5: Hard Restart

If hot reload doesn't work, press:
```
R
```
This will do a full restart.

---

## 🔧 Common Issues

### Issue 1: CORS Error in Browser Console

**Symptom**: Error like "Access-Control-Allow-Origin"

**Solution**: The backend should already have CORS enabled, but if you see this:

1. Check `backend/server.js` has:
   ```javascript
   app.use(cors());
   ```

2. Restart the backend server

### Issue 2: Network Error / Connection Refused

**Symptom**: "Network error" or "Connection refused"

**Solution**:
1. Make sure backend is running (check terminal)
2. Visit http://localhost:5000 in browser - should show welcome message
3. Check if port 5000 is actually listening:
   ```powershell
   netstat -ano | findstr :5000
   ```

### Issue 3: Invalid Credentials (even with correct password)

**Symptom**: "Invalid credentials" error

**Possible causes**:
1. Extra spaces in email or password
2. Wrong email/password
3. Account doesn't exist

**Solution**:
1. Try copy-pasting from the demo credentials shown on login screen
2. Re-create accounts:
   ```powershell
   cd a:\appdev\mobile
   .\create-test-users.ps1
   ```

### Issue 4: App Stays on Login Screen (No Error)

**Symptom**: Click login, loading spinner appears, then nothing happens

**Possible causes**:
1. Navigation not working
2. Silent error in console
3. Patient data loading failing

**Solution**:
1. Check browser console for errors
2. Try logging in as a **nurse** instead:
   ```
   Email: nurse@test.com
   Password: nurse123
   ```
   Nurses don't need patient data, so they should navigate immediately

---

## 🧪 Test the API Directly

You can test if the backend is working by visiting these URLs in your browser:

1. **Backend Health Check**:
   ```
   http://localhost:5000
   ```
   Should show: Welcome message

2. **Test Login via PowerShell**:
   ```powershell
   Invoke-RestMethod -Uri "http://localhost:5000/api/auth/login" -Method Post -Body (@{email="patient@test.com"; password="patient123"} | ConvertTo-Json) -ContentType "application/json"
   ```
   Should return: success=True with a token

---

## 📊 What Should Happen

### Correct Login Flow:

1. **Enter credentials** → patient@test.com / patient123
2. **Click "Login"** → Loading spinner appears
3. **API call** → Request sent to backend
4. **Backend responds** → Returns token and user data
5. **App saves data** → Stores in SharedPreferences
6. **Navigation** → Redirects to Patient Dashboard
7. **Dashboard loads** → Shows patient information

### For Nurse Login:

1-5. Same as above
6. **Navigation** → Redirects to Nurse Dashboard
7. **Dashboard loads** → Shows assigned patients and alerts

---

## 🎯 Quick Test

Try this in order:

1. **Refresh the browser** (F5)
2. **Open DevTools** (F12)
3. **Go to Console tab**
4. **Enter credentials**: `nurse@test.com` / `nurse123`
5. **Click Login**
6. **Watch the console** for any errors
7. **Check Network tab** for the API call

---

## 📝 What to Tell Me

If it's still not working, please tell me:

1. **What you see in the browser console** (any red errors?)
2. **What happens when you click login** (loading spinner? error message?)
3. **Which account you're trying** (patient, nurse, or doctor?)
4. **Any error messages** shown in the app

---

## ✅ Verified Working

I've confirmed:
- ✅ Backend API is responding
- ✅ Login endpoint works
- ✅ Test accounts exist
- ✅ Credentials are correct
- ✅ Token is being generated

The issue is likely in the Flutter app's navigation or error handling. Check the browser console!

---

**The backend is working perfectly. The issue is in the frontend. Check the browser console for clues!** 🔍
