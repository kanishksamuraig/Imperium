const express = require('express');
const router = express.Router();
const EmergencyAlert = require('../models/EmergencyAlert');
const Patient = require('../models/Patient');
const User = require('../models/User');
const { authMiddleware, authorize } = require('../middleware/auth');

// @route   POST /api/alerts/emergency
// @desc    Trigger SOS emergency alert
// @access  Private (Patient only)
router.post('/emergency', authMiddleware, authorize('patient'), async (req, res) => {
  try {
    const { patientId, location, notes, priority } = req.body;

    if (!patientId) {
      return res.status(400).json({
        success: false,
        message: 'Please provide patientId'
      });
    }

    // Verify patient exists and is assigned to a doctor
    const patient = await Patient.findById(patientId)
      .populate('assignedDoctor')
      .populate('assignedNurse');

    if (!patient) {
      return res.status(404).json({
        success: false,
        message: 'Patient not found'
      });
    }

    // Create emergency alert
    const alert = new EmergencyAlert({
      patientId,
      location: location || {},
      notes,
      priority: priority || 'high',
      status: 'active'
    });

    await alert.save();

    // TODO: Send FCM notification to assigned doctor and nurse
    // This would be implemented with Firebase Admin SDK
    // if (patient.assignedDoctor?.fcmToken) sendFCMNotification(patient.assignedDoctor.fcmToken, alert);
    // if (patient.assignedNurse?.fcmToken) sendFCMNotification(patient.assignedNurse.fcmToken, alert);

    res.status(201).json({
      success: true,
      message: 'Emergency alert sent successfully',
      data: alert
    });
  } catch (error) {
    console.error('Emergency alert error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error during emergency alert'
    });
  }
});

// @route   GET /api/alerts/active
// @desc    Get active emergency alerts for the logged-in doctor/nurse
// @access  Private (Nurse/Doctor only)
router.get('/active', authMiddleware, authorize('nurse', 'doctor'), async (req, res) => {
  try {
    // Find patients assigned to this doctor/nurse
    let patientQuery = {};
    if (req.user.role === 'doctor') {
      patientQuery.assignedDoctor = req.user._id;
    } else if (req.user.role === 'nurse') {
      patientQuery.assignedNurse = req.user._id;
    }

    const assignedPatients = await Patient.find(patientQuery).select('_id');
    const patientIds = assignedPatients.map(p => p._id);

    const alerts = await EmergencyAlert.find({
      status: { $in: ['active', 'acknowledged'] },
      patientId: { $in: patientIds }
    })
      .populate({
        path: 'patientId',
        populate: {
          path: 'userId',
          select: 'name email phone'
        }
      })
      .populate('responderId', 'name email role')
      .sort({ timestamp: -1 });

    res.json({
      success: true,
      count: alerts.length,
      data: alerts
    });
  } catch (error) {
    console.error('Get active alerts error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error'
    });
  }
});

// @route   GET /api/alerts/patient/:patientId
// @desc    Get alert history for a patient
// @access  Private
router.get('/patient/:patientId', authMiddleware, async (req, res) => {
  try {
    const alerts = await EmergencyAlert.find({ patientId: req.params.patientId })
      .populate('responderId', 'name email role')
      .sort({ timestamp: -1 })
      .limit(20);

    res.json({
      success: true,
      count: alerts.length,
      data: alerts
    });
  } catch (error) {
    console.error('Get patient alerts error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error'
    });
  }
});

// @route   PUT /api/alerts/:id/acknowledge
// @desc    Acknowledge an emergency alert
// @access  Private (Nurse/Doctor only)
router.put('/:id/acknowledge', authMiddleware, authorize('nurse', 'doctor'), async (req, res) => {
  try {
    const alert = await EmergencyAlert.findByIdAndUpdate(
      req.params.id,
      {
        status: 'acknowledged',
        responderId: req.user._id,
        responseTime: new Date()
      },
      { new: true }
    );

    if (!alert) {
      return res.status(404).json({
        success: false,
        message: 'Alert not found'
      });
    }

    res.json({
      success: true,
      message: 'Alert acknowledged successfully',
      data: alert
    });
  } catch (error) {
    console.error('Acknowledge alert error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error'
    });
  }
});

// @route   PUT /api/alerts/:id/resolve
// @desc    Resolve an emergency alert
// @access  Private (Nurse/Doctor only)
router.put('/:id/resolve', authMiddleware, authorize('nurse', 'doctor'), async (req, res) => {
  try {
    const { notes } = req.body;

    // First fetch the existing alert to preserve existing notes if no new notes provided
    const existingAlert = await EmergencyAlert.findById(req.params.id);
    if (!existingAlert) {
      return res.status(404).json({
        success: false,
        message: 'Alert not found'
      });
    }

    const alert = await EmergencyAlert.findByIdAndUpdate(
      req.params.id,
      {
        status: 'resolved',
        resolutionTime: new Date(),
        notes: notes || existingAlert.notes
      },
      { new: true }
    );

    res.json({
      success: true,
      message: 'Alert resolved successfully',
      data: alert
    });
  } catch (error) {
    console.error('Resolve alert error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error'
    });
  }
});

module.exports = router;
