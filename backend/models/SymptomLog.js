const mongoose = require('mongoose');

const symptomLogSchema = new mongoose.Schema({
  patientId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Patient',
    required: true
  },
  date: {
    type: Date,
    default: Date.now
  },
  condition: {
    type: String,
    required: true
  },
  symptoms: {
    // Diabetes
    bloodSugarLevel: Number,
    insulinDosage: Number,
    dietAdherence: {
      type: String,
      enum: ['excellent', 'good', 'fair', 'poor']
    },

    // Renal Failure
    fluidIntake: Number,      // in ml
    swelling: {
      type: String,
      enum: ['none', 'mild', 'moderate', 'severe']
    },
    bloodPressure: String,    // e.g., "120/80"
    fatigue: {
      type: String,
      enum: ['none', 'mild', 'moderate', 'severe']
    },

    // TB
    coughFrequency: {
      type: String,
      enum: ['none', 'occasional', 'frequent', 'constant']
    },
    weight: Number,
    nightSweats: Boolean,
    medicationAdherence: Boolean,

    // Thyroid
    tshLevel: Number,         // mIU/L — normal range: 0.4–4.0
    energyLevel: {
      type: String,
      enum: ['very_low', 'low', 'normal', 'high']
    },
    heartRate: Number,

    // Substance Abuse Rehab
    cravingIntensity: {
      type: Number,
      min: 0,
      max: 10
    },
    moodRating: {
      type: Number,
      min: 0,
      max: 10
    },
    withdrawalSymptoms: [String],
    supportGroupAttendance: Boolean
  },
  severity: {
    type: String,
    enum: ['normal', 'warning', 'critical'],
    default: 'normal'
  },
  notes: {
    type: String,
    maxlength: 500
  },
  flaggedBySystem: {
    type: Boolean,
    default: false
  },
  reviewedByDoctor: {
    type: Boolean,
    default: false
  },
  doctorNotes: {
    type: String,
    default: ''
  }
}, {
  timestamps: true
});

// Index for efficient queries
symptomLogSchema.index({ patientId: 1, date: -1 });

module.exports = mongoose.model('SymptomLog', symptomLogSchema);
