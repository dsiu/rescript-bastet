# Bastet Test Coverage Audit

This audit compares the original Bastet tests against the ReScript port at the test-case level. It checks test presence, concrete inputs, expected outputs, property generators, and harness behavior.

## Runnable JS Test Parity

Structured Mocha output was generated for both suites:

- Original: <https://github.com/Risto-Stevcev/bastet>, `./node_modules/.bin/mocha lib/js/bastet_js/test/Test_*.js --reporter json`
- Port: <https://github.com/dsiu/rescript-bastet>, branch `rescript-v12`, `node --stack-size=2000 ./node_modules/mocha/bin/_mocha __tests__/Test_*.res.mjs --reporter json`

Result after fixes:

- Original runnable JS tests: 317
- Port runnable tests: 329
- Original runnable JS tests missing from port: 0
- Port-only tests: 12, all under `Semantic audit regressions`

The full-title comparison confirms every original JS Mocha test case is present in the ReScript port with the same suite/test title. The 12 extras are compile/edge-case regressions added by the semantic audit.

## Fixes From Test Comparison

- `__tests__/MochaI.res`: `test` and `suite` now return callbacks, matching original `bastet_js/test/MochaI.ml`. The previous port registered tests immediately, flattening generated suite titles and making the harness semantically different from the original.
- `__tests__/Test_Float.res`: `ArbitraryFloat.make` now uses `Bastet_Float.Bounded.top` raised to `1.0 /. 150.0`, matching original `Test_JsFloat.ml`. The previous `1.0e50` upper bound was broader than the original test input domain and could trigger flaky floating-point law failures.
- `__tests__/Test_Semantic_Audit.res`: added a direct regression that documents the single ReScript `Float.Show` surface and its JavaScript `Float.toString` formatting.

## Generated Suite Inputs and Outputs

The original core tests in `bastet/test` and the original JS tests in `bastet_js/test` both exercise the shared generated suites from original `bastet/src/Test.ml`. The ReScript port implements those suites in `src/Bastet_Test*.res` and runs them through `__tests__/Test_*.res`.

Checked generated-suite examples:

| Family | Original inputs/outputs | Port status |
| --- | --- | --- |
| `Array` | `zip_with (*) [1;2;3] [4;5;6] -> [4;10;18]`, `zip`, fold left/right, fold_map int/list, unfold, traverse/sequence, show, alt append order | Equivalent in `src/Bastet_Test_Array.res`; same values and expected outputs. |
| `List` | fold left/right, fold_map int/list, unfold, traverse/sequence, show, alt append order | Equivalent in `src/Bastet_Test_List.res`; same values and expected outputs. Top-level suite name remains original `List'`. |
| `Option` | `\"foo\" |? Some \"bar\" -> \"bar\"`, `\"foo\" |? None -> \"foo\"`, fold/traverse/sequence cases | Equivalent in `src/Bastet_Test_Option.res`; same branch inputs and expected outputs. |
| `Default` | default fold and traverse over `[1;2;3;4;5]`, `[3;2;1]`, positive-int traversal | Equivalent in `src/Bastet_Test_Default.res`; same inputs and expected outputs. |
| `Bool`, `Int`, `Float`, `String` | law suites from original `Test.ml`; primitive arbitrary generators from JS wrappers | Equivalent. Float arbitrary bounds now match original JS wrapper. |
| `Array/List/Option/Result/Tuple` laws | functor/apply/applicative/monad/alt/foldable/traversable/eq/ord/show law tests | Equivalent by generated title match and source-level comparison of `T.check` examples and property wiring. |

## Direct JS Test Inputs and Outputs

These original `bastet_js/test` files contain direct Mocha tests outside the generated `Test.*` suites. Each has a matching ReScript test with the same concrete values and expected outputs:

| Original file | Port file | Input/output parity |
| --- | --- | --- |
| `Test_JsFunction.ml` | `__tests__/Test_Function.res` | Function law properties and explicit apply composition case `fn 3 4 -> -9` preserved. |
| `Test_JsFunctions.ml` | `__tests__/Test_Functions.res` | `scan_left` and `scan_right` array/list cases preserve `[1;2;3]`, initial accumulators `0`/`10`, and expected `[1;3;6]`, `[9;7;4]`, `[6;5;3]`, `[4;5;7]`. |
| `Test_JsTuple.ml` | `__tests__/Test_Tuple.res` | Foldable/traversable concrete cases preserve tuple inputs, positive/negative traversal branches, and expected singleton/empty lists. |
| `Test_JsDict.ml` | `__tests__/Test_Dict.res` | Annihilation, fold totals, and traversal over `{a,b,c}` preserve original expected values, including `None` on a missing traversal result. |
| `Test_JsResult.ml` | `__tests__/Test_Result.res` | Show/Eq/Ord concrete cases and `hush`/`note` utilities preserve all original inputs and expected `Ok`/`Error`/`Some`/`None` outputs. |
| `Test_JsDate.ml` | `__tests__/Test_Date.res` | Same `arb_date` property tests and same law predicates. |
| `Test_JsPromise.ml` | `__tests__/Test_Promise.res` | Promise functor/apply/applicative async property tests preserve `arb_nat`, 10ms delayed promise, comparison promise, and string conversion/composition functions. |
| `Test_JsPPX_Let.ml` | `__tests__/Test_PPX_Let.res` | Callback delays `100`/`200`, bind/both ordering tests, and below/above expectations preserved. |

## Core OCaml Test Coverage

The files under original `bastet/test` are wrappers around the same original generated `Bastet.Test.*` suites, using Alcotest/QCheck instead of Mocha/bs-jsverify. The ReScript port covers those same generated suite definitions through the JS-style test harness. No additional unique concrete test cases were found only in the OCaml wrapper files.

The original repo's native test path now passes through `make test`. Native-only wrapper differences are harness-level only:

- `AlcotestI.ml` maps the generic `Test.TEST` interface to Alcotest testables and cases.
- `QCheckI.ml` maps the generic `Test.QUICKCHECK` interface to QCheck/Alcotest properties.
- `Test_*.ml` files under `bastet/test` instantiate the same original generated suite modules as the JS wrappers, with equivalent arbitrary domains where applicable.

## Final Test Parity Checklist

- Every original runnable JS Mocha test full title is present in the ReScript port.
- Generated suite concrete inputs and expected outputs match original `bastet/src/Test.ml`.
- Direct JS test files have ReScript equivalents with matching inputs, outputs, and async ordering expectations.
- Original native Alcotest/QCheck wrappers define no extra standalone source expectations beyond the generated suite modules.
- Property-test arbitrary generators match the original JS wrappers where applicable.
- Port-only tests are documented semantic-audit regressions, not replacements for original tests.
