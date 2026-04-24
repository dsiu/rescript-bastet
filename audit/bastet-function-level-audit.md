# Bastet Function-Level Semantic Audit

This audit records source-level comparison of public values/functions in the original Bastet modules against the ReScript port. It is separate from test results: every row below was checked against the original implementation for argument order, return shape, branch behavior, and ReScript runtime/std-lib differences.

## Core Helpers and Interfaces

| Module | Public values/functions checked | Result |
| --- | --- | --- |
| `Interface` | `invert`, `int_to_ordering`, `unsafe_compare`, `Ordering.less_than`, `greater_than`, `less_than_or_equal`, `greater_than_or_equal` | Equivalent. ReScript polymorphic variant tags use `#tag`; branch ordering and comparison semantics match. |
| `Function` | `flip`, `const`, `Functor.map`, `Apply.apply`, `Semigroupoid.compose`, `Category.id`, `Invariant.imap`, `Profunctor.dimap`, `Contravariant.cmap`, `Bicontravariant.bicmap`, infix composition | Equivalent. Curried OCaml functions were translated to explicit uncurried ReScript wrappers that return functions where the original returned functions. |
| `Infix` | all exported operators: `<:>`, `<$>`, `<@>`, `<*>`, `>>=`, `=<<`, `>=>`, `<=<`, `<|>`, `<.`, `>.`, `=|=`, order operators, numeric operators, extend/bifunctor/lattice operators | Equivalent. `=<<` keeps original semantic order: function first, monadic value second, implemented through `flat_map(monadic, function)`. |
| `PPX_Let` | `return`, `bind`, `map`, `both`, `Open_on_rhs.return` from `Make` | Equivalent. Verified source-level against original and ported the four original async order tests. |

## Primitive Instances

| Module | Public values/functions checked | Result |
| --- | --- | --- |
| `Bool` | `Conjunctive.append/empty`, `Disjunctive.append/empty`, `Eq.eq`, `Ord.compare`, `Bounded.top/bottom`, `join`, `meet`, `not`, `implies`, `Show.show`, infix operators | Equivalent. Boolean operators, bounds, ordering, and Heyting/Boolean behavior match original source. |
| `Int` | arithmetic `append/empty/invert/subtract/divide/modulo`, `Eq.eq`, `Ord.compare`, `Bounded.top/bottom`, `Show.show`, semiring/ring/euclidean operations, infix operators | Equivalent. ReScript integer operators map to the same JavaScript integer semantics used by the port target; argument order preserved. |
| `Float` | `approximately_equal`, additive/multiplicative/subtractive/divisive operations, `Eq.eq`, `Ord.compare`, `Bounded`, `Show`, semiring/ring/division/euclidean/field operations, infix operators | Equivalent for the ReScript/JS target. `Float.Show.show` intentionally uses ReScript `Float.toString`, matching original `bastet_js/src/JsFloat.ml`; original native OCaml `string_of_float` formatting is not preserved as a separate port surface. |
| `String` | `append`, `empty`, `invert`, `Eq.eq`, `Ord.compare`, `Show.show`, infix operators | Equivalent. Concatenation, empty string, identity inverse, and comparison behavior match. |
| `Date` | `Magma.append`, `Monoid.empty`, `Eq.eq`, `Ord.compare`, infix operators | Equivalent. Both implementations operate on epoch milliseconds. |

## Containers and Data Types

