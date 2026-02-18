import 'package:flutter/material.dart';
import '../../models/patient.dart';
import '../../services/api_service.dart';

class SymptomLogger extends StatefulWidget {
  final Patient patient;

  const SymptomLogger({super.key, required this.patient});

  @override
  State<SymptomLogger> createState() => _SymptomLoggerState();
}

class _SymptomLoggerState extends State<SymptomLogger> {
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();
  bool _isSubmitting = false;

  // Diabetes fields
  final _bloodSugarController = TextEditingController();
  final _insulinController = TextEditingController();
  String _dietAdherence = 'good';

  // Renal Failure fields
  final _fluidIntakeController = TextEditingController();
  final _bloodPressureController = TextEditingController();
  String _swelling = 'none';
  String _fatigue = 'none';

  // TB fields
  String _coughFrequency = 'none';
  final _weightController = TextEditingController();
  bool _nightSweats = false;
  bool _medicationAdherence = true;

  // Thyroid fields
  final _tshLevelController = TextEditingController();
  String _energyLevel = 'normal';
  bool _thyroidMedAdherence = true;

  // Substance Abuse fields
  double _cravingIntensity = 0;
  double _moodRating = 5;
  bool _supportGroupAttendance = false;

  @override
  void dispose() {
    _notesController.dispose();
    _bloodSugarController.dispose();
    _insulinController.dispose();
    _fluidIntakeController.dispose();
    _bloodPressureController.dispose();
    _weightController.dispose();
    _tshLevelController.dispose();
    super.dispose();
  }

  Future<void> _submitSymptoms() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    Map<String, dynamic> symptoms = {};

    // Build symptoms based on condition
    switch (widget.patient.condition) {
      case Condition.diabetes:
        symptoms = {
          'bloodSugarLevel': double.tryParse(_bloodSugarController.text),
          'insulinDosage': double.tryParse(_insulinController.text),
          'dietAdherence': _dietAdherence,
        };
        break;

      case Condition.renalFailure:
        symptoms = {
          'fluidIntake': double.tryParse(_fluidIntakeController.text),
          'swelling': _swelling,
          'bloodPressure': _bloodPressureController.text,
          'fatigue': _fatigue,
        };
        break;

      case Condition.tb:
        symptoms = {
          'coughFrequency': _coughFrequency,
          'weight': double.tryParse(_weightController.text),
          'nightSweats': _nightSweats,
          'medicationAdherence': _medicationAdherence,
        };
        break;

      case Condition.thyroid:
        symptoms = {
          'tshLevel': double.tryParse(_tshLevelController.text),
          'energyLevel': _energyLevel,
          'medicationAdherence': _thyroidMedAdherence,
        };
        break;

      case Condition.substanceAbuse:
        symptoms = {
          'cravingIntensity': _cravingIntensity.toInt(),
          'moodRating': _moodRating.toInt(),
          'supportGroupAttendance': _supportGroupAttendance,
        };
        break;
    }

    final result = await ApiService.logSymptoms(
      patientId: widget.patient.id,
      symptoms: symptoms,
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
    );

    setState(() => _isSubmitting = false);

    if (!mounted) return;

    if (result['success']) {
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Symptoms logged successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to log symptoms: ${result['message']}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Log Symptoms'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Condition: ${widget.patient.conditionDisplayName}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Text(
                      'Debug: ${widget.patient.condition}',
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Disease-specific forms
            ..._buildConditionSpecificFields(),

            const SizedBox(height: 16),

            // Notes field (common for all)
            TextFormField(
              controller: _notesController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Additional Notes (Optional)',
                border: OutlineInputBorder(),
                hintText: 'Any other symptoms or observations...',
              ),
            ),

            const SizedBox(height: 24),

            ElevatedButton(
              onPressed: _isSubmitting ? null : _submitSymptoms,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Submit Symptoms',
                      style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildConditionSpecificFields() {
    debugPrint('🩺 Building fields for condition: ${widget.patient.condition}');
    switch (widget.patient.condition) {
      case Condition.diabetes:
        return _buildDiabetesFields();
      case Condition.renalFailure:
        return _buildRenalFields();
      case Condition.tb:
        return _buildTBFields();
      case Condition.thyroid:
        return _buildThyroidFields();
      case Condition.substanceAbuse:
        return _buildSubstanceAbuseFields();
    }
  }

  List<Widget> _buildDiabetesFields() {
    return [
      TextFormField(
        controller: _bloodSugarController,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(
          labelText: 'Blood Sugar Level (mg/dL)',
          border: OutlineInputBorder(),
          prefixIcon: Icon(Icons.bloodtype),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter blood sugar level';
          }
          return null;
        },
      ),
      const SizedBox(height: 16),
      TextFormField(
        controller: _insulinController,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(
          labelText: 'Insulin Dosage (units)',
          border: OutlineInputBorder(),
          prefixIcon: Icon(Icons.medication),
        ),
      ),
      const SizedBox(height: 16),
      DropdownButtonFormField<String>(
        value: _dietAdherence,
        decoration: const InputDecoration(
          labelText: 'Diet Adherence',
          border: OutlineInputBorder(),
          prefixIcon: Icon(Icons.restaurant),
        ),
        items: const [
          DropdownMenuItem(value: 'excellent', child: Text('Excellent')),
          DropdownMenuItem(value: 'good', child: Text('Good')),
          DropdownMenuItem(value: 'fair', child: Text('Fair')),
          DropdownMenuItem(value: 'poor', child: Text('Poor')),
        ],
        onChanged: (value) => setState(() => _dietAdherence = value!),
      ),
    ];
  }

