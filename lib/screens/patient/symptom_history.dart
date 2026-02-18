import 'package:flutter/material.dart';
import '../../models/patient.dart';
import '../../models/symptom_log.dart';
import '../../services/api_service.dart';

class SymptomHistory extends StatefulWidget {
  final Patient patient;

  const SymptomHistory({super.key, required this.patient});

  @override
  State<SymptomHistory> createState() => _SymptomHistoryState();
}

class _SymptomHistoryState extends State<SymptomHistory> {
  bool _isLoading = true;
  List<SymptomLog> _symptoms = [];

  @override
  void initState() {
    super.initState();
    _loadSymptoms();
  }

  Future<void> _loadSymptoms() async {
    setState(() => _isLoading = true);

    final result =
        await ApiService.getSymptomHistory(widget.patient.id, limit: 50);

    if (result['success']) {
      setState(() {
        _symptoms = (result['data'] as List)
            .map((json) => SymptomLog.fromJson(json))
            .toList();
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Symptom History'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _symptoms.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.history, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('No symptom history yet'),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadSymptoms,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _symptoms.length,
                    itemBuilder: (context, index) {
                      return _buildSymptomCard(_symptoms[index]);
                    },
                  ),
                ),
    );
  }

  Widget _buildSymptomCard(SymptomLog log) {
    Color severityColor;
    switch (log.severity) {
      case Severity.critical:
        severityColor = Colors.red;
        break;
      case Severity.warning:
        severityColor = Colors.orange;
        break;
      default:
        severityColor = Colors.green;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: severityColor,
          child: const Icon(Icons.favorite, color: Colors.white),
        ),
        title: Text(
          '${log.date.day}/${log.date.month}/${log.date.year} - ${log.date.hour}:${log.date.minute.toString().padLeft(2, '0')}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          'Severity: ${log.severity.toString().split('.').last.toUpperCase()}',
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Symptoms:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...log.symptoms.entries.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text('• ${entry.key}: ${entry.value}'),
                  );
                }),
                if (log.notes != null && log.notes!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  const Text(
                    'Notes:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(log.notes!),
                ],
                if (log.flaggedBySystem) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.flag, color: Colors.red, size: 16),
                        SizedBox(width: 8),
                        Text(
                          'Flagged for doctor review',
                          style: TextStyle(color: Colors.red),
                        ),
                      ],
                    ),
                  ),
                ],
                if (log.reviewedByDoctor &&
                    log.doctorNotes != null &&
                    log.doctorNotes!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.verified, color: Colors.blue, size: 16),
                            SizedBox(width: 8),
                            Text(
                              'Doctor\'s Notes:',
                              style: TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(log.doctorNotes!),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
