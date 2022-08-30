/// Exception thrown when an octal number has invalid digits
class InvalidOctalNumber implements Exception {
  /// The number that could not be converted to octal
  final int number;

  /// Create a new Exception for [number] that was invalid
  const InvalidOctalNumber(this.number);

  /// Get the message for this exception
  String get message => '$number is not a valid octal number.';

  /// Get the message for this exception
  @override
  String toString() => message;
}
