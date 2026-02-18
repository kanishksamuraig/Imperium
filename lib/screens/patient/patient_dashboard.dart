import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../services/api_service.dart';
import '../../widgets/sos_button.dart';
import '../../models/patient.dart';
import '../../models/symptom_log.dart';
import '../auth/login_screen.dart';
import 'symptom_logger.dart';
import 'symptom_history.dart';

class PatientDashboard extends StatefulWidget {
  const PatientDashboard({super.key});

  @override
  State<PatientDashboard> createState() => _PatientDashboardState();
}

class _PatientDashboardState extends State<PatientDashboard> {
  bool _isLoadingSymptoms = false;
  List<SymptomLog> _recentSymptoms = [];
  bool _isSendingSOS = false;

  @override
  void initState() {
    super.initState();
    _loadRecentSymptoms();
    // Ensure patient data is loaded (may not be ready if background load is still in progress)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<AppProvider>(context, listen: false);
      if (provider.currentPatient == null) {
        provider.loadPatientData();
      }
    });
  }

  Future<void> _loadRecentSymptoms() async {
    final provider = Provider.of<AppProvider>(context, listen: false);
    if (provider.currentPatient == null) return;

    setState(() => _isLoadingSymptoms = true);

    final result = await ApiService.getSymptomHistory(
      provider.currentPatient!.id,
      limit: 5,
    );

    if (result['success']) {
      setState(() {
        _recentSymptoms = (result['data'] as List)
            .map((json) => SymptomLog.fromJson(json))
            .toList();
        _isLoadingSymptoms = false;
      });
    } else {
      setState(() => _isLoadingSymptoms = false);
    }
  }

  Future<void> _handleSOS() async {
    final provider = Provider.of<AppProvider>(context, listen: false);
    if (provider.currentPatient == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Emergency SOS'),
        content:
            const Text('Are you sure you want to send an emergency alert?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Send SOS'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isSendingSOS = true);

    final result = await ApiService.triggerEmergencyAlert(
      patientId: provider.currentPatient!.id,
      notes: 'Emergency alert from patient',
    );

    setState(() => _isSendingSOS = false);

    if (!mounted) return;

    if (result['success']) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Emergency alert sent successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to send alert: ${result['message']}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _handleLogout() async {
    final provider = Provider.of<AppProvider>(context, listen: false);
    await provider.logout();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Patient Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _handleLogout,
          ),
        ],
      ),
      body: Consumer<AppProvider>(
        builder: (context, provider, child) {
          if (provider.currentPatient == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  const Text('Loading your patient profile...'),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => provider.loadPatientData(),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'If this persists, please contact support.',
                    style: TextStyle(color: Colors.grey[500], fontSize: 12),
                  ),
                ],
              ),
            );
          }

          final patient = provider.currentPatient!;

          return RefreshIndicator(
            onRefresh: _loadRecentSymptoms,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Welcome Card
                Card(
                  color: Colors.blue.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome, ${provider.currentUser?.name ?? "Patient"}!',
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        const SizedBox(height: 8),
                        Text('Condition: ${patient.conditionDisplayName}'),
                        if (patient.doctorName != null)
                          Text('Doctor: ${patient.doctorName}'),
                        if (patient.nurseName != null)
                          Text('Nurse: ${patient.nurseName}'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Quick Actions
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => SymptomLogger(patient: patient),
                            ),
                          );
                          _loadRecentSymptoms();
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Log Symptoms'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => SymptomHistory(patient: patient),
                            ),
                          );
                        },
                        icon: const Icon(Icons.history),
                        label: const Text('View History'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Recent Symptoms
                Text(
                  'Recent Symptom Logs',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 12),

                if (_isLoadingSymptoms)
                  const Center(child: CircularProgressIndicator())
                else if (_recentSymptoms.isEmpty)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        children: [
                          Icon(Icons.note_add,
                              size: 48, color: Colors.grey[400]),
                          const SizedBox(height: 8),
                          Text(
                            'No symptom logs yet',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Tap "Log Symptoms" to add your first entry',
                            style: TextStyle(
                                color: Colors.grey[500], fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  ..._recentSymptoms.map((log) => _buildSymptomCard(log)),
              ],
            ),
          );
        },
      ),
      floatingActionButton: SOSButton(
        onPressed: _handleSOS,
        isLoading: _isSendingSOS,
      ),
    );
  }

  Widget _buildSymptomCard(SymptomLog log) {
    Color severityColor;
    IconData severityIcon;

    switch (log.severity) {
      case Severity.critical:
        severityColor = Colors.red;
        severityIcon = Icons.error;
        break;
      case Severity.warning:
        severityColor = Colors.orange;
        severityIcon = Icons.warning;
        break;
      default:
        severityColor = Colors.green;
        severityIcon = Icons.check_circle;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(severityIcon, color: severityColor),
        title: Text(
          'Logged on ${log.date.day}/${log.date.month}/${log.date.year}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
                'Severity: ${log.severity.toString().split('.').last.toUpperCase()}'),
            if (log.notes != null && log.notes!.isNotEmpty)
              Text('Notes: ${log.notes}',
                  maxLines: 2, overflow: TextOverflow.ellipsis),
            if (log.flaggedBySystem)
              const Text(
                '⚠️ Flagged for doctor review',
                style:
                    TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
          ],
        ),
        trailing: log.reviewedByDoctor
            ? const Icon(Icons.verified, color: Colors.blue)
            : null,
      ),
    );
  }
}
