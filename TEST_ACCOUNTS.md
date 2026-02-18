# Test Accounts

This document lists all the test accounts created by the seed script for development and testing purposes.

## Running the Seed Script

To populate the database with sample data, run:

```bash
cd backend
npm run seed
```

This will:
- Clear all existing data
- Create test accounts for doctors, nurses, and patients
- Add sample patient records with medical histories
- Create sample symptom logs with varying severity levels

## Test Accounts

### 👨‍⚕️ Doctor Account

- **Email:** `doctor@test.com`
- **Password:** `password123`
- **Name:** Dr. Sarah Johnson
- **Phone:** +1234567890
- **Patients:** 2 registered patients

### 👩‍⚕️ Nurse Accounts

#### Nurse 1
- **Email:** `nurse1@test.com`
- **Password:** `password123`
- **Name:** Nurse Emily Davis
- **Phone:** +1234567891
- **Assigned Patient:** John Smith (Diabetes)

#### Nurse 2
- **Email:** `nurse2@test.com`
- **Password:** `password123`
- **Name:** Nurse Michael Chen
- **Phone:** +1234567892
- **Assigned Patient:** Maria Garcia (Renal Failure)

### 🤒 Patient Accounts

#### Patient 1
- **Email:** `patient1@test.com`
- **Password:** `password123`
- **Name:** John Smith
- **Phone:** +1234567893
- **Condition:** Diabetes (Type 2)
- **Assigned Doctor:** Dr. Sarah Johnson
- **Assigned Nurse:** Nurse Emily Davis
- **Baseline Data:**
  - HbA1c: 7.5
  - Notes: Type 2 diabetes, diagnosed 2 years ago
- **Medical History:**
  - Allergies: Penicillin
  - Current Medications: Metformin 500mg, Glipizide 5mg
  - Previous Conditions: Hypertension
- **Symptom Logs:** 2 entries (1 warning, 1 normal)

#### Patient 2
- **Email:** `patient2@test.com`
- **Password:** `password123`
- **Name:** Maria Garcia
- **Phone:** +1234567894
- **Condition:** Renal Failure (Stage 3 CKD)
- **Assigned Doctor:** Dr. Sarah Johnson
- **Assigned Nurse:** Nurse Michael Chen
- **Baseline Data:**
  - Creatinine: 2.8
  - Notes: Stage 3 chronic kidney disease
- **Medical History:**
  - Allergies: None
  - Current Medications: Lisinopril 10mg, Furosemide 40mg
  - Previous Conditions: Diabetes, Hypertension
- **Symptom Logs:** 1 entry (critical)

## Dashboard Statistics

After running the seed script, the doctor dashboard will show:

- **Total Patients:** 2
- **Flagged Symptoms:** 2 (1 warning, 1 critical)
- **Total Symptom Logs:** 3

## Sample Data Details

### Symptom Logs Created

1. **John Smith - 2 days ago**
   - Blood Sugar: 180
   - Severity: Warning
   - Symptoms: Moderate thirst, frequent urination, mild fatigue

2. **John Smith - 1 day ago**
   - Blood Sugar: 145
   - Severity: Normal
   - Symptoms: Mild thirst, normal urination, no fatigue

3. **Maria Garcia - 3 hours ago**
   - Creatinine Level: 3.2
   - Severity: Critical
   - Symptoms: Moderate swelling, decreased urine output, severe fatigue
   - Notes: Experiencing increased swelling in legs

## Testing Scenarios

You can use these accounts to test:

1. **Doctor Login:** Login as doctor and view all patients
2. **Nurse Login:** Login as nurse and see only assigned patient
3. **Patient Login:** Login as patient and view own medical records
4. **Symptom Tracking:** View flagged symptoms and emergency alerts
5. **Patient Registration:** Register new patients as doctor
6. **Nurse Assignment:** Assign nurses to patients

## Resetting Data

To reset the database and start fresh, simply run the seed script again:

```bash
npm run seed
```

This will clear all existing data and recreate the test accounts.
