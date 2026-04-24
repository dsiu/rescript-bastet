# Bastet ReScript Port Audit Index

This folder records the semantic audit of the ReScript 12.2 port against original Bastet core and JS-specific modules.

## Session Summary

The audit compared the ReScript port against original Bastet:

- Port: <https://github.com/dsiu/rescript-bastet>, branch `rescript-v12`
  - `src`
  - `__tests__`
- Original: <https://github.com/Risto-Stevcev/bastet>
  - `bastet/src`
  - `bastet_js/src`
  - `bastet/test`
  - `bastet_js/test`

Major conclusions:

- Public module coverage is complete for the audited Bastet families. No original public module family is unintentionally missing.
- The port is semantically equivalent at the function level for the audited public APIs, with intentional ReScript-target mappings documented.
- JS-specific original modules are represented idiomatically:
  - `JsArray` maps to `Bastet_Array` / `Bastet_ArrayF`.
  - `JsFloat` maps into the single ReScript-native `Bastet_Float` surface.
  - `Date`, `Dict`, and `Promise` map to `Bastet_Date`, `Bastet_Dict`, and `Bastet_Promise`.
- The single largest intentional semantic-surface difference is `Float.Show.show`: the port follows JavaScript/ReScript `Float.toString`, not OCaml `string_of_float`.
- Several implementation shapes are necessarily different because ReScript functions are uncurried by default. This affects point-free translations in `Verify`, `Functions`, and `Dict.Traversable`.
- The original JS test suite is covered by the ported ReScript tests at full-title level. The port has additional audit regression tests.
- The original native `make test` path was fixed separately and is documented as passing in the main semantic audit.

## Fixes And Decisions Captured

- `Bastet_Dict` raw JavaScript externals were fixed to bind through `globalThis` under ES modules.
- `MochaI` was fixed so generated tests return delayed callbacks, matching the original JS test harness behavior.
- `Test_Float` now uses the original JS float arbitrary range instead of a broader ad hoc bound.
- Missing original JS `PPX_Let` async ordering tests were ported.
- `Test_Semantic_Audit.res` was added for compile witnesses and edge-case regressions that are not direct original test copies.
- ReScript-native APIs are used instead of legacy `Js` and `Belt` modules, per repo instructions.

## Verification Snapshot

Latest verified port commands:

- `yarn build`: passed.
- `yarn test`: passed with 329 tests.
- `yarn coverage`: passed with 329 tests and overall coverage:
  - 79.65% statements
  - 95.80% branches
  - 73.36% functions
  - 79.65% lines

Original repo baseline documented in the main audit:

- `make test`: passed.
- BuckleScript/Mocha portion: 317 passing.
- Native dune/Alcotest/QCheck portion: passed.

## Audit Files

- `bastet-semantic-audit.md`
  - Main audit report.
  - Summarizes scope, method, module coverage, test additions, baseline commands, and final checklist.

- `bastet-api-coverage-matrix.csv`
  - Module/function coverage matrix.
  - Maps original core and JS-specific public items to ReScript port equivalents, including renamed-equivalent and port-only rows.

- `bastet-function-level-audit.md`
  - Function-level semantic audit.
  - Records checked public values/functions, argument order, branch behavior, return shape, and ReScript runtime differences.

- `bastet-test-coverage-audit.md`
  - Test parity audit.
  - Compares original JS/core test coverage against the ported tests, including concrete inputs, expected outputs, and generated law suites.

- `bastet-implementation-differences.md`
  - Intentional implementation-shape differences.
  - Documents where the ReScript source/test code is materially different from original Bastet while preserving behavior.

- `bastet-missing-features.md`
  - Missing feature and intentional mapping list.
  - Documents that no original public module family is unintentionally missing and explains JS-specific public-name mappings.

- `bastet-semantic-mismatches.md`
  - Fixed mismatch and residual risk list.
  - Records issues fixed during the audit and states that no remaining unintended behavior/signature mismatches are known.

## Reading Order

1. Start with `bastet-semantic-audit.md` for the overall conclusion.
2. Use `bastet-api-coverage-matrix.csv` to answer “does this original public item exist in the port?”
3. Use `bastet-function-level-audit.md` to answer “does this function preserve behavior and argument order?”
4. Use `bastet-test-coverage-audit.md` to answer “do ported tests cover original tests?”
5. Use `bastet-implementation-differences.md` to answer “why does this ReScript implementation look different?”
6. Use `bastet-missing-features.md` and `bastet-semantic-mismatches.md` for exceptions, omissions, and residual risks.
