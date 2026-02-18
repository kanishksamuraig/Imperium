import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../models/symptom_log.dart';
import 'package:intl/intl.dart';

class FlaggedSymptomsScreen extends StatefulWidget {
  const FlaggedSymptomsScreen({super.key});

  @override
  State<FlaggedSymptomsScreen> createState() => _FlaggedSymptomsScreenState();
}

class _FlaggedSymptomsScreenState extends State<FlaggedSymptomsScreen> {
  List<SymptomLog> _flaggedSymptoms = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadFlaggedSymptoms();
  }

  Future<void> _loadFlaggedSymptoms() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final result = await ApiService.getFlaggedSymptoms();

      if (result['success']) {
        final List<dynamic> symptomsData = result['data'] as List<dynamic>;
        final List<SymptomLog> parsed = [];
        for (int i = 0; i < symptomsData.length; i++) {
          try {
            final item = symptomsData[i];
            final map = Map<String, dynamic>.from(item as Map);
            parsed.add(SymptomLog.fromJson(map));
          } catch (itemErr) {
            debugPrint('⚠️ Failed to parse symptom[$i]: $itemErr');
            debugPrint('   Raw item: ${symptomsData[i]}');
          }
        }
        setState(() {
          _flaggedSymptoms = parsed;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = result['message'];
          _isLoading = false;
        });
      }
    } catch (e, stack) {
      debugPrint('❌ loadFlaggedSymptoms error: $e\n$stack');
      setState(() {
        _error = 'Error loading flagged symptoms: $e';
        _isLoading = false;
      });
    }
  }

  Color _getSeverityColor(Severity severity) {
    switch (severity) {
      case Severity.critical:
        return Colors.red;
      case Severity.warning:
        return Colors.orange;
      case Severity.normal:
        return Colors.green;
    }
  }

  IconData _getSeverityIcon(Severity severity) {
    switch (severity) {
      case Severity.critical:
        return Icons.error;
      case Severity.warning:
        return Icons.warning;
      case Severity.normal:
        return Icons.check_circle;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flagged Symptoms'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadFlaggedSymptoms,
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
                        onPressed: _loadFlaggedSymptoms,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : _flaggedSymptoms.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle_outline,
                              size: 64, color: Colors.green[400]),
                          const SizedBox(height: 16),
                          Text(
                            'No flagged symptoms',
                            style: TextStyle(
                                color: Colors.grey[600], fontSize: 18),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'All patients are doing well!',
                            style: TextStyle(color: Colors.grey[500]),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadFlaggedSymptoms,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16.0),
                        itemCount: _flaggedSymptoms.length,
                        itemBuilder: (context, index) {
                          final symptom = _flaggedSymptoms[index];
                          final dateFormat = DateFormat('MMM dd, yyyy HH:mm');

                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ExpansionTile(
                              leading: Icon(
                                _getSeverityIcon(symptom.severity),
                                color: _getSeverityColor(symptom.severity),
                                size: 32,
                              ),
                              title: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      symptom.patientName != null
                                          ? 'Patient: ${symptom.patientName}'
                                          : symptom.patientId.length > 8
                                              ? 'Patient: ${symptom.patientId.substring(0, 8)}...'
                                              : 'Patient: ${symptom.patientId}',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  Chip(
                                    label: Text(
                                      symptom.severity.name.toUpperCase(),
                                      style: const TextStyle(
                                          fontSize: 11, color: Colors.white),
                                    ),
                                    backgroundColor:
                                        _getSeverityColor(symptom.severity),
                                    padding: EdgeInsets.zero,
                                  ),
                                ],
                              ),
                              subtitle: Text(
                                dateFormat.format(symptom.date),
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Symptoms:',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleSmall
                                            ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                      const SizedBox(height: 8),
                                      ...symptom.symptoms.entries.map((entry) {
                                        return Padding(
                                          padding:
                                              const EdgeInsets.only(bottom: 4),
                                          child: Row(
                                            children: [
                                              const Icon(Icons.circle, size: 8),
                                              const SizedBox(width: 8),
                                              Text('${entry.key}: '),
                                              Text(
                                                '${entry.value}',
                                                style: const TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ],
                                          ),
                                        );
                                      }).toList(),
                                      if (symptom.notes != null) ...[
                                        const SizedBox(height: 12),
                                        Text(
                                          'Notes:',
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleSmall
                                              ?.copyWith(
                                                fontWeight: FontWeight.bold,
                                              ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(symptom.notes!),
                                      ],
                                      if (symptom.doctorNotes != null) ...[
                                        const SizedBox(height: 12),
                                        Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: Colors.blue[50],
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Doctor Notes:',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .titleSmall
                                                    ?.copyWith(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.blue[900],
                                                    ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(symptom.doctorNotes!),
                                            ],
                                          ),
                                        ),
                                      ],
                                      const SizedBox(height: 12),
                                      ElevatedButton.icon(
                                        onPressed: () {
                                          _showAddNotesDialog(symptom);
                                        },
                                        icon: const Icon(Icons.note_add),
                                        label: const Text('Add Doctor Notes'),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
    );
  }

  void _showAddNotesDialog(SymptomLog symptom) {
    final notesController =
        TextEditingController(text: symptom.doctorNotes ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.note_add, color: Colors.blue),
            const SizedBox(width: 8),
            const Text('Doctor Notes'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (symptom.patientName != null) ...[
              Text(
                'Patient: ${symptom.patientName}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
            ],
            TextField(
              controller: notesController,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Enter your clinical notes here...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final notes = notesController.text.trim();
              if (notes.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Please enter notes before saving')),
                );
                return;
              }
              Navigator.pop(context);
              // Save notes via API
              final result = await ApiService.reviewSymptom(
                symptomId: symptom.id,
                doctorNotes: notes,
              );
              if (!mounted) return;
              if (result['success']) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('✅ Notes saved and patient notified'),
                    backgroundColor: Colors.green,
                  ),
                );
                _loadFlaggedSymptoms(); // Refresh — reviewed items disappear
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to save notes: ${result['message']}'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Save Notes'),
          ),
        ],
      ),
    );
  }
}