  List<Widget> _buildRenalFields() {
    return [
      TextFormField(
        controller: _fluidIntakeController,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(
          labelText: 'Fluid Intake (ml)',
          border: OutlineInputBorder(),
          prefixIcon: Icon(Icons.local_drink),
        ),
      ),
      const SizedBox(height: 16),
      DropdownButtonFormField<String>(
        value: _swelling,
        decoration: const InputDecoration(
          labelText: 'Swelling',
          border: OutlineInputBorder(),
          prefixIcon: Icon(Icons.warning),
        ),
        items: const [
          DropdownMenuItem(value: 'none', child: Text('None')),
          DropdownMenuItem(value: 'mild', child: Text('Mild')),
          DropdownMenuItem(value: 'moderate', child: Text('Moderate')),
          DropdownMenuItem(value: 'severe', child: Text('Severe')),
        ],
        onChanged: (value) => setState(() => _swelling = value!),
      ),
      const SizedBox(height: 16),
      TextFormField(
        controller: _bloodPressureController,
        decoration: const InputDecoration(
          labelText: 'Blood Pressure (e.g., 120/80)',
          border: OutlineInputBorder(),
          prefixIcon: Icon(Icons.favorite),
        ),
      ),
      const SizedBox(height: 16),
      DropdownButtonFormField<String>(
        value: _fatigue,
        decoration: const InputDecoration(
          labelText: 'Fatigue Level',
          border: OutlineInputBorder(),
          prefixIcon: Icon(Icons.battery_alert),
        ),
        items: const [
          DropdownMenuItem(value: 'none', child: Text('None')),
          DropdownMenuItem(value: 'mild', child: Text('Mild')),
          DropdownMenuItem(value: 'moderate', child: Text('Moderate')),
          DropdownMenuItem(value: 'severe', child: Text('Severe')),
        ],
        onChanged: (value) => setState(() => _fatigue = value!),
      ),
    ];
  }

  List<Widget> _buildTBFields() {
    return [
      DropdownButtonFormField<String>(
        value: _coughFrequency,
        decoration: const InputDecoration(
          labelText: 'Cough Frequency',
          border: OutlineInputBorder(),
          prefixIcon: Icon(Icons.sick),
        ),
        items: const [
          DropdownMenuItem(value: 'none', child: Text('None')),
          DropdownMenuItem(value: 'occasional', child: Text('Occasional')),
          DropdownMenuItem(value: 'frequent', child: Text('Frequent')),
          DropdownMenuItem(value: 'constant', child: Text('Constant')),
        ],
        onChanged: (value) => setState(() => _coughFrequency = value!),
      ),
      const SizedBox(height: 16),
      TextFormField(
        controller: _weightController,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(
          labelText: 'Weight (kg)',
          border: OutlineInputBorder(),
          prefixIcon: Icon(Icons.monitor_weight),
        ),
      ),
      const SizedBox(height: 16),
      SwitchListTile(
        title: const Text('Night Sweats'),
        value: _nightSweats,
        onChanged: (value) => setState(() => _nightSweats = value),
      ),
      SwitchListTile(
        title: const Text('Taking Medication as Prescribed'),
        value: _medicationAdherence,
        onChanged: (value) => setState(() => _medicationAdherence = value),
      ),
    ];
  }

  List<Widget> _buildThyroidFields() {
    return [
      TextFormField(
        controller: _tshLevelController,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: const InputDecoration(
          labelText: 'TSH Level (mIU/L)',
          border: OutlineInputBorder(),
          prefixIcon: Icon(Icons.science),
          hintText: 'Normal: 0.4 – 4.0',
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter your TSH level';
          }
          return null;
        },
      ),
      const SizedBox(height: 16),
      DropdownButtonFormField<String>(
        value: _energyLevel,
        decoration: const InputDecoration(
          labelText: 'Energy Level',
          border: OutlineInputBorder(),
          prefixIcon: Icon(Icons.battery_charging_full),
        ),
        items: const [
          DropdownMenuItem(
              value: 'high', child: Text('High (Hyperthyroid symptoms)')),
          DropdownMenuItem(value: 'normal', child: Text('Normal')),
          DropdownMenuItem(
              value: 'low', child: Text('Low (Hypothyroid symptoms)')),
          DropdownMenuItem(
              value: 'very_low', child: Text('Very Low / Exhausted')),
        ],
        onChanged: (value) => setState(() => _energyLevel = value!),
      ),
      const SizedBox(height: 16),
      SwitchListTile(
        title: const Text('Taking Thyroid Medication as Prescribed'),
        subtitle: const Text('Levothyroxine or equivalent'),
        value: _thyroidMedAdherence,
        onChanged: (value) => setState(() => _thyroidMedAdherence = value),
      ),
    ];
  }

  List<Widget> _buildSubstanceAbuseFields() {
    return [
      Text('Craving Intensity: ${_cravingIntensity.toInt()}/10'),
      Slider(
        value: _cravingIntensity,
        min: 0,
        max: 10,
        divisions: 10,
        label: _cravingIntensity.toInt().toString(),
        onChanged: (value) => setState(() => _cravingIntensity = value),
      ),
      const SizedBox(height: 16),
      Text('Mood Rating: ${_moodRating.toInt()}/10'),
      Slider(
        value: _moodRating,
        min: 0,
        max: 10,
        divisions: 10,
        label: _moodRating.toInt().toString(),
        onChanged: (value) => setState(() => _moodRating = value),
      ),
      const SizedBox(height: 16),
      SwitchListTile(
        title: const Text('Attended Support Group'),
        value: _supportGroupAttendance,
        onChanged: (value) => setState(() => _supportGroupAttendance = value),
      ),
    ];
  }
}
