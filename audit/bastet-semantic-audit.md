# Bastet ReScript Port Semantic Audit

## Scope

Audited the ReScript 12.2 port against original Bastet:

- Port: <https://github.com/dsiu/rescript-bastet>, branch `rescript-v12`
  - `src`
  - `__tests__`
- Original: <https://github.com/Risto-Stevcev/bastet>
  - `bastet/src`
  - `bastet_js/src`
  - `bastet/test`
  - `bastet_js/test`

The ReScript API reference used for syntax and stdlib decisions is the official LLM entrypoint: <https://rescript-lang.org/llms/manual/llms.txt>.

## Method

- Extracted candidate public API with:
  - `rg -n "^(module type|module|type|let|external|include)\b" bastet/src bastet_js/src`
  - `rg -n "^(module type|module|type|let|external|include)\b" src`
- Compared original core modules with `Bastet_*` ReScript modules and `Bastet.res` exports.
- Compared original JS modules with ReScript equivalents:
  - `Date.ml` -> `Bastet_Date.res`
  - `Dict.ml` -> `Bastet_Dict.res`
  - `Promise.ml` -> `Bastet_Promise.res`
  - `JsArray.ml` -> `Bastet_Array.res` / `Bastet_ArrayF.res`
  - `JsFloat.ml` -> `Bastet_Float.res`
- Audited port-only source files:
  - `Bastet.res` is the public aggregate.
  - `BsBastet.res` is a compatibility alias that only includes `Bastet`.
  - `Demo.res` is an unreferenced example/demo module and is not exported by `Bastet.res`.
- Validated module type and functor compatibility with build-time witnesses in `__tests__/Test_Semantic_Audit.res`.
- Ported the original missing JS `PPX_Let` async tests to `__tests__/Test_PPX_Let.res`.
- Added targeted regressions for `Interface`, `Array`, `Dict`, `Option`, `Result`, `Tuple`, and `Date` edge behavior.

## Findings

- Public module coverage is complete for the requested families: `Interface`, `Verify`, `Test`, `Array`, `ArrayF`, `List`, `Option`, `Result`, `Function`, `Functions`, `Tuple`, `Bool`, `Int`, `Float`, `String`, `Default`, `Endo`, `Dual`, `Infix`, `Functors`, `PPX_Let`, `Date`, `Dict`, and `Promise`.
- `JsArray` is a renamed-equivalent mapping through `Bastet_Array` / `Bastet_ArrayF`.
- `JsFloat` is intentionally collapsed into `Bastet_Float`; the port keeps one ReScript-native float module and uses JavaScript number formatting for `Float.Show`.
- `BsBastet` is a port-only compatibility namespace alias; it does not add behavior.
- `Demo.res` is port-only example code outside the aggregate public API; it has no original source equivalent and no production module depends on it.
- One direct public-call bug was fixed in `Bastet_Dict.res`: raw ES module helpers now bind through `globalThis` so exported externals are callable outside the defining module.
- `Float.Show.show` intentionally follows ReScript/JavaScript `Float.toString` behavior instead of original native OCaml `string_of_float` formatting. This preserves the JS-specific Bastet behavior and avoids a separate `JsFloat` surface in the ReScript port.
- No remaining missing original features or known semantic mismatches are documented.

## Test Coverage Added

- `__tests__/Test_PPX_Let.res`
  - ports the original four async `PPX_Let` tests for `bind` and `both`
  - verifies callback result ordering for faster/slower left-hand computations
- `__tests__/Test_Semantic_Audit.res`
  - compile witnesses for representative functor outputs
  - direct edge/regression tests for ordering conversion, array zip truncation, empty zip, dict merge precedence, dict insert, option eliminator order, result eliminator order, result ordering, tuple helpers, date ordering, and ReScript-native float display formatting

## Baseline Commands

Original repo:

- `make test`: passed after fixing the original repo's native test command and native test compatibility.
- BuckleScript/Mocha portion: passed, `317 passing`.
- Native dune/Alcotest/QCheck portion: passed.

ReScript port:

- `yarn build`: passed.
- `yarn test`: passed, `329 passing`.
- `yarn coverage`: passed, `329 passing`, overall coverage `79.65%` statements / `95.80%` branches / `73.36%` functions / `79.65%` lines.

## Final Checklist

- API coverage matrix exists: `audit/bastet-api-coverage-matrix.csv`.
- Function-level source audit exists: `audit/bastet-function-level-audit.md`.
- Test coverage audit exists: `audit/bastet-test-coverage-audit.md`.
- Implementation-differences audit exists: `audit/bastet-implementation-differences.md`.
- Missing feature list exists: `audit/bastet-missing-features.md`.
- Semantic mismatch list exists: `audit/bastet-semantic-mismatches.md`.
- Original JS-specific modules are mapped and tested where applicable.
- Law-based property tests run through the existing `Bastet_Test` and `Bastet_Verify` suites.
- Additional example regressions cover direct public edge cases not previously tested.
