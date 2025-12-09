open Bastet_Test_Core

module List = (
  T: TEST,
  Q: QUICKCHECK with type t = T.test,
  A: ARBITRARY with type t = list<int> and type arbitrary<'a> = Q.arbitrary<'a>,
  AA: ARBITRARY_A with type t<'a> = list<'a> and type arbitrary<'a> = Q.arbitrary<'a>,
) => {
  module M = Make(T, Q)

  module Functor = M.Functor(Bastet_List.Functor, AA)
  module Apply = M.Apply(Bastet_List.Applicative, AA)
  module Applicative = M.Applicative(Bastet_List.Applicative, AA)
  module Monad = M.Monad(Bastet_List.Monad, AA)
  module Alt = M.Alt(Bastet_List.Alt, AA)
  module Eq = M.Eq(Functors.ListF.Int.Eq, A)

  let foldable = T.suite(
    "List.Foldable",
    list{
      T.test("should do a left fold", () => {
        T.check(T.int, Bastet_List.Foldable.fold_left(\"+", 0, list{1, 2, 3, 4, 5}), 15)
        T.check(T.int, Bastet_List.Foldable.fold_left(\"-", 10, list{3, 2, 1}), 4)
      }),
      T.test("should do a right fold", () =>
        T.check(T.int, Bastet_List.Foldable.fold_right(\"-", 10, list{3, 2, 1}), -8)
      ),
      T.test("should do a map fold (int)", () => {
        let fold_map = Functors.ListF.Int.Additive.Fold_Map.fold_map
        T.check(T.int, fold_map(Function.Category.id, list{1, 2, 3}), 6)
      }),
      T.test("should do a map fold (list)", () => {
        let fold_map = Functors.ListF.List.Fold_Map_Plus.fold_map
        T.check(
          T.list(T.list(T.int)),
          fold_map(Bastet_List.Applicative.pure, list{list{1, 2, 3}, list{4, 5}}),
          list{list{1, 2, 3}, list{4, 5}},
        )
      }),
    },
  )

  let unfoldable = T.suite(
    "List.Unfoldable",
    list{
      T.test("should do an unfold", () => T.check(T.list(T.int), Bastet_List.Unfoldable.unfold(x =>
            if x > 5 {
              None
            } else {
              Some(x, x + 1)
            }
          , 0), list{0, 1, 2, 3, 4, 5})),
      T.test("should do an unfold", () => T.check(T.list(T.int), Bastet_List.Unfoldable.unfold(x =>
            if x > 20 {
              None
            } else {
              Some(x, x + 5)
            }
          , 0), list{0, 5, 10, 15, 20})),
    },
  )

  let traversable = {
    let (traverse, sequence) = {
      open Functors.ListF.Option.Traversable
      (traverse, sequence)
    }

    T.suite(
      "List.Traversable",
      list{
        T.test("should traverse the list", () => {
          let positive_int = x => x >= 0 ? Some(x) : None

          T.check(
            T.option(T.list(T.int)),
            traverse(positive_int, list{1, 2, 3}),
            Some(list{1, 2, 3}),
          )
          T.check(T.option(T.list(T.int)), traverse(positive_int, list{1, 2, -3}), None)
        }),
        T.test("should sequence the list", () => {
          T.check(
            T.option(T.list(T.int)),
            sequence(list{Some(3), Some(4), Some(5)}),
            Some(list{3, 4, 5}),
          )
          T.check(T.option(T.list(T.int)), sequence(list{Some(3), Some(4), None}), None)
        }),
      },
    )
  }

  let show = {
    module Int = Bastet_Int
    module S = Bastet_List.Show(Int.Show)
    T.suite(
      "List.Show",
      list{
        T.test("should show the list", () =>
          T.check(T.string, S.show(list{1, 1, 2, 3, 5, 8, 13}), "[1, 1, 2, 3, 5, 8, 13]")
        ),
      },
    )
  }

  let alt_order = T.suite(
    "List.Alt.alt",
    list{
      T.test("should order the lists correctly", () =>
        T.check(T.list(T.int), Bastet_List.Alt.alt(list{1, 2, 3}, list{4, 5}), list{1, 2, 3, 4, 5})
      ),
    },
  )

  let suites =
    list{Functor.suite, Apply.suite, Applicative.suite, Monad.suite, Alt.suite, Eq.suite}
    ->List.map(suite => suite("List"))
    ->List.concat(list{foldable, unfoldable, traversable, show, alt_order})
}