| Module | Public values/functions checked | Result |
| --- | --- | --- |
| `Array` / `ArrayF` | `zip_with`, `zip`, `Functor.map`, `Alt.alt`, `Apply.apply`, `Applicative.pure`, `Monad.flat_map`, `Foldable.fold_left/fold_right/fold_map`, `Unfoldable.unfold`, `Traversable.traverse/sequence`, `Eq.eq`, `Ord.compare`, `Show.show`, `Invariant.imap`, `Extend.extend`, infix operators | Equivalent. ReScript `Array.reduceRight` callback order was checked and adjusted in the comparison: the port correctly flips accumulator/current where needed. `zip_with` preserves original shorter-input truncation and empty behavior. |
| `List` | `Functor.map`, `Alt.alt`, `Apply.apply`, `Applicative.pure`, `Monad.flat_map`, `Plus.empty`, `Alternative`, `Foldable.fold_left/fold_right/fold_map`, `Unfoldable.unfold`, `Traversable.traverse/sequence`, `Eq.eq`, `Show.show`, infix operators | Equivalent. ReScript `List.reduceReverse` callback order was checked; traverse/fold-right preserve original right-to-left behavior. |
| `Option` | `maybe`, `getWithDefault`, all algebra lifting functors, `Functor.map`, `Apply.apply`, `Applicative.pure`, `Monad.flat_map`, `Alt.alt`, `Plus.empty`, `Alternative`, `Foldable`, `Traversable`, `Eq`, `Ord`, `Show`, `|?` | Equivalent. Branch behavior for `Some`/`None`, `None < Some`, and fallback/default order match. |
| `Result` | `result`, all algebra lifting functors, `Functor.map`, `Bifunctor.bimap`, `Apply.apply`, `Applicative.pure`, `Monad.flat_map`, `Alt.alt`, `Extend.extend`, `Show`, `Eq`, `Ord`, `Bounded`, `Many_Valued_Logic.*`, `Foldable`, `Bifoldable`, `Traversable`, `Bitraversable`, `Infix`, `Choose.choose`, `Unsafe.from_ok/from_error`, `is_ok`, `is_error`, `note`, `hush` | Equivalent. `Error < Ok`, Ok-biased map/apply/monad behavior, both-side traversal, and unsafe exception behavior are preserved; ReScript uses `throw(Invalid_argument(...))` for the original `raise`. |
| `Tuple` | `first`, `second`, `swap`, `curry`, `uncurry`, algebra functors, `Functor.map`, `Apply.apply`, `Applicative.pure`, `Monad.flat_map`, `Foldable`, `Traversable`, `Eq`, `Semigroupoid.compose`, `Show`, `Bifunctor`, `Biapply`, `Biapplicative`, `Bifoldable`, `Bitraversable`, infix operators | Equivalent. Note that original `swap` is a two-argument helper (`a -> b -> b * a`), not a tuple-taking helper; the port preserves that exact shape. |
| `Dual` | `append` for fixed and higher-kinded algebras, `empty`, `Functor.map`, `Applicative.apply/pure`, `Monad.flat_map`, `Foldable`, `Traversable`, infix operators | Equivalent. Append order remains reversed (`b <> a`) for all fixed and higher-kinded variants. |
| `Endo` | `Magma.append`, `Semigroup`, `Monoid.empty`, infix operators | Equivalent. Composition order is original `a <. b` behavior with identity as `Function.Category.id`. |
| `Dict` | `fold_left`, `fold_left_keys`, `merge`, `unsafe_from_object`, `insert`, `Functor.map`, `Apply.apply`, `Alt.alt`, `Plus.empty`, `Foldable`, `Traversable.traverse_with_index/traverse/sequence` | Equivalent after fix. Direct public externals now resolve through `globalThis`; merge preserves original left-dict key precedence and `insert` mutates/returns the same dict. |
| `Promise` | `Functor.map`, `Apply.apply`, `Applicative.pure` | Equivalent. ReScript implementation uses `Promise.then`/`Promise.resolve`; promise auto-flattening limitation remains documented as in original. |

## Derived Helpers

