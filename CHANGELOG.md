# Changelog

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
