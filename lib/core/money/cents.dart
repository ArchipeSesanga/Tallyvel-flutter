/// An amount of South African rand, held as a whole number of cents.
///
/// The API sends every amount as integer cents (`amountCents: 10050` is
/// R100,50), so the app never holds money in a `double`. An extension type
/// costs nothing at runtime (it is an `int`) but cannot be mixed up with
/// another `int`: a count of members is not a [Cents], and the compiler says
/// so.
extension type const Cents(int value) {
  /// R0,00.
  static const zero = Cents(0);

  /// The largest amount the API accepts (2^53 - 1 cents, the largest integer a
  /// JavaScript client holds exactly).
  static const max = Cents(9007199254740991);

  /// Adds two amounts.
  Cents operator +(Cents other) => Cents(value + other.value);

  /// Subtracts [other]. The result may be negative.
  Cents operator -(Cents other) => Cents(value - other.value);

  /// The same amount with the opposite sign.
  Cents operator -() => Cents(-value);

  /// [count] times this amount (for example members times the contribution).
  Cents operator *(int count) => Cents(value * count);

  /// Whether this is less than [other].
  bool operator <(Cents other) => value < other.value;

  /// Whether this is at most [other].
  bool operator <=(Cents other) => value <= other.value;

  /// Whether this is more than [other].
  bool operator >(Cents other) => value > other.value;

  /// Whether this is at least [other].
  bool operator >=(Cents other) => value >= other.value;

  /// Whether this is below zero.
  bool get isNegative => value < 0;

  /// Whether this is exactly zero.
  bool get isZero => value == 0;
}