| Module | Public values/functions checked | Result |
| --- | --- | --- |
| `Default` | `Fold_Map.fold_map_default_left/right`, `Fold_Map_Any`, `Fold_Map_Plus`, `Fold.fold_left_default/fold_right_default`, `Sequence.sequence_default`, `Traverse.traverse_default` | Equivalent. Endo/Dual-Endo derivations preserve left/right fold orientation. |
| `Functions.Monoid` | `power`, `guard` | Equivalent. Handles `p <= 0`, `p == 1`, even exponent squaring, and odd exponent multiplication like original. |
| `Functions.Functor` | `void`, `void_right`, `void_left`, `flap` | Equivalent. ReScript placeholders were checked to preserve original constant/flap behavior. |
| `Functions.Apply` | `apply_first`, `apply_second`, `apply_both`, `lift2`, `lift3`, `lift4`, `lift5`, infix `<*` and `*>` | Equivalent. Source-level review confirmed the ReScript translations preserve original `const <$> a <*> b`, `const id <$> a <*> b`, tuple construction, and lift argument order. |
| `Functions.Apply'` | `apply_const`, `apply_first`, `apply_second`, `apply_both` | Equivalent. Function applicative wrappers preserve original environment threading. |
| `Functions.Applicative` | `liftA1`, `when_`, `unless` | Equivalent. Boolean guard behavior and unit-returning pure fallback match. |
| `Functions.Monad` | `flatten`, `compose_kliesli`, `compose_kliesli_flipped`, `if_m`, `liftM1`, `ap`, `when_`, `unless` | Equivalent. `=<<` and `<=<` direction was explicitly checked against original operator definitions. |
| `Functions.Foldable` | `Semigroup.surround_map/surround`, `Monoid.fold/intercalate`, `Applicative.traverse'/sequence'`, `Plus.one_of`, `Monad.fold_monad` | Equivalent. Fold direction, separator placement, and monadic accumulator order match original. |
| `Functions.Traversable` | `Internal.State_Left/State_Right`, `Map_Accum.map_accum_left/right`, `Scan.scan_left/scan_right` | Equivalent. State application order matches original left and right scan behavior. |
| `Functors` | all namespace modules under `ArrayF`, `ListF`, `OptionF`, `ResultF`, `TupleF`, and `FunctionF` | Equivalent. These are alias/instantiation namespaces; each referenced implementation module above was checked at value level. |
| `Test` / `Verify` | law predicates and generated test-suite helpers | Equivalent. Source-level comparison confirms the same law names, predicate argument order, and framework abstraction roles; runtime tests exercise these predicates broadly. |
| `Bastet` aggregate | re-exports `Array`, `ArrayF`, `Bool`, `Date`, `Default`, `Dict`, `Dual`, `Endo`, `Float`, `Function`, `Functions`, `Functors`, `Infix`, `Int`, `Interface`, `List`, `Option`, `PPX_Let`, `Promise`, `Result`, `String`, `Test`, `Tuple`, `Verify` | Equivalent aggregate namespace for the port. Every re-export maps to an audited module above. |
| `BsBastet` aggregate | `include Bastet` | Port-only compatibility alias. Adds no behavior and therefore cannot diverge semantically from `Bastet`. |
| `Demo` | example values and console logging for traversable, show, Kleisli composition, fold_map, infix map, and semigroup composition | Port-only demo module. It is not re-exported by `Bastet.res` and is not part of the original public API surface. |

## Intentional Non-Semantic Differences

- OCaml/Reason curried functions are represented as explicit uncurried ReScript functions where required by ReScript 12.2, while public argument order is preserved.
- OCaml `raise (Invalid_argument ...)` in `Result.Unsafe` becomes ReScript `throw(Invalid_argument(...))`.
- Original `Js.Array`, `Js.Dict`, `Js.Promise`, and `Js.Date` surfaces are mapped to ReScript `array`, `dict`, `promise`, and `Date.t`.
- The original `JsArray` module is represented by `Bastet_Array`/`Bastet_ArrayF`; the original `JsFloat` behavior is represented by the single ReScript-native `Bastet_Float` module.
- `BsBastet` and `Demo` are port-only source modules. `BsBastet` is only an alias; `Demo` is example code outside the aggregate API.
