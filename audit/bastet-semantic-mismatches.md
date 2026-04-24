# Bastet Semantic Mismatch List

## Fixed During This Audit

- `Bastet_Dict.merge`, `fold_left`, and `fold_left_keys` were exposed as `@val` externals but their raw JavaScript helpers were module-scoped `var` bindings under ES modules. Direct public calls could fail with `ReferenceError`. The raw helpers now assign to `globalThis`, matching the public external binding model.
- `Bastet_Float.Show.show` uses JavaScript `Float.toString`. This differs from original native OCaml `Float.Show`/`string_of_float`, but it is now documented as an intentional ReScript-target decision because the port keeps a single native JS float surface and matches original `JsFloat.Show`.
- The ReScript port was missing the original JS `PPX_Let` async behavior tests. `__tests__/Test_PPX_Let.res` now ports the original four callback-order tests and preserves the original `bind`/`both` semantics under ReScript's uncurried function model.
- `__tests__/MochaI.res` registered generated tests immediately instead of returning delayed callbacks like the original `bastet_js/test/MochaI.ml`. This flattened generated suite titles and made the test harness semantically different. The port now returns callbacks for both `test` and `suite`.
- `__tests__/Test_Float.res` used `1.0e50` as the arbitrary upper bound instead of the original `Float.Bounded.top ** (1. /. 150.)` input domain. The generator now matches the original bound using `Math.pow(..., ~exp=1.0 /. 150.0)`.

## Remaining Mismatches

No remaining unintended behavior or signature mismatches are known after the current audit pass.

## Residual Risks

- `Dual`, `Endo`, and the broad `Functions` helper namespace still have lower statement/function coverage than the smaller primitive modules. They have compile witnesses and source-equivalence review, but future work should add more direct example tests for their less commonly used helpers.
- `Demo.res` is port-only example code under `src`; it is not exported by `Bastet.res` and no production module depends on it, but it remains a package-visible source file rather than an original Bastet API.
