import 'dart:convert';

/// A JSON object: string keys, JSON values, read through the readers below.
/// Holding one means the shape was checked, so nothing downstream checks it
/// again.
///
/// The map inside is private, so code outside this library cannot wrap an
/// unchecked value in one. A value from outside becomes one through a door
/// that checks it: [JsonObject.decode] for wire text, [parse] for a value
/// that is already decoded, and [object] or [objects] for one nested in
/// another. An object we build ourselves, for a `toJson`, is [JsonObject.of]
/// a map whose static type is already string-keyed.
///
/// A plain reader requires its field and throws [JsonFieldException] naming it;
/// its `OrNull` twin takes an absent or null field as null and still rejects
/// one of the wrong type. A default for an absent field is the caller's `??`,
/// so the default sits where it is used.
///
/// For now it also implements `Map<String, Object?>`, so a field can still be
/// read by key and a [JsonObject] goes wherever a map is wanted. A later
/// version drops that, leaving the readers as the only way to a field.
///
/// The type is erased at runtime: `x as JsonObject` is
/// `x as Map<String, Object?>`, and fails with a [TypeError] where a door
/// would have thrown a [FormatException]. Use [parse] instead, and the same
/// goes for `is JsonObject` and a `JsonObject` pattern.
extension type const JsonObject._(Map<String, Object?> _fields)
    implements Map<String, Object?> {
  /// An object built from a map we wrote, as a `toJson` returns it. A map
  /// literal is one; so is any map whose type already says string keys.
  const JsonObject.of(Map<String, Object?> fields) : this._(fields);

  /// A copy of [fields] that refuses changes, for an object kept for the
  /// life of a conversation. Nested objects and lists are shared, not
  /// copied.
  factory JsonObject.unmodifiable(Map<String, Object?> fields) =>
      JsonObject._(Map.unmodifiable(fields));

  /// The object with no fields.
  static const empty = JsonObject._({});

  /// [text] decoded as a JSON object. A [FormatException] when it is not
  /// JSON, or is JSON of another kind (a list, a string, a number, null).
  factory JsonObject.decode(String text) =>
      parse(jsonDecode(text)) ??
      (throw const FormatException('not a JSON object'));

  /// [value] as a JSON object, or null when it is anything else. For a
  /// value that is already decoded: one element of a decoded list, or a
  /// message whose kind is not known until it is looked at.
  ///
  /// The test is the map's runtime type, which `jsonDecode` always makes
  /// string-keyed. A `Map<dynamic, dynamic>`, as YAML and Flutter platform
  /// channels deliver one, is not a JSON object here even when every key is
  /// a string: copy it with `Map<String, Object?>.from` first.
  static JsonObject? parse(Object? value) => switch (value) {
        final Map<String, Object?> m => JsonObject._(m),
        _ => null,
      };

  /// Whether [k] is present, even with a null value.
  bool has(String k) => _fields.containsKey(k);

  /// The field as it was decoded, for a value whose shape the caller reads
  /// with a pattern (one of several kinds) or passes on untouched.
  Object? raw(String k) => _fields[k];

  String string(String k) => switch (_fields[k]) {
        final String s => s,
        _ => throw JsonFieldException(k, 'a string'),
      };
  String? stringOrNull(String k) => _fields[k] == null ? null : string(k);

  /// A whole number, as [wholeNumber] reads one.
  int integer(String k) =>
      wholeNumber(_fields[k]) ?? (throw JsonFieldException(k, 'an integer'));
  int? integerOrNull(String k) => _fields[k] == null ? null : integer(k);

  /// Any finite number, `3` or `3.5`. JSON has no infinity, but a literal
  /// too large for a double (`1e400`) decodes as one, and `toInt` throws on
  /// it.
  num number(String k) => switch (_fields[k]) {
        final num n when n.isFinite => n,
        _ => throw JsonFieldException(k, 'a finite number'),
      };
  num? numberOrNull(String k) => _fields[k] == null ? null : number(k);

  bool boolean(String k) => switch (_fields[k]) {
        final bool b => b,
        _ => throw JsonFieldException(k, 'true or false'),
      };
  bool? booleanOrNull(String k) => _fields[k] == null ? null : boolean(k);

  JsonObject object(String k) =>
      parse(_fields[k]) ?? (throw JsonFieldException(k, 'an object'));
  JsonObject? objectOrNull(String k) => _fields[k] == null ? null : object(k);

  List<Object?> list(String k) => _list(k, 'a list');
  List<Object?>? listOrNull(String k) => _fields[k] == null ? null : list(k);

  List<String> strings(String k) => [
        for (final x in _list(k, 'a list of strings'))
          x is String ? x : throw JsonFieldException(k, 'a list of strings'),
      ];
  List<String>? stringsOrNull(String k) =>
      _fields[k] == null ? null : strings(k);

  List<JsonObject> objects(String k) => [
        for (final x in _list(k, 'a list of objects'))
          parse(x) ?? (throw JsonFieldException(k, 'a list of objects')),
      ];
  List<JsonObject>? objectsOrNull(String k) =>
      _fields[k] == null ? null : objects(k);

  /// The field as a list, or a [JsonFieldException] saying it should have
  /// been [wanted], so a reader of a list of something names the whole shape
  /// whichever way the field is wrong.
  List<Object?> _list(String k, String wanted) => switch (_fields[k]) {
        final List<Object?> l => l,
        _ => throw JsonFieldException(k, wanted),
      };
}

/// A field that is absent, or present but not the shape its reader asked
/// for.
///
/// A [FormatException], so code that catches those still does. A reader that
/// wants to tell "this field is wrong" apart from any other failure catches
/// this type alone.
final class JsonFieldException extends FormatException {
  JsonFieldException(this.field, this.wanted)
      : super('`$field` is not $wanted');
  final String field;

  /// What the field should have been, as a phrase: `a string`, `a list`.
  final String wanted;
}

/// [v] as a whole number: `3`, or `3.0` as some writers spell one (and as a
/// web build reads every whole number), but never `3.5`; null for anything
/// else. A double is taken only below 2^53 in size, where it stands for one
/// whole number: 2^53 is also what `9007199254740993.0` decodes to, and far
/// past it `toInt` clamps to the biggest int without saying so.
int? wholeNumber(Object? v) => switch (v) {
      final int n => n,
      final double d
          when d == d.truncateToDouble() && d > -_twoTo53 && d < _twoTo53 =>
        d.toInt(),
      _ => null,
    };

/// 2^53, the first size at which a double no longer pins down one whole
/// number. JavaScript's `Number.MAX_SAFE_INTEGER` is one less, for the same
/// reason.
const _twoTo53 = 9007199254740992.0;
