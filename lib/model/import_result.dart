class ImportResult {
  final bool success;
  final int successCount;
  final int errorCount;
  final List<String> errors;
  final String message;

  ImportResult({
    required this.success,
    this.successCount = 0,
    this.errorCount = 0,
    this.errors = const [],
    required this.message,
  });
}
