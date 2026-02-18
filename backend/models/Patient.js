const mongoose = require('mongoose');

const patientSchema = new mongoose.Schema({
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true,
    unique: true
  },
  condition: {
    type: String,
    enum: ['diabetes', 'renal_failure', 'tb', 'thyroid', 'substance_abuse'],
    required: true
  },
  registrationDate: {
    type: Date,
    default: Date.now
  },
  assignedDoctor: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  assignedNurse: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    default: null
  },
  baseline: {
    // Disease-specific baseline data
    hba1c: Number,           // For diabetes
    creatinine: Number,      // For renal
    tbStage: String,         // For TB
    tshLevel: Number,        // For thyroid
    rehabStage: String,      // For substance abuse
    notes: String
  },
  medicalHistory: {
    allergies: [String],
    currentMedications: [String],
    previousConditions: [String]
  },
  isActive: {
    type: Boolean,
    default: true
  }
}, {
  timestamps: true
});

module.exports = mongoose.model('Patient', patientSchema);
