const express = require('express');
const router = express.Router();
const Patient = require('../models/Patient');
const User = require('../models/User');
const { authMiddleware, authorize } = require('../middleware/auth');

// @route   GET /api/patients/:id
// @desc    Get patient details
// @access  Private
router.get('/:id', authMiddleware, async (req, res) => {
  try {
    const patient = await Patient.findById(req.params.id)
      .populate('userId', 'name email phone')
      .populate('assignedDoctor', 'name email')
      .populate('assignedNurse', 'name email phone');

    if (!patient) {
      return res.status(404).json({
        success: false,
        message: 'Patient not found'
      });
    }

    res.json({
      success: true,
      data: patient
    });
  } catch (error) {
    console.error('Get patient error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error'
    });
  }
});

// @route   GET /api/patients/user/:userId
// @desc    Get patient by user ID
// @access  Private
router.get('/user/:userId', authMiddleware, async (req, res) => {
  try {
    const patient = await Patient.findOne({ userId: req.params.userId })
      .populate('userId', 'name email phone')
      .populate('assignedDoctor', 'name email phone')
      .populate('assignedNurse', 'name email phone');

    if (!patient) {
      return res.status(404).json({
        success: false,
        message: 'Patient not found'
      });
    }

    res.json({
      success: true,
      data: patient
    });
  } catch (error) {
    console.error('Get patient by user error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error'
    });
  }
});

// @route   GET /api/patients
// @desc    Get all patients (for doctors/nurses)
// @access  Private (Doctor/Nurse only)
router.get('/', authMiddleware, authorize('doctor', 'nurse'), async (req, res) => {
  try {
    let query = {};

    // If nurse, only show assigned patients
    if (req.user.role === 'nurse') {
      query.assignedNurse = req.user._id;
    }
    // If doctor, show their patients
    else if (req.user.role === 'doctor') {
      query.assignedDoctor = req.user._id;
    }

    const patients = await Patient.find(query)
      .populate('userId', 'name email phone')
      .populate('assignedDoctor', 'name email')
      .populate('assignedNurse', 'name email phone')
      .sort({ createdAt: -1 });

    res.json({
      success: true,
      count: patients.length,
      data: patients
    });
  } catch (error) {
    console.error('Get patients error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error'
    });
  }
});

// @route   PUT /api/patients/:id
// @desc    Update patient details
// @access  Private (Doctor only)
router.put('/:id', authMiddleware, authorize('doctor'), async (req, res) => {
  try {
    const patient = await Patient.findByIdAndUpdate(
      req.params.id,
      req.body,
      { new: true, runValidators: true }
    );

    if (!patient) {
      return res.status(404).json({
        success: false,
        message: 'Patient not found'
      });
    }

    res.json({
      success: true,
      message: 'Patient updated successfully',
      data: patient
    });
  } catch (error) {
    console.error('Update patient error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error'
    });
  }
});

module.exports = router;
