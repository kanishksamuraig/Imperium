const mongoose = require('mongoose');

const emergencyAlertSchema = new mongoose.Schema({
  patientId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Patient',
    required: true
  },
  timestamp: {
    type: Date,
    default: Date.now
  },
  location: {
    latitude: Number,
    longitude: Number,
    address: String
  },
  status: {
    type: String,
    enum: ['active', 'acknowledged', 'resolved', 'cancelled'],
    default: 'active'
  },
  responderId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    default: null
  },
  responseTime: {
    type: Date,
    default: null
  },
  resolutionTime: {
    type: Date,
    default: null
  },
  notes: {
    type: String,
    maxlength: 1000
  },
  priority: {
    type: String,
    enum: ['low', 'medium', 'high', 'critical'],
    default: 'high'
  }
}, {
  timestamps: true
});

// Index for active alerts
emergencyAlertSchema.index({ status: 1, timestamp: -1 });

module.exports = mongoose.model('EmergencyAlert', emergencyAlertSchema);
