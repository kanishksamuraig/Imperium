const express = require('express');
const router = express.Router();
const SymptomLog = require('../models/SymptomLog');
const Patient = require('../models/Patient');
const { authMiddleware, authorize } = require('../middleware/auth');

// @route   POST /api/symptoms/log
// @desc    Log daily symptoms
// @access  Private (Patient only)
router.post('/log', authMiddleware, authorize('patient'), async (req, res) => {
  try {
    const { patientId, symptoms, severity, notes } = req.body;

    if (!patientId || !symptoms) {
      return res.status(400).json({
        success: false,
        message: 'Please provide patientId and symptoms'
      });
    }

    // Get patient to verify condition
    const patient = await Patient.findById(patientId);
    if (!patient) {
      return res.status(404).json({
        success: false,
        message: 'Patient not found'
      });
    }

    // Auto-flag critical symptoms based on condition
    let autoSeverity = severity || 'normal';
    let flagged = false;

    // --- Diabetes ---
    if (patient.condition === 'diabetes' && symptoms.bloodSugarLevel) {
      if (symptoms.bloodSugarLevel < 70 || symptoms.bloodSugarLevel > 250) {
        autoSeverity = 'critical'; flagged = true;
      } else if (symptoms.bloodSugarLevel < 90 || symptoms.bloodSugarLevel > 180) {
        autoSeverity = 'warning'; flagged = true;
      }
    }

    // --- Renal Failure ---
    if (patient.condition === 'renal_failure') {
      if (symptoms.swelling === 'severe') {
        autoSeverity = 'critical'; flagged = true;
      } else if (symptoms.swelling === 'moderate' || symptoms.fatigue === 'severe') {
        autoSeverity = 'warning'; flagged = true;
      }
    }

    // --- Thyroid ---
    if (patient.condition === 'thyroid' && symptoms.tshLevel != null) {
      const tsh = parseFloat(symptoms.tshLevel);
      if (!isNaN(tsh)) {
        if (tsh < 0.1 || tsh > 10) {
          autoSeverity = 'critical'; flagged = true;
        } else if (tsh < 0.4 || tsh > 4.0) {
          autoSeverity = 'warning'; flagged = true;
        }
      }
    }
    // Non-adherence to thyroid meds is always critical
    if (patient.condition === 'thyroid' && symptoms.medicationAdherence === false) {
      autoSeverity = 'critical'; flagged = true;
    }

    // --- TB ---
    if (patient.condition === 'tb') {
      if (symptoms.medicationAdherence === false) {
        autoSeverity = 'critical'; flagged = true;
      } else if (symptoms.coughFrequency === 'constant' || symptoms.nightSweats === true) {
        if (autoSeverity !== 'critical') { autoSeverity = 'warning'; flagged = true; }
      }
    }

    // --- Substance Abuse ---
    if (patient.condition === 'substance_abuse' && symptoms.cravingIntensity != null) {
      const craving = parseInt(symptoms.cravingIntensity);
      if (craving >= 7) {
        autoSeverity = 'critical'; flagged = true;
      } else if (craving >= 5) {
        if (autoSeverity !== 'critical') { autoSeverity = 'warning'; flagged = true; }
      }
    }


    // Create symptom log
    const symptomLog = new SymptomLog({
      patientId,
      condition: patient.condition,
      symptoms,
      severity: autoSeverity,
      notes,
      flaggedBySystem: flagged
    });

    await symptomLog.save();

    res.status(201).json({
      success: true,
      message: 'Symptoms logged successfully',
      data: symptomLog
    });
  } catch (error) {
    console.error('Symptom logging error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error during symptom logging'
    });
  }
});

// @route   GET /api/symptoms/patient/:patientId
// @desc    Get symptom history for a patient
// @access  Private
router.get('/patient/:patientId', authMiddleware, async (req, res) => {
  try {
    const { startDate, endDate, limit = 30 } = req.query;

    let query = { patientId: req.params.patientId };

    if (startDate || endDate) {
      query.date = {};
      if (startDate) query.date.$gte = new Date(startDate);
      if (endDate) query.date.$lte = new Date(endDate);
    }

    const symptoms = await SymptomLog.find(query)
      .sort({ date: -1 })
      .limit(parseInt(limit));

    res.json({
      success: true,
      count: symptoms.length,
      data: symptoms
    });
  } catch (error) {
    console.error('Get symptoms error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error'
    });
  }
});

// @route   GET /api/symptoms/flagged
// @desc    Get flagged symptoms for doctor review (only for assigned patients)
// @access  Private (Doctor/Nurse only)
router.get('/flagged', authMiddleware, authorize('doctor', 'nurse'), async (req, res) => {
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

    const flaggedSymptoms = await SymptomLog.find({
      flaggedBySystem: true,
      reviewedByDoctor: false,
      patientId: { $in: patientIds }
    })
      .populate({
        path: 'patientId',
        populate: {
          path: 'userId',
          select: 'name email phone'
        }
      })
      .sort({ date: -1 })
      .limit(50);

    res.json({
      success: true,
      count: flaggedSymptoms.length,
      data: flaggedSymptoms
    });
  } catch (error) {
    console.error('Get flagged symptoms error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error'
    });
  }
});

// @route   PUT /api/symptoms/:id/review
// @desc    Doctor reviews and adds notes to symptom log
// @access  Private (Doctor only)
router.put('/:id/review', authMiddleware, authorize('doctor'), async (req, res) => {
  try {
    const { doctorNotes } = req.body;

    const symptomLog = await SymptomLog.findByIdAndUpdate(
      req.params.id,
      {
        reviewedByDoctor: true,
        doctorNotes
      },
      { new: true }
    );

    if (!symptomLog) {
      return res.status(404).json({
        success: false,
        message: 'Symptom log not found'
      });
    }

    res.json({
      success: true,
      message: 'Symptom reviewed successfully',
      data: symptomLog
    });
  } catch (error) {
    console.error('Review symptom error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error'
    });
  }
});

module.exports = router;
