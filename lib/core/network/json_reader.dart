import 'package:tallyvel/core/failures/failure.dart';
import 'package:tallyvel/core/money/cents.dart';
import 'package:tallyvel/core/time/calendar_date.dart';

/// A decoded JSON object.
typedef Json = Map<String, Object?>;

/// Reads what the API sent, throwing [UnexpectedFailure] (the app and the API
/// disagree about the contract) instead of a cast error when it is not the
/// shape the app expects. Nothing here keeps the value in the error.
Json asJson(Object? value) =>
    value is Map ? Json.from(value) : throw const UnexpectedFailure();

/// [value] as a list of objects.
List<Json> asJsonList(Object? value) => value is List
    ? [for (final item in value) asJson(item)]
    : throw const UnexpectedFailure();

/// A required string.
String readString(Json json, String key) => switch (json[key]) {
  final String value => value,
  _ => throw const UnexpectedFailure(),
};

/// A string that may be absent or null.
String? readStringOrNull(Json json, String key) => switch (json[key]) {
  final String value => value,
  _ => null,
};

/// A required whole number.
int readInt(Json json, String key) => switch (json[key]) {
  final int value => value,
  _ => throw const UnexpectedFailure(),
};

/// An amount: the API sends every amount as integer cents.
Cents readCents(Json json, String key) => Cents(readInt(json, key));

/// A required instant, in UTC.
DateTime readDateTime(Json json, String key) =>
    DateTime.tryParse(readString(json, key))?.toUtc() ??
    (throw const UnexpectedFailure());

/// A South African calendar day (`YYYY-MM-DD`) that may be null.
CalendarDate? readDateOrNull(Json json, String key) => switch (json[key]) {
  final String value =>
    CalendarDate.tryParse(value) ?? (throw const UnexpectedFailure()),
  _ => null,
};

/// An object that may be null.
Json? readJsonOrNull(Json json, String key) =>
    json[key] == null ? null : asJson(json[key]);
