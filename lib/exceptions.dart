// Exception thrown when an octal number has invalid digits
class InvalidOctalNumber implements Exception {
  final int number;
  const InvalidOctalNumber(this.number);
  String get message => "${this.number} is not a valid octal number.";
  String toString() => this.message;
}