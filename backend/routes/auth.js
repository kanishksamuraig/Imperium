const express = require('express');
const router = express.Router();
const jwt = require('jsonwebtoken');
const User = require('../models/User');
const Patient = require('../models/Patient');

// @route   POST /api/auth/register
// @desc    Register a new user; if patient, auto-create Patient record and assign to a doctor
// @access  Public
router.post('/register', async (req, res) => {
  try {
    const { name, email, password, role, phone, condition } = req.body;

    // Validation
    if (!name || !email || !password || !role) {
      return res.status(400).json({
        success: false,
        message: 'Please provide all required fields'
      });
    }

    // Patients must provide a condition
    if (role === 'patient' && !condition) {
      return res.status(400).json({
        success: false,
        message: 'Please provide your medical condition'
      });
    }

    // Check if user already exists
    const existingUser = await User.findOne({ email });
    if (existingUser) {
      return res.status(400).json({
        success: false,
        message: 'User with this email already exists'
      });
    }

    // Create user
    const user = new User({
      name,
      email,
      password,
      role,
      phone
    });

    await user.save();

    // If registering as a patient, auto-create Patient record and assign to a doctor
    if (role === 'patient') {
      // Find the doctor with the fewest assigned patients (load balancing)
      const doctors = await User.find({ role: 'doctor', isActive: true });

      let assignedDoctor = null;

      if (doctors.length > 0) {
        // Count patients per doctor and pick the one with fewest
        const patientCounts = await Promise.all(
          doctors.map(async (doc) => {
            const count = await Patient.countDocuments({ assignedDoctor: doc._id });
            return { doctor: doc, count };
          })
        );
        patientCounts.sort((a, b) => a.count - b.count);
        assignedDoctor = patientCounts[0].doctor._id;
      }

      if (!assignedDoctor) {
        // No doctor available — still create the patient record without a doctor
        // (assignedDoctor is required in schema, so we skip patient record creation
        //  and return an error to inform the admin)
        console.warn('No doctors available to assign to new patient:', user._id);
        // We still complete registration but warn
      } else {
        const patient = new Patient({
          userId: user._id,
          condition,
          assignedDoctor,
          baseline: {},
          medicalHistory: {}
        });
        await patient.save();
      }
    }

    // Generate JWT
    const token = jwt.sign(
      { userId: user._id, role: user.role },
      process.env.JWT_SECRET || 'default_secret_key',
      { expiresIn: '30d' }
    );

    res.status(201).json({
      success: true,
      message: 'User registered successfully',
      data: {
        token,
        user: {
          id: user._id,
          name: user.name,
          email: user.email,
          role: user.role,
          phone: user.phone
        }
      }
    });
  } catch (error) {
    console.error('Registration error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error during registration'
    });
  }
});

// @route   POST /api/auth/login
// @desc    Login user
// @access  Public
router.post('/login', async (req, res) => {
  try {
    const { email, password } = req.body;

    // Validation
    if (!email || !password) {
      return res.status(400).json({
        success: false,
        message: 'Please provide email and password'
      });
    }

    // Find user
    const user = await User.findOne({ email });
    if (!user) {
      return res.status(401).json({
        success: false,
        message: 'Invalid credentials'
      });
    }

    // Check password
    const isMatch = await user.comparePassword(password);
    if (!isMatch) {
      return res.status(401).json({
        success: false,
        message: 'Invalid credentials'
      });
    }

    // Generate JWT
    const token = jwt.sign(
      { userId: user._id, role: user.role },
      process.env.JWT_SECRET || 'default_secret_key',
      { expiresIn: '30d' }
    );

    res.json({
      success: true,
      message: 'Login successful',
      data: {
        token,
        user: {
          id: user._id,
          name: user.name,
          email: user.email,
          role: user.role,
          phone: user.phone
        }
      }
    });
  } catch (error) {
    console.error('Login error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error during login'
    });
  }
});

// @route   POST /api/auth/fcm-token
// @desc    Update FCM token for push notifications
// @access  Private
router.post('/fcm-token', async (req, res) => {
  try {
    const { fcmToken } = req.body;
    const userId = req.user.id;

    await User.findByIdAndUpdate(userId, { fcmToken });

    res.json({
      success: true,
      message: 'FCM token updated successfully'
    });
  } catch (error) {
    console.error('FCM token update error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error'
    });
  }
});

module.exports = router;
