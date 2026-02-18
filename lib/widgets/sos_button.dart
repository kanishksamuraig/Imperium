import 'package:flutter/material.dart';

class SOSButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isLoading;

  const SOSButton({
    super.key,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.large(
      onPressed: isLoading ? null : onPressed,
      backgroundColor: Colors.red.shade600,
      child: isLoading
          ? const CircularProgressIndicator(color: Colors.white)
          : const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.sos, size: 36, color: Colors.white),
                SizedBox(height: 4),
                Text(
                  'SOS',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
    );
  }
}
