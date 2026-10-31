# Changelog

## 0.2.0

- **Breaking:** `JsonObject` no longer implements `Map<String, Object?>`, so
  a field is read through a reader, `raw`, or `fields`. To migrate:

  | 0.1.x | 0.2.0 |
  |---|---|
  | `obj['k']` | `obj.raw('k')`, or a typed reader |
  | `{...obj, 'k': v}` | `{...obj.fields, 'k': v}` |
  | `obj.entries` / `keys` / `values` | `obj.fields.entries` / `keys` / `values` |
  | `obj.containsKey(k)` | `obj.has(k)` |
  | `obj` passed where a `Map` is wanted | `obj.fields` |
  | `obj['k'] = v` | build a new object: `JsonObject.of({...obj.fields, 'k': v})` |

- Add `fields`: every field, as a map that refuses changes.
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
