# 🔧 Patient Registration Troubleshooting

## Common Issues & Solutions

### Issue 1: "User already exists" Error

**Symptom**: Error message says email already registered

**Cause**: You're trying to register a patient with an email that's already in the system

**Solution**:
- Use a different email address
- Or check if the patient was already registered (go to "View All Patients")

---

### Issue 2: "Unauthorized" or "Token" Error

**Symptom**: Error about authentication or token

**Cause**: Doctor is not properly logged in or token expired

**Solution**:
1. Log out
2. Log back in as doctor
3. Try registering again

---

### Issue 3: Network Error

**Symptom**: "Network error" or "Connection refused"

**Cause**: Backend server is not running or not accessible

**Solution**:
1. Check if backend is running:
   ```powershell
   # In backend terminal, you should see:
   # Server running on port 5000
   ```

2. Test the endpoint manually:
   ```powershell
   # Test if backend is accessible
   Invoke-RestMethod -Uri "http://localhost:5000" -Method Get
   ```

3. If backend is not running, restart it:
   ```powershell
   cd a:\appdev\mobile\backend
   .\start-backend.ps1
   ```

---

### Issue 4: "Patient already registered" Error

**Symptom**: Error says patient profile already exists

**Cause**: The user account was created but patient profile creation failed, then you tried again

**Solution**:
The user account exists but not the patient profile. You have two options:

**Option A**: Use a different email for a new patient

**Option B**: Manually create the patient profile (advanced):
```powershell
# Get the userId first, then create patient profile
# This requires knowing the userId from the database
```

---

### Issue 5: Server Error 500

**Symptom**: "Server error during patient registration"

**Cause**: Backend error, possibly database issue

**Solution**:
1. Check backend terminal for error messages
2. Make sure MongoDB is running
3. Check backend logs for details

---

## 🧪 Test Registration Step-by-Step

### Step 1: Verify You're Logged In as Doctor
```
Email: doctor@test.com
Password: doctor123
```

### Step 2: Fill in Patient Details
```
Name: Test Patient
Email: testpatient1@test.com  (use unique email each time)
Password: test123
Phone: 1234567890
Condition: Diabetes
```

### Step 3: Click "Register Patient"
- Loading spinner should appear
- Wait for response

### Step 4: Check Result
- **Success**: Green snackbar "Patient registered successfully!"
- **Error**: Red snackbar with error message

---

## 🔍 Debugging Steps

### 1. Check Browser Console
1. Open Chrome DevTools (F12)
2. Go to Console tab
3. Try registering a patient
4. Look for error messages

### 2. Check Network Tab
1. Open Chrome DevTools (F12)
2. Go to Network tab
3. Try registering a patient
4. Look for failed requests (red)
5. Click on the failed request to see details

### 3. Check Backend Terminal
1. Look at the backend terminal
2. Try registering a patient
3. Check for error logs

---

## 📊 Expected API Flow

### Step 1: Register User Account
```
POST http://localhost:5000/api/auth/register
Body: {
  "name": "Test Patient",
  "email": "testpatient1@test.com",
  "password": "test123",
  "role": "patient",
  "phone": "1234567890"
}
Response: {
  "success": true,
  "data": {
    "user": { "_id": "userId123..." },
    "token": "..."
  }
}
```

### Step 2: Create Patient Profile
```
POST http://localhost:5000/api/patients/register
Headers: { "Authorization": "Bearer doctorToken" }
Body: {
  "userId": "userId123...",
  "condition": "diabetes",
  "assignedDoctor": "doctorId",
  "baseline": {},
  "medicalHistory": {...}
}
Response: {
  "success": true,
  "message": "Patient registered successfully",
  "data": { patient object }
}
```

---

## 🎯 Quick Test

Try registering with these exact details:

```
Name: John Smith
Email: johnsmith@test.com
Password: patient123
Phone: 5551234567
Condition: Diabetes
```

If this works, the system is fine. If it fails, note the exact error message.

---

## 💡 Common Mistakes

1. **Using same email twice** - Each patient needs unique email
2. **Not logged in as doctor** - Only doctors can register patients
3. **Backend not running** - Check terminal
4. **MongoDB not connected** - Check backend logs

---

## 🆘 Still Having Issues?

Please provide:

1. **Exact error message** from the red snackbar
2. **Browser console errors** (F12 → Console tab)
3. **Backend terminal output** when you try to register
4. **Patient details** you're trying to register (email, name, etc.)

This will help me identify the exact issue!
