import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../models/emergency_alert.dart';
import 'package:intl/intl.dart';

class EmergencyAlertsScreen extends StatefulWidget {
  const EmergencyAlertsScreen({super.key});

  @override
  State<EmergencyAlertsScreen> createState() => _EmergencyAlertsScreenState();
}

class _EmergencyAlertsScreenState extends State<EmergencyAlertsScreen> {
  List<EmergencyAlert> _alerts = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadAlerts();
  }

  Future<void> _loadAlerts() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final result = await ApiService.getActiveAlerts();
      
      if (result['success']) {
        final List<dynamic> alertsData = result['data'];
        setState(() {
          _alerts = alertsData.map((json) => EmergencyAlert.fromJson(json)).toList();
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
        _error = 'Error loading alerts: $e';
        _isLoading = false;
      });
    }
  }

  Color _getPriorityColor(AlertPriority priority) {
    switch (priority) {
      case AlertPriority.critical:
        return Colors.red;
      case AlertPriority.high:
        return Colors.orange;
      case AlertPriority.medium:
        return Colors.yellow[700]!;
      case AlertPriority.low:
        return Colors.blue;
    }
  }

  Color _getStatusColor(AlertStatus status) {
    switch (status) {
      case AlertStatus.active:
        return Colors.red;
      case AlertStatus.acknowledged:
        return Colors.orange;
      case AlertStatus.resolved:
        return Colors.green;
      case AlertStatus.cancelled:
        return Colors.grey;
    }
  }

  IconData _getPriorityIcon(AlertPriority priority) {
    switch (priority) {
      case AlertPriority.critical:
        return Icons.emergency;
      case AlertPriority.high:
        return Icons.warning;
      case AlertPriority.medium:
        return Icons.info;
      case AlertPriority.low:
        return Icons.notifications;
    }
  }

  Future<void> _acknowledgeAlert(EmergencyAlert alert) async {
    try {
      final result = await ApiService.acknowledgeAlert(alert.id);
      
      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Alert acknowledged'),
            backgroundColor: Colors.green,
          ),
        );
        _loadAlerts(); // Reload alerts
      } else {
        throw Exception(result['message']);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _resolveAlert(EmergencyAlert alert) async {
    final notesController = TextEditingController();
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Resolve Alert'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Add resolution notes:'),
            const SizedBox(height: 8),
            TextField(
              controller: notesController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Enter resolution notes...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Resolve'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final result = await ApiService.resolveAlert(
          alert.id,
          notes: notesController.text.trim().isEmpty ? null : notesController.text.trim(),
        );
        
        if (result['success']) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Alert resolved'),
              backgroundColor: Colors.green,
            ),
          );
          _loadAlerts(); // Reload alerts
        } else {
          throw Exception(result['message']);
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Emergency Alerts'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAlerts,
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
                      Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                      const SizedBox(height: 16),
                      Text(_error!, textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _loadAlerts,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : _alerts.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle_outline, size: 64, color: Colors.green[400]),
                          const SizedBox(height: 16),
                          Text(
                            'No active alerts',
                            style: TextStyle(color: Colors.grey[600], fontSize: 18),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'All patients are safe',
                            style: TextStyle(color: Colors.grey[500]),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadAlerts,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16.0),
                        itemCount: _alerts.length,
                        itemBuilder: (context, index) {
                          final alert = _alerts[index];
                          final dateFormat = DateFormat('MMM dd, yyyy HH:mm');
                          
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            color: alert.status == AlertStatus.active
                                ? Colors.red[50]
                                : alert.status == AlertStatus.acknowledged
                                    ? Colors.orange[50]
                                    : null,
                            child: ExpansionTile(
                              leading: Icon(
                                _getPriorityIcon(alert.priority),
                                color: _getPriorityColor(alert.priority),
                                size: 36,
                              ),
                              title: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      alert.patientName ?? 'Patient: ${alert.patientId.substring(0, 8)}...',
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  Chip(
                                    label: Text(
                                      alert.status.toString().split('.').last.toUpperCase(),
                                      style: const TextStyle(fontSize: 11, color: Colors.white),
                                    ),
                                    backgroundColor: _getStatusColor(alert.status),
                                    padding: EdgeInsets.zero,
                                  ),
                                ],
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(Icons.priority_high, size: 16, color: _getPriorityColor(alert.priority)),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Priority: ${alert.priority.toString().split('.').last.toUpperCase()}',
                                        style: TextStyle(color: _getPriorityColor(alert.priority), fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Triggered: ${dateFormat.format(alert.timestamp)}',
                                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                                  ),
                                ],
                              ),
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      if (alert.patientPhone != null) ...[
                                        Row(
                                          children: [
                                            const Icon(Icons.phone, size: 20),
                                            const SizedBox(width: 8),
                                            Text(
                                              alert.patientPhone!,
                                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                            ),
                                            const SizedBox(width: 8),
                                            IconButton(
                                              icon: const Icon(Icons.call, color: Colors.green),
                                              onPressed: () {
                                                // TODO: Implement call functionality
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(content: Text('Calling ${alert.patientPhone}...')),
                                                );
                                              },
                                            ),
                                          ],
                                        ),
                                        const Divider(),
                                      ],
                                      if (alert.location != null) ...[
                                        Text(
                                          'Location:',
                                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                                fontWeight: FontWeight.bold,
                                              ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text('Lat: ${alert.location!['latitude']}, Long: ${alert.location!['longitude']}'),
                                        const SizedBox(height: 12),
                                      ],
                                      if (alert.notes != null) ...[
                                        Text(
                                          'Notes:',
                                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                                fontWeight: FontWeight.bold,
                                              ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(alert.notes!),
                                        const SizedBox(height: 12),
                                      ],
                                      if (alert.responderName != null) ...[
                                        Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: Colors.blue[50],
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Responder: ${alert.responderName}',
                                                style: const TextStyle(fontWeight: FontWeight.bold),
                                              ),
                                              if (alert.responseTime != null)
                                                Text('Acknowledged: ${dateFormat.format(alert.responseTime!)}'),
                                              if (alert.resolutionTime != null)
                                                Text('Resolved: ${dateFormat.format(alert.resolutionTime!)}'),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                      ],
                                      Row(
                                        children: [
                                          if (alert.status == AlertStatus.active) ...[
                                            Expanded(
                                              child: ElevatedButton.icon(
                                                onPressed: () => _acknowledgeAlert(alert),
                                                icon: const Icon(Icons.check),
                                                label: const Text('Acknowledge'),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.orange,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                          ],
                                          if (alert.status != AlertStatus.resolved)
                                            Expanded(
                                              child: ElevatedButton.icon(
                                                onPressed: () => _resolveAlert(alert),
                                                icon: const Icon(Icons.done_all),
                                                label: const Text('Resolve'),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.green,
                                                ),
                                              ),
                                            ),
                                        ],
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
}
