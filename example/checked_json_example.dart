import 'dart:convert';

import 'package:checked_json/checked_json.dart';

void main() {
  // Wire text comes in through the door that checks it.
  final user = JsonObject.decode(
    '{"name": "Ada", "born": 1815.0, "tags": ["maths"], '
    '"home": {"city": "London"}}',
  );

  print(user.string('name')); // Ada
  print(user.integer('born')); // 1815, though written 1815.0
  print(user.strings('tags')); // [maths]
  print(user.object('home').string('city')); // London

  // An absent field is null to an `OrNull` reader; the default is yours.
  print(user.stringOrNull('email') ?? 'no email'); // no email

  // A field of the wrong shape is refused, and the refusal names it.
  try {
    user.integer('name');
  } on JsonFieldException catch (e) {
    print(e.message); // `name` is not an integer
  }

  // A value already decoded, whose kind is not known until it is looked at.
  final Object? decoded = jsonDecode('[1, 2]');
  print(JsonObject.parse(decoded)); // null: a list, not an object

  // An object we build ourselves, for a `toJson`.
  const reply = JsonObject.of({'ok': true});
  print(jsonEncode(reply)); // {"ok":true}
}
