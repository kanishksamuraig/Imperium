import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../models/patient.dart';

class ViewPatientsScreen extends StatefulWidget {
  const ViewPatientsScreen({super.key});

  @override
  State<ViewPatientsScreen> createState() => _ViewPatientsScreenState();
}

class _ViewPatientsScreenState extends State<ViewPatientsScreen> {
  List<Patient> _patients = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPatients();
  }

  Future<void> _loadPatients() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final result = await ApiService.getAllPatients();

      if (result['success']) {
        final List<dynamic> patientsData = result['data'];
        setState(() {
          _patients =
              patientsData.map((json) => Patient.fromJson(json)).toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = result['message'];
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error loading patients: $e';
        _isLoading = false;
      });
    }
  }

  String _getConditionLabel(Condition condition) {
    switch (condition) {
      case Condition.diabetes:
        return 'Diabetes';
      case Condition.renalFailure:
        return 'Renal Failure';
      case Condition.tb:
        return 'Tuberculosis';
      case Condition.thyroid:
        return 'Thyroid';
      case Condition.substanceAbuse:
        return 'Substance Abuse';
    }
  }

  Color _getConditionColor(Condition condition) {
    switch (condition) {
      case Condition.diabetes:
        return Colors.blue;
      case Condition.renalFailure:
        return Colors.red;
      case Condition.tb:
        return Colors.orange;
      case Condition.thyroid:
        return Colors.purple;
      case Condition.substanceAbuse:
        return Colors.teal;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Patients'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPatients,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline,
                          size: 64, color: Colors.red[300]),
                      const SizedBox(height: 16),
                      Text(_error!, textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _loadPatients,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : _patients.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.people_outline,
                              size: 64, color: Colors.grey[400]),
                          const SizedBox(height: 16),
                          Text(
                            'No patients registered yet',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadPatients,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16.0),
                        itemCount: _patients.length,
                        itemBuilder: (context, index) {
                          final patient = _patients[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor:
                                    _getConditionColor(patient.condition),
                                child: Text(
                                  (patient.patientName?.isNotEmpty == true
                                          ? patient.patientName![0]
                                          : 'P')
                                      .toUpperCase(),
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                              title: Text(
                                patient.patientName ??
                                    'Patient ${patient.id.substring(0, 6)}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  if (patient.patientEmail != null)
                                    Text(
                                      patient.patientEmail!,
                                      style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 12),
                                    ),
                                  const SizedBox(height: 2),
                                  Row(
                                    children: [
                                      Icon(Icons.medical_services,
                                          size: 16,
                                          color: _getConditionColor(
                                              patient.condition)),
                                      const SizedBox(width: 4),
                                      Text(_getConditionLabel(
                                          patient.condition)),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Row(
                                    children: [
                                      Icon(Icons.calendar_today,
                                          size: 16, color: Colors.grey[600]),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Registered: ${patient.registrationDate.toString().substring(0, 10)}',
                                        style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              onTap: () {
                                // TODO: Navigate to patient details
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(
                                          'Patient details for ${patient.id}')),
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}
