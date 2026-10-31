# checked_json

A JSON object you only get by checking a value. Holding a `JsonObject` means
the value was looked at and found to be a JSON object, so nothing downstream
checks it again. Its fields are read through typed readers that say which
field was wrong and what it should have been.

```dart
import 'package:checked_json/checked_json.dart';

final user = JsonObject.decode('{"name": "Ada", "tags": ["maths"]}');

user.string('name');         // 'Ada'
user.strings('tags');        // ['maths']
user.integerOrNull('born');  // null: absent
user.integer('name');        // throws JsonFieldException: `name` is not an integer
```

## The doors in

The map inside a `JsonObject` is private, so code outside the library cannot
wrap an unchecked value in one. A value becomes one through a door that checks
it:

- `JsonObject.decode(text)` for wire text. A `FormatException` when the text
  is not JSON, or is JSON of another kind.
- `JsonObject.parse(value)` for a value that is already decoded. Null when it
  is not a JSON object.
- `object(k)` and `objects(k)` for an object nested in another.
- `JsonObject.of(map)` for an object you build yourself, for a `toJson`, from
  a map whose static type is already string-keyed.

## The readers

`string`, `integer`, `number`, `boolean`, `object`, `list`, `strings` and
`objects`. A plain reader requires its field and throws a
`JsonFieldException` naming the field and the shape it wanted. Its `OrNull`
twin takes an absent or null field as null, and still refuses one of the wrong
type. A default for an absent field is the caller's `??`, so the default sits
where it is used. `has(k)` tells a field present with a null value apart from
an absent one, and `raw(k)` gives a field as it was decoded.

`JsonFieldException` extends `FormatException`: a bad field is a condition
you're meant to catch, not a programming bug. Code that already catches
`FormatException` still catches it.

## What it guarantees, and what it doesn't yet

- **`as JsonObject` and `is JsonObject` do not check.** An extension type is
  erased at runtime, so `x as JsonObject` is `x as Map<String, Object?>` and
  fails with a `TypeError` where a door would have thrown a
  `FormatException`. Use `JsonObject.parse` instead, and the same goes for a
  `JsonObject` pattern.
- **For now a `JsonObject` is also a `Map<String, Object?>`.** It implements
  the map type, so `obj['k']` still compiles, reads a field without a check,
  and a `JsonObject` goes wherever a map is wanted. 0.2.0 removes this,
  leaving the readers as the only way to a field.
- **`parse` matches the map's runtime type.** `jsonDecode` always makes a
  string-keyed map, so its output is fine. A `Map<dynamic, dynamic>`, as YAML
  and Flutter platform channels deliver one, gives null even when every key is
  a string: copy it with `Map<String, Object?>.from` first.
- **Whole numbers are exact only below 2^53 in magnitude.** `integer` reads
  `3` or `3.0` (as some writers spell one, and as a web build reads every
  whole number) but never `3.5`. A double is taken only when its size is
  strictly below 2^53, where it stands for one whole number; 2^53 itself is
  refused, because `9007199254740993.0` decodes to it too.
- **Nested values are not deep-checked up front.** A door checks that the
  value is an object; each field is checked when its reader reads it.

## Licence

Apache-2.0. Copyright 2026 Enspyr Pty Ltd.
