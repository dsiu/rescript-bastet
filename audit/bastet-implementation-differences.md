# Bastet Implementation Differences

This file documents places where the ReScript port is materially different from original Bastet implementation shape, even when the public behavior is equivalent or intentionally changed for the ReScript target.

These are not known semantic mismatches. Confirmed behavior is tracked in `bastet-semantic-audit.md`, `bastet-function-level-audit.md`, and `bastet-test-coverage-audit.md`. Known defects or intentional semantic differences are tracked in `bastet-semantic-mismatches.md`.

## Source Differences

### Array

- `src/Bastet_Array.res` uses ReScript native `Array` APIs as the implementation backend.
  - Original core used OCaml arrays.
  - Original JS-specific `bastet_js/src/JsArray.ml` used `Js.Array` and `Belt.Array`.
  - This is intentional because the port targets ReScript 12 and avoids legacy `Js`/`Belt` modules.

- `src/Bastet_ArrayF.res` contains more manual implementations for `zip_with`, `fold_right`, `traverse`, and `Ord.compare`.
  - Original Bastet can rely on OCaml/Reason curried functions and `ArrayLabels`.
  - The port uses ReScript arrays, explicit callback argument order, refs, and `Array.getUnsafe` where needed.
  - The expected behavior is covered by original translated tests plus audit edge cases for shorter `zip_with` and empty `zip`.

### Dict

- `src/Bastet_Dict.res` assigns raw JavaScript helpers to `globalThis.bastet_dict_*`.
  - Original `bastet_js/src/Dict.ml` used module-scoped raw JavaScript `var fold_left`, `var fold_left_keys`, and `var merge` with BuckleScript `[@@bs.val]` externals.
  - Under ReScript ES modules, public `@val external` bindings need globally visible names, so the port intentionally uses `globalThis`.

- `src/Bastet_Dict.res` expands `traverse_with_index` with an `insert_flipped` helper.
  - Original used point-free applicative style: `Function.flip (insert k) <$> acc <*> f k v`.
  - The port preserves the applicative behavior but uses an explicit wrapper because ReScript functions are uncurried by default.

- `src/Bastet_Dict.res` rewrites `traverse`.
  - Original: `Obj.magic (traverse_with_index <. Function.const)`.
  - Port: `Obj.magic((f, ta) => traverse_with_index((_, a) => f(a), ta))`.
  - The original point-free form does not translate cleanly under ReScript uncurried calling; a direct translation can compile into an extra function layer at runtime.

### Promise

- `src/Bastet_Promise.res` uses ReScript native `promise<'a>` and `Promise.then` / `Promise.resolve`.
  - Original JS-specific `bastet_js/src/Promise.ml` used `Js.Promise.t`, `Js.Promise.then_`, and `Js.Promise.resolve`.
  - Behavior is intended to match the original Promise functor/apply/applicative surface while exposing idiomatic ReScript bindings.

### Date

- `src/Bastet_Date.res` uses ReScript native `Date.t`, `Date.fromTime`, and `Date.getTime`.
  - Original JS-specific `bastet_js/src/Date.ml` used `Js.Date.t`, `Js.Date.fromFloat`, and `Js.Date.getTime`.
  - Behavior is preserved by comparing and combining dates through epoch milliseconds.

### Float

- `src/Bastet_Float.res` uses JavaScript-native float bounds and formatting.
  - Original core `bastet/src/Float.ml` used `max_float`, `min_float`, and `string_of_float`.
  - Original JS-specific `bastet_js/src/JsFloat.ml` exposed `Js.Float.toString`.
  - The port intentionally keeps a single ReScript-native `Float` surface, so `Float.Show.show` follows JavaScript/ReScript `Float.toString` formatting rather than OCaml `string_of_float`.

### Verify

- `src/Bastet_Verify.res` adapts curried OCaml law expressions to ReScript uncurried functions.
  - `Functor.composition` original:
    `E.eq (F.map (f <. g) a) ((F.map f <. F.map g) a)`.
  - Port:
    `E.eq(F.map("<."(f, g), a), "<."(F.map(f, _), F.map(g, _))(a))`.
  - The placeholder calls turn uncurried `F.map` into unary functions that can be composed.

