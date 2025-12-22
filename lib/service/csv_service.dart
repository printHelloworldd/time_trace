import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:time_trace/model/activity_model.dart';
import 'package:time_trace/model/category_model.dart';
import 'package:time_trace/model/import_result.dart';
import 'package:time_trace/service/activity_service.dart';
import 'package:time_trace/service/category_service.dart';

class CsvService {
  final ActivityService activityService;
  final CategoryService categoryService;

  CsvService({required this.activityService, required this.categoryService});

  /// Exports activities in CSV
  Future<String?> exportActivitiesToCsv({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      // Gets data
      final activities = await _getActivitiesForExport(startDate, endDate);

      if (activities.isEmpty) {
        throw Exception('No data for export');
      }

      // Creates CSV data
      final csvData = _createCsvData(activities);

      // Converts CSV into String
      final csvString = const ListToCsvConverter().convert(csvData);

      // Saves file
      final filePath = await _saveCsvFile(csvString);

      return filePath;
    } catch (e) {
      print('Failed to export: $e');
      return null;
    }
  }

  /// Exports and shares file
  Future<bool> exportAndShare() async {
    try {
      final filePath = await exportActivitiesToCsv();

      if (filePath == null) {
        return false;
      }

      // Sahres file
      final result = await Share.shareXFiles(
        [XFile(filePath)],
        subject: 'Activities export',
        text: 'Activities data in CSV format',
      );

      return result.status == ShareResultStatus.success;
    } catch (e) {
      print('Failed to share: $e');
      return false;
    }
  }

  /// Exports in Downloads (Android)
  Future<String?> exportToDownloads() async {
    try {
      final activities = await _getActivitiesForExport(null, null);
      if (activities.isEmpty) {
        throw Exception('No data for export');
      }

      final csvData = _createCsvData(activities);
      final csvString = const ListToCsvConverter().convert(csvData);

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'activities_export_$timestamp.csv';
      final bytes = utf8.encode(csvString);

      String? outputPath = await FilePicker.platform.saveFile(
        dialogTitle: 'Сохранить CSV',
        fileName: fileName,
        type: FileType.custom,
        allowedExtensions: ['csv'],
        bytes: Uint8List.fromList(bytes),
      );

      return outputPath;
    } catch (e) {
      print('Failed to export in Downloads: $e');
      return null;
    }
  }

  /// Imports activities from CSV
  Future<ImportResult> importActivitiesFromCsv() async {
    try {
      // Выбираем файл
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );

      if (result == null || result.files.single.path == null) {
        return ImportResult(
          success: false,
          message: 'File has not been selected',
        );
      }

      final filePath = result.files.single.path!;
      final file = File(filePath);

      // Reads file
      final csvString = await file.readAsString();

      // Parses CSV
      final csvData = const CsvToListConverter().convert(csvString);

      if (csvData.isEmpty || csvData.length < 2) {
        return ImportResult(success: false, message: 'File is empty');
      }

      // Imports data
      final importResult = await _importCsvData(csvData);

      return importResult;
    } catch (e) {
      print('Failed to import: $e');
      return ImportResult(success: false, message: 'Failed to import: $e');
    }
  }

  Future<List<ActivityModel>> _getActivitiesForExport(
    DateTime? startDate,
    DateTime? endDate,
  ) async {
    if (startDate != null && endDate != null) {
      return await activityService.getActivitiesForPeriod(
        startDate: startDate,
        endDate: endDate,
      );
    }

    // If no dates are specified, we export everything
    return await activityService.getAllActivities();
  }

  /// Creates CSV data from the activity list
  List<List<dynamic>> _createCsvData(List<ActivityModel> activities) {
    // Headers
    final headers = [
      'ID',
      'Title',
      'Category',
      'Category color',
      'Hour',
      'Date',
      'Date of creation',
    ];

    // Data
    final rows =
        activities.map((activity) {
          return [
            activity.id ?? '',
            activity.title,
            activity.category.title,
            activity.category.color.value.toRadixString(16), // Цвет в HEX
            activity.hour,
            _formatDate(activity.date),
            _formatDateTime(activity.createdAt),
          ];
        }).toList();

    return [headers, ...rows];
  }

  Future<String> _saveCsvFile(String csvString) async {
    final directory = await getApplicationDocumentsDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final fileName = 'activities_export_$timestamp.csv';
    final file = File('${directory.path}/$fileName');

    await file.writeAsString(csvString);

    return file.path;
  }

  Future<ImportResult> _importCsvData(List<List<dynamic>> csvData) async {
    int successCount = 0;
    int errorCount = 0;
    final errors = <String>[];

    // Skips headers (first row)
    for (int i = 1; i < csvData.length; i++) {
      try {
        final row = csvData[i];

        if (row.length < 7) {
          errors.add('Row $i: insufficient data');
          errorCount++;
          continue;
        }

        // Parses data
        final title = row[1].toString();
        final categoryTitle = row[2].toString();
        final colorHex = row[3].toString();
        final hour = int.parse(row[4].toString());
        final dateStr = row[5].toString();

        // Finds or creates category
        final category = await _findOrCreateCategory(categoryTitle, colorHex);

        // Parses date
        final dateParts = dateStr.split('-');
        final date = DateTime(
          int.parse(dateParts[0]),
          int.parse(dateParts[1]),
          int.parse(dateParts[2]),
        );

        // Creates activity
        final activity = ActivityModel(
          title: title,
          category: category,
          hour: hour,
          date: date,
        );

        // Saves
        await activityService.addActivity(activity);
        successCount++;
      } catch (e) {
        errors.add('Row $i: $e');
        errorCount++;
      }
    }

    return ImportResult(
      success: errorCount == 0,
      successCount: successCount,
      errorCount: errorCount,
      errors: errors,
      message: 'Imported: $successCount, Errors: $errorCount',
    );
  }

  Future<CategoryModel> _findOrCreateCategory(
    String title,
    String colorHex,
  ) async {
    final categories = await categoryService.getAllCategories();
    final existing =
        categories
            .where((c) => c.title.toLowerCase() == title.toLowerCase())
            .firstOrNull;

    if (existing != null) {
      return existing;
    }

    final color = _parseColor(colorHex);
    final newCategory = CategoryModel(title: title, color: color);

    final id = await categoryService.addCategory(newCategory);

    return newCategory.copyWith(id: id);
  }

  /// Parses color from HEX
  Color _parseColor(String hexString) {
    try {
      final hex = hexString.replaceAll('#', '');
      return Color(int.parse('0x$hex'));
    } catch (e) {
      return Colors.blue; // Default color
    }
  }

  /// Formats date for CSV
  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// Formats date and time fro CSV
  String _formatDateTime(DateTime dateTime) {
    return '${_formatDate(dateTime)} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
