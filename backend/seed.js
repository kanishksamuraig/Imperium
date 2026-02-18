require('dotenv').config();
const mongoose = require('mongoose');
const User = require('./models/User');
const Patient = require('./models/Patient');
const SymptomLog = require('./models/SymptomLog');
const connectDB = require('./config/db');

const seedData = async () => {
    try {
        // Connect to database
        await connectDB();

        console.log('🗑️  Clearing existing data...');
        await User.deleteMany({});
        await Patient.deleteMany({});
        await SymptomLog.deleteMany({});

        console.log('👨‍⚕️  Creating doctor account...');
        const doctor = await User.create({
            name: 'Dr. Sarah Johnson',
            email: 'doctor@test.com',
            password: 'password123',
            role: 'doctor',
            phone: '+1234567890'
        });

        console.log('👩‍⚕️  Creating nurse accounts...');
        const nurse1 = await User.create({
            name: 'Nurse Emily Davis',
            email: 'nurse1@test.com',
            password: 'password123',
            role: 'nurse',
            phone: '+1234567891'
        });

        const nurse2 = await User.create({
            name: 'Nurse Michael Chen',
            email: 'nurse2@test.com',
            password: 'password123',
            role: 'nurse',
            phone: '+1234567892'
        });

        console.log('🤒  Creating patient accounts...');
        const patient1User = await User.create({
            name: 'John Smith',
            email: 'patient1@test.com',
            password: 'password123',
            role: 'patient',
            phone: '+1234567893'
        });

        const patient2User = await User.create({
            name: 'Maria Garcia',
            email: 'patient2@test.com',
            password: 'password123',
            role: 'patient',
            phone: '+1234567894'
        });

        console.log('📋  Registering patients with medical records...');
        const patient1 = await Patient.create({
            userId: patient1User._id,
            condition: 'diabetes',
            assignedDoctor: doctor._id,
            assignedNurse: nurse1._id,
            baseline: {
                hba1c: 7.5,
                notes: 'Type 2 diabetes, diagnosed 2 years ago'
            },
            medicalHistory: {
                allergies: ['Penicillin'],
                currentMedications: ['Metformin 500mg', 'Glipizide 5mg'],
                previousConditions: ['Hypertension']
            }
        });

        const patient2 = await Patient.create({
            userId: patient2User._id,
            condition: 'renal_failure',
            assignedDoctor: doctor._id,
            assignedNurse: nurse2._id,
            baseline: {
                creatinine: 2.8,
                notes: 'Stage 3 chronic kidney disease'
            },
            medicalHistory: {
                allergies: [],
                currentMedications: ['Lisinopril 10mg', 'Furosemide 40mg'],
                previousConditions: ['Diabetes', 'Hypertension']
            }
        });

        console.log('📊  Creating sample symptom logs...');
        await SymptomLog.create({
            patientId: patient1._id,
            condition: 'diabetes',
            symptoms: {
                bloodSugarLevel: 180,
                dietAdherence: 'fair',
                fatigue: 'mild'
            },
            severity: 'warning',
            notes: 'Feeling a bit tired today',
            flaggedBySystem: true,
            createdAt: new Date(Date.now() - 2 * 24 * 60 * 60 * 1000) // 2 days ago
        });

        await SymptomLog.create({
            patientId: patient1._id,
            condition: 'diabetes',
            symptoms: {
                bloodSugarLevel: 145,
                dietAdherence: 'good',
                fatigue: 'none'
            },
            severity: 'normal',
            notes: 'Feeling better after adjusting diet',
            flaggedBySystem: false,
            createdAt: new Date(Date.now() - 1 * 24 * 60 * 60 * 1000) // 1 day ago
        });

        await SymptomLog.create({
            patientId: patient2._id,
            condition: 'renal_failure',
            symptoms: {
                fluidIntake: 1200,
                swelling: 'moderate',
                fatigue: 'severe',
                bloodPressure: '150/95'
            },
            severity: 'critical',
            notes: 'Experiencing increased swelling in legs',
            flaggedBySystem: true,
            createdAt: new Date(Date.now() - 3 * 60 * 60 * 1000) // 3 hours ago
        });

        console.log('\n✅ Database seeded successfully!\n');
        console.log('═══════════════════════════════════════════════════════');
        console.log('📝 TEST ACCOUNTS CREATED:');
        console.log('═══════════════════════════════════════════════════════');
        console.log('\n👨‍⚕️  DOCTOR ACCOUNT:');
        console.log('   Email: doctor@test.com');
        console.log('   Password: password123');
        console.log('   Name: Dr. Sarah Johnson');
        console.log('\n👩‍⚕️  NURSE ACCOUNTS:');
        console.log('   1. Email: nurse1@test.com');
        console.log('      Password: password123');
        console.log('      Name: Nurse Emily Davis');
        console.log('      Assigned to: John Smith (Diabetes)');
        console.log('\n   2. Email: nurse2@test.com');
        console.log('      Password: password123');
        console.log('      Name: Nurse Michael Chen');
        console.log('      Assigned to: Maria Garcia (Renal Failure)');
        console.log('\n🤒  PATIENT ACCOUNTS:');
        console.log('   1. Email: patient1@test.com');
        console.log('      Password: password123');
        console.log('      Name: John Smith');
        console.log('      Condition: Diabetes');
        console.log('      Assigned Nurse: Nurse Emily Davis');
        console.log('\n   2. Email: patient2@test.com');
        console.log('      Password: password123');
        console.log('      Name: Maria Garcia');
        console.log('      Condition: Renal Failure');
        console.log('      Assigned Nurse: Nurse Michael Chen');
        console.log('\n📊  STATS:');
        console.log('   Total Patients: 2');
        console.log('   Flagged Symptoms: 2 (1 warning, 1 critical)');
        console.log('   Total Symptom Logs: 3');
        console.log('═══════════════════════════════════════════════════════\n');

        process.exit(0);
    } catch (error) {
        console.error('❌ Error seeding database:', error);
        process.exit(1);
    }
};

seedData();