- `src/Bastet_Verify.res` adapts `Apply.associative_composition`.
  - Original:
    `E.eq (A.map Function.Semigroupoid.compose f <*> g <*> h) (f <*> (g <*> h))`.
  - Port:
    `E.eq(A.map(a => Function.Semigroupoid.compose(a, _), f)->"<*>"(g)->"<*>"(h), f->"<*>"(g->"<*>"(h)))`.
  - The wrapper `Function.Semigroupoid.compose(a, _)` preserves the curried original law under ReScript's uncurried function model.

### Functions

- `src/Bastet_Functions.res` uses explicit placeholder wrappers in applicative helpers.
  - Examples include `const(x, _)`, `f(x, _)`, and `x => Fn.apply_second(x, _)`.
  - Original Bastet used direct curried applicative style such as `const <$> a <*> b` and `Fn.apply_second <. f`.
  - These wrappers are required to preserve the same argument order and composition behavior in ReScript.

- `src/Bastet_Functions.res` rewrites `Foldable.Applicative.traverse'`.
  - Original: `F.fold_right (Fn.apply_second <. f) (A.pure ()) fa`.
  - Port builds the composed callback explicitly before passing it to `fold_right`.

### Infix

- `src/Bastet_Infix.res` defines `">."` as `(f, g) => S.compose(g, f)`.
  - Original Reason implementation used `( >. ) g f = S.compose f g`.
  - The resulting behavior is equivalent; the parameter naming/order is adapted to ReScript's escaped infix operator functions.

### Port-Only Source Files

- `src/Bastet.res` is the ReScript aggregate namespace and re-exports the mapped module families.
- `src/BsBastet.res` is a compatibility namespace alias for older code that imports `BsBastet`.
- `src/Demo.res` is example/demo code and has no original Bastet API equivalent. It is not re-exported by `Bastet.res`.

## Test Differences

### Mocha Harness

- `__tests__/MochaI.res` implements the original JS Mocha test adapter in ReScript.
  - Original `bastet_js/test/MochaI.ml` used `ListLabels.iter` and BuckleScript Mocha bindings.
  - The port uses a local `listIter` helper and `RescriptMocha`.
  - `test` and `suite` return delayed callbacks, matching the original registration behavior.

### Float Tests

- `__tests__/Test_Float.res` preserves the constrained JS float generator range.
  - Original `Test_JsFloat.ml` used `Float.Bounded.top ** (1. /. 150.)`.
  - The port uses `Math.pow(Bastet_Float.Bounded.top, ~exp=1.0 /. 150.0)`.
  - This keeps property inputs in the same practical range while retaining the ReScript-native single `Float` surface.

### Promise Tests

- `__tests__/Test_Promise.res` ports original Promise async property tests to native ReScript promises.
  - Original used `Js.Promise`, `Js.Global.setTimeout`, and `Obj.magic` to adapt promise equality into async properties.
  - The port uses `Promise`, `setTimeout`, and the same `Obj.magic` strategy where the property harness requires it.

### PPX_Let Tests

- `__tests__/Test_PPX_Let.res` ports callback-order tests from original `Test_JsPPX_Let.ml`.
  - Original used `Js.Date.now` and `Js.Global.setTimeout`.
  - The port uses `perf_hooks.performance.now` and `setTimeout`.
  - The same delay values and below/above ordering expectations are preserved.

### Result Tests

- `__tests__/Test_Result.res` uses `JSON.stringifyAny` and ReScript stdlib aliases.
  - Original JS tests used `Js.Json.stringifyAny`, `Js.Option`, and `Belt.Result`.
  - The port follows repo rules by avoiding legacy `Js` and `Belt` modules.

### Audit Regression Tests

- `__tests__/Test_Semantic_Audit.res` is port-only.
  - It is not a direct original test translation.
  - It adds compile witnesses and edge-case regressions found during the audit, including public functor instantiation, argument-order traps, dict merge precedence, `Float.Show` formatting, and selected interface conversions.

## Verification Snapshot

Latest local verification after this comparison:

- `yarn build` passed.
- `yarn test` passed with 329 tests.

