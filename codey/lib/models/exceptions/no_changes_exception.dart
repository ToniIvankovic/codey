class NoChangesException implements Exception {
  final String message;

  NoChangesException(this.message);

  @override
  String toString() {
    return message;
  }
}