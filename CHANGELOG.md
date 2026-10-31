# Changelog

## 0.2.1

- Add `deepFrozen()`: a copy all the way down that refuses changes. Every
  nested object and list is copied and made unmodifiable, field and list
  order are kept (so `jsonEncode` writes the same bytes), and a nested map
  comes back as a `Map<String, Object?>`. A value `jsonEncode` cannot write
  as it is (a key that is not a string, a `Set`, a `DateTime`, `NaN`) is a
  `JsonFieldException` whose `field` is its path, such as `a.b[2]`. A key is
  never turned into a string.
- `frozen()` and `JsonObject.unmodifiable` are unchanged and stay shallow.

## 0.2.0

- **Breaking:** `JsonObject` no longer implements `Map<String, Object?>`, so
  `obj['k']` and `obj['k'] = v` do not compile. To migrate:

  | 0.1.x | 0.2.0 |
  |---|---|
  | `obj['k']` | a typed reader (`obj.string('k')`, ...), or `obj.raw('k')` for a value read with a pattern or passed on |
  | `JsonObject.of({...obj, 'k': v})` | `obj.withFields({'k': v})` |
  | `JsonObject.of({...a, ...b})` | `JsonObject.merge([a, b])` |
  | `JsonObject.of({...obj}..remove('k'))` | `obj.without({'k'})` |
  | `obj.keys`, `obj.entries` | `obj.keys`, with a reader for each value |
  | `obj.containsKey(k)` | `obj.has(k)` |
  | `JsonObject.unmodifiable(obj)` | `obj.frozen()` |
  | `obj` passed to a parameter declared as a `Map` | `obj.asUncheckedMap()` |
  | `jsonEncode(obj)` | unchanged: it writes a `JsonObject` as it is |

- Add `withFields`, `JsonObject.merge` and `without`, which each make a new
  object from others, and `keys`.
- Add `frozen()`, a copy that refuses changes. Shallow: nested objects and
  lists are shared.
- Add `asUncheckedMap()`, a read-only map view for a parameter declared as a
  `Map`.
- `JsonObject` implements `Object`, so it is never null and an extension on
  `T extends Object` applies to it. (Without `implements Map`, it would
  otherwise be only an `Object?`.)

## 0.1.0

- Add `JsonObject`, an extension type over `Map<String, Object?>` that can
  only be made from raw data through a door that checks it
  (`JsonObject.decode`, `JsonObject.parse`), with typed readers (`string`,
  `integer`, `number`, `boolean`, `object`, `list`, `strings`, `objects`,
  each with an `OrNull` twin) plus `has` and `raw`.
- Add `JsonFieldException`, the `FormatException` a reader throws naming the
  field that is absent or the wrong shape, and the shape it wanted.
- Add `wholeNumber`, which reads `3` or `3.0` as an `int` and refuses
  fractions and doubles of 2^53 or more in size.
- Licensed Apache-2.0.
