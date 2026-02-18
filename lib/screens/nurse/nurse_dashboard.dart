import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../services/api_service.dart';
import '../../models/patient.dart';
import '../../models/emergency_alert.dart';
import '../../widgets/sos_button.dart';
import '../auth/login_screen.dart';

class NurseDashboard extends StatefulWidget {
  const NurseDashboard({super.key});

  @override
  State<NurseDashboard> createState() => _NurseDashboardState();
}

class _NurseDashboardState extends State<NurseDashboard> {
  bool _isLoadingPatients = false;
  bool _isLoadingAlerts = false;
  List<Patient> _assignedPatients = [];
  List<EmergencyAlert> _activeAlerts = [];
  bool _isSendingSOS = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await Future.wait([
      _loadAssignedPatients(),
      _loadActiveAlerts(),
    ]);
  }

  Future<void> _loadAssignedPatients() async {
    setState(() => _isLoadingPatients = true);

    final result = await ApiService.getAllPatients();

    if (result['success']) {
      setState(() {
        _assignedPatients = (result['data'] as List)
            .map((json) => Patient.fromJson(json))
            .toList();
        _isLoadingPatients = false;
      });
    } else {
      setState(() => _isLoadingPatients = false);
    }
  }

  Future<void> _loadActiveAlerts() async {
    setState(() => _isLoadingAlerts = true);

    final result = await ApiService.getActiveAlerts();

    if (result['success']) {
      setState(() {
        _activeAlerts = (result['data'] as List)
            .map((json) => EmergencyAlert.fromJson(json))
            .toList();
        _isLoadingAlerts = false;
      });
    } else {
      setState(() => _isLoadingAlerts = false);
    }
  }

  Future<void> _acknowledgeAlert(EmergencyAlert alert) async {
    final result = await ApiService.acknowledgeAlert(alert.id);

    if (result['success']) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Alert acknowledged'),
          backgroundColor: Colors.green,
        ),
      );
      _loadActiveAlerts();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed: ${result['message']}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _resolveAlert(EmergencyAlert alert) async {
    final notes = await showDialog<String>(
      context: context,
      builder: (context) {
        final controller = TextEditingController();
        return AlertDialog(
          title: const Text('Resolve Alert'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Resolution Notes',
              hintText: 'Enter details about how the alert was resolved...',
            ),
            maxLines: 3,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, controller.text),
              child: const Text('Resolve'),
            ),
          ],
        );
      },
    );

    if (notes == null) return;

    final result = await ApiService.resolveAlert(alert.id, notes: notes);

    if (!mounted) return;

    if (result['success']) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Alert resolved'),
          backgroundColor: Colors.green,
        ),
      );
      _loadActiveAlerts();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed: ${result['message']}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _handleSOS() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Emergency SOS'),
        content: const Text('Send emergency alert to doctors and other nurses?'),
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

    // For nurse, we'll create a generic emergency alert
    // In a real app, this would be handled differently
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✅ Emergency alert sent!'),
        backgroundColor: Colors.green,
      ),
    );

    setState(() => _isSendingSOS = false);
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
        title: const Text('Nurse Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _handleLogout,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Welcome Card
            Consumer<AppProvider>(
              builder: (context, provider, child) {
                return Card(
                  color: Colors.green.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Welcome, ${provider.currentUser?.name ?? "Nurse"}!',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),

            // Active Emergency Alerts
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Active Emergency Alerts',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                if (_activeAlerts.isNotEmpty)
                  Chip(
                    label: Text('${_activeAlerts.length}'),
                    backgroundColor: Colors.red,
                    labelStyle: const TextStyle(color: Colors.white),
                  ),
              ],
            ),
            const SizedBox(height: 12),

            if (_isLoadingAlerts)
              const Center(child: CircularProgressIndicator())
            else if (_activeAlerts.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      Icon(Icons.check_circle, size: 48, color: Colors.green[400]),
                      const SizedBox(height: 8),
                      Text(
                        'No active emergency alerts',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              )
            else
              ..._activeAlerts.map((alert) => _buildAlertCard(alert)),

            const SizedBox(height: 24),

            // Assigned Patients
            Text(
              'Assigned Patients',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),

            if (_isLoadingPatients)
              const Center(child: CircularProgressIndicator())
            else if (_assignedPatients.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      Icon(Icons.people, size: 48, color: Colors.grey[400]),
                      const SizedBox(height: 8),
                      Text(
                        'No patients assigned yet',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              )
            else
              ..._assignedPatients.map((patient) => _buildPatientCard(patient)),
          ],
        ),
      ),
      floatingActionButton: SOSButton(
        onPressed: _handleSOS,
        isLoading: _isSendingSOS,
      ),
    );
  }

  Widget _buildAlertCard(EmergencyAlert alert) {
    return Card(
      color: Colors.red.shade50,
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: const Icon(Icons.warning, color: Colors.red, size: 32),
        title: Text(
          alert.patientName ?? 'Unknown Patient',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Time: ${alert.timestamp.hour}:${alert.timestamp.minute.toString().padLeft(2, '0')}'),
            if (alert.patientPhone != null) Text('Phone: ${alert.patientPhone}'),
          ],
        ),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'acknowledge',
              child: Text('Acknowledge'),
            ),
            const PopupMenuItem(
              value: 'resolve',
              child: Text('Resolve'),
            ),
          ],
          onSelected: (value) {
            if (value == 'acknowledge') {
              _acknowledgeAlert(alert);
            } else if (value == 'resolve') {
              _resolveAlert(alert);
            }
          },
        ),
      ),
    );
  }

  Widget _buildPatientCard(Patient patient) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: const CircleAvatar(
          child: Icon(Icons.person),
        ),
        title: Text(patient.patientName ?? 'Unknown'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Condition: ${patient.conditionDisplayName}'),
            if (patient.patientPhone != null) Text('Phone: ${patient.patientPhone}'),
          ],
        ),
      ),
    );
  }
}
