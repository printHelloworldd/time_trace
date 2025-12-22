import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:time_trace/injection.dart';
import 'package:time_trace/service/csv_service.dart';
import 'package:time_trace/view_model/activity_view_model.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final CsvService _csvService = getIt<CsvService>();
  bool _isLoading = false;

  static const privacyPolicyUrl =
      "https://www.termsfeed.com/live/5087524d-37bd-4cfb-853d-0b53dfc417c3";
  static const termsConditionsUrl =
      "https://www.termsfeed.com/live/9c216b28-0070-483f-aa08-3dfb9f37f283";

  Future<void> _exportAndShare() async {
    setState(() => _isLoading = true);

    try {
      final success = await _csvService.exportAndShare();

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('The file has been exported successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error while exporting'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _exportToDownloads() async {
    setState(() => _isLoading = true);

    try {
      final filePath = await _csvService.exportToDownloads();

      if (!mounted) return;

      if (filePath != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('The file has been saved:\n$filePath'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 5),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error saving'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _importFromCsv() async {
    // Shows warning
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Import sata'),
            content: const Text(
              'The data from the file will be appended to the existing ones.\n\n'
              'Continue?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Import'),
              ),
            ],
          ),
    );

    if (confirm != true) return;

    setState(() => _isLoading = true);

    try {
      final result = await _csvService.importActivitiesFromCsv();

      if (!mounted) return;

      // Shows result
      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: Text(result.success ? 'Success!' : 'Import completed'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(result.message),
                  if (result.errors.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    const Text('Errors:'),
                    ...result.errors.take(5).map((e) => Text('• $e')),
                    if (result.errors.length > 5)
                      Text('... and ${result.errors.length - 5}'),
                  ],
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
                ),
              ],
            ),
      );
    } finally {
      if (mounted) {
        context.read<ActivityViewModel>().loadTodayActivities();
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _openUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      if (!await launchUrl(uri)) {
        throw Exception('Failed to open URL');
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error opening link: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 32),
          child: Column(
            children: [
              MenuItemButton(
                onPressed: _exportToDownloads,
                // leadingIcon: Icon(Icons.download_rounded),
                child: Text("Export data as CSV"),
              ),
              MenuItemButton(
                onPressed: _importFromCsv,
                // leadingIcon: Icon(Icons.install_mobile_rounded),
                child: Text("Import data from CSV"),
              ),
              MenuItemButton(
                onPressed: () async {
                  await _openUrl(privacyPolicyUrl);
                },
                child: Text("Privacy Policy"),
              ),
              MenuItemButton(
                onPressed: () async {
                  await _openUrl(termsConditionsUrl);
                },
                child: Text("Terms & Conditions"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
