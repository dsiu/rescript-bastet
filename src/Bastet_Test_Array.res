open Bastet_Test_Core

module Array = (
  Arr: Bastet_ArrayF.ARRAY,
  T: TEST,
  Q: QUICKCHECK with type t = T.test,
  A: ARBITRARY with type t = array<int> and type arbitrary<'a> = Q.arbitrary<'a>,
  AA: ARBITRARY_A with type t<'a> = array<'a> and type arbitrary<'a> = Q.arbitrary<'a>,
) => {
  module M = Make(T, Q)
  module Functor = M.Functor(Arr.Functor, AA)
  module Apply = M.Apply(Arr.Applicative, AA)
  module Applicative = M.Applicative(Arr.Applicative, AA)
  module Monad = M.Monad(Arr.Monad, AA)
  module Alt = M.Alt(Arr.Alt, AA)
  module Eq = M.Eq(Functors.ArrayF.Int.Eq, A)
  module Ord = M.Ord(Functors.ArrayF.Int.Ord, A)
  module Invariant = M.Invariant(Arr.Invariant, AA)

  let zip_with = T.suite(
    "Array.zip_with",
    list{
      T.test("should zip_with two arrays", () =>
        T.check(T.array(T.int), Arr.zip_with(\"*", [1, 2, 3], [4, 5, 6]), [4, 10, 18])
      ),
    },
  )

  let zip = T.suite(
    "Array.zip",
    list{
      T.test("should zip two arrays", () =>
        T.check(
          T.array(T.tuple(T.int, T.string)),
          Arr.zip([1, 2, 3], ["a", "b", "c"]),
          [(1, "a"), (2, "b"), (3, "c")],
        )
      ),
    },
  )

  let foldable = T.suite(
    "Array.Foldable",
    list{
      T.test("should do a left fold", () => {
        T.check(T.int, Arr.Foldable.fold_left(\"+", 0, [1, 2, 3, 4, 5]), 15)
        T.check(T.int, Arr.Foldable.fold_left(\"-", 10, [3, 2, 1]), 4)
      }),
      T.test("should do a right fold", () =>
        T.check(T.int, Arr.Foldable.fold_right(\"-", 10, [3, 2, 1]), -8)
      ),
      T.test("should do a map fold (int)", () => {
        let fold_map = Functors.ArrayF.Int.Additive.Fold_Map.fold_map
        T.check(T.int, fold_map(Function.Category.id, [1, 2, 3]), 6)
      }),
      T.test("should do a map fold (list)", () => {
        let fold_map = Functors.ArrayF.List.Fold_Map_Plus.fold_map
        T.check(
          T.list(T.list(T.int)),
          fold_map(Bastet_List.Applicative.pure, [list{1, 2, 3}, list{4, 5}]),
          list{list{1, 2, 3}, list{4, 5}},
        )
      }),
    },
  )

  let unfoldable = T.suite(
    "Array.Unfoldable",
    list{
      T.test("should do an unfold", () => T.check(T.array(T.int), Arr.Unfoldable.unfold(x =>
            if x > 5 {
              None
            } else {
              Some(x, x + 1)
            }
          , 0), [0, 1, 2, 3, 4, 5])),
      T.test("should do an unfold", () => T.check(T.array(T.int), Arr.Unfoldable.unfold(x =>
            if x > 20 {
              None
            } else {
              Some(x, x + 5)
            }
          , 0), [0, 5, 10, 15, 20])),
    },
  )

  let traversable = {
    let (traverse, sequence) = {
      open Functors.ArrayF.Option.Traversable
      (traverse, sequence)
    }

    T.suite(
      "Array.Traversable",
      list{
        T.test("should traverse the array", () => {
          let positive_int = x => x >= 0 ? Some(x) : None

          T.check(T.option(T.array(T.int)), traverse(positive_int, [1, 2, 3]), Some([1, 2, 3]))
          T.check(T.option(T.array(T.int)), traverse(positive_int, [1, 2, -3]), None)
        }),
        T.test("should sequence the array", () => {
          T.check(T.option(T.array(T.int)), sequence([Some(3), Some(4), Some(5)]), Some([3, 4, 5]))
          T.check(T.option(T.array(T.int)), sequence([Some(3), Some(4), None]), None)
        }),
      },
    )
  }

  let show = {
    module S = Arr.Show(Bastet_Int.Show)
    T.suite(
      "Array.Show",
      list{
        T.test("should show the array", () =>
          T.check(T.string, S.show([1, 1, 2, 3, 5, 8, 13]), "[1, 1, 2, 3, 5, 8, 13]")
        ),
      },
    )
  }

  let extend = {
    module V = Verify.Extend(Arr.Extend)
    let id = Function.Category.id
    let \"<." = Function.Infix.\"<."
    let fold = Functors.ArrayF.Int.Additive.Fold_Map.fold_map(id, ...)
    let fold' = Functors.ArrayF.Float.Additive.Fold_Map.fold_map(id, ...)
    T.suite(
      "Array.Extend",
      list{
        Q.property(
          ~name="should satisfy associativity",
          AA.make_bound(Q.arbitrary_int),
          V.associativity(\"<."(Float.toString(_), fold'), \"<."(float_of_int, fold), ...),
        ),
      },
    )
  }

  let alt_order = T.suite(
    "Array.Alt.alt",
    list{
      T.test("should order the arrays correctly", () =>
        T.check(T.array(T.int), Arr.Alt.alt([1, 2, 3], [4, 5]), [1, 2, 3, 4, 5])
      ),
    },
  )

  let suites =
    list{
      Functor.suite,
      Apply.suite,
      Applicative.suite,
      Monad.suite,
      Alt.suite,
      Eq.suite,
      Ord.suite,
      Invariant.suite,
    }
    ->List.map(suite => suite("Array"))
    ->List.concat(list{zip_with, zip, foldable, unfoldable, traversable, show, extend, alt_order})
}
