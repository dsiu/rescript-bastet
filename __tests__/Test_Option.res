@@uncurried
@@uncurried.swap

include Test

module Option = (
  T: TEST,
  Q: QUICKCHECK with type t = T.test,
  A: ARBITRARY with type t = option<int> and type arbitrary<'a> = Q.arbitrary<'a>,
  AA: ARBITRARY_A with type t<'a> = option<'a> and type arbitrary<'a> = Q.arbitrary<'a>,
) => {
  module M = Make(T, Q)
  module Semigroup = M.Semigroup(Functors.OptionF.Int.Additive.Semigroup, A)
  module Monoid = M.Monoid(Functors.OptionF.Int.Additive.Monoid, A)
  module Functor = M.Functor(Option.Functor, AA)
  module Apply = M.Apply(Option.Applicative, AA)
  module Applicative = M.Applicative(Option.Applicative, AA)
  module Monad = M.Monad(Option.Monad, AA)
  module Alt = M.Alt(Option.Alt, AA)
  module Plus = M.Plus(Option.Plus, AA)
  module Alternative = M.Alternative(Option.Alternative, AA)
  module Eq = M.Eq(Functors.OptionF.Int.Eq, A)
  module Ord = M.Ord(Functors.OptionF.Int.Ord, A)

  let infix = T.suite(
    "Option.Infix",
    list{
      T.test("should apply a default value if it's None", () => {
        let \"|?" = Option.Infix.\"|?"
        T.check(T.string, \"|?"("foo", Some("bar")), "bar")
        T.check(T.string, \"|?"("foo", None), "foo")
      }),
    },
  )

  let foldable = T.suite(
    "Option.Foldable",
    list{
      T.test("should do a left fold", () =>
        T.check(T.int, Option.Foldable.fold_left(\"+", 0, Some(1)), 1)
      ),
      T.test("should do a right fold", () => {
        T.check(T.int, Option.Foldable.fold_right(\"+", 0, Some(1)), 1)
        T.check(T.int, Option.Foldable.fold_right(\"+", 0, None), 0)
      }),
      T.test("should do a map fold (int)", () => {
        let fold_map = {
          open Functors.OptionF.Int.Additive.Fold_Map
          fold_map
        }

        T.check(T.int, fold_map(\"*"(2, ...), Some(3)), 6)
        T.check(T.int, fold_map(\"+"(1, ...), None), 0)
      }),
      //      T.test("should do a map fold (list)", () => {
      //        let fold_map = {
      //          open Functors.OptionF.List.Fold_Map_Plus
      //          fold_map
      //        }
      //
      //        T.check(T.list(T.int), fold_map(x => list{x}, Some(123)), list{123})
      //      }),
    },
  )

  //  let traversable = {
  //    let (traverse, sequence) = {
  //      open Functors.OptionF.List.Traversable
  //      (traverse, sequence)
  //    }
  //
  //    T.suite(
  //      "Option.Traversable",
  //      list{
  //        T.test("should traverse the list", () => {
  //          let positive_int = x => x >= 0 ? list{x} : list{}
  //
  //          T.check(T.list(T.option(T.int)), traverse(positive_int, Some(123)), list{Some(123)})
  //        }),
  //        T.test("should sequence the list", () => {
  //          T.check(
  //            T.list(T.option(T.int)),
  //            sequence(Some(list{3, 4, 5})),
  //            list{Some(3), Some(4), Some(5)},
  //          )
  //          T.check(T.list(T.option(T.int)), sequence(None), list{None})
  //        }),
  //      },
  //    )
  //  }

  let suites = ListLabels.append(
    list{infix, foldable},
    ListLabels.map(
      ~f=suite => suite("Option"),
      list{
        Semigroup.suite,
        Monoid.suite,
        Functor.suite,
        Apply.suite,
        Applicative.suite,
        Monad.suite,
        Alt.suite,
        Alternative.suite,
        Plus.suite,
        Eq.suite,
        Ord.suite,
      },
    ),
  )
}
