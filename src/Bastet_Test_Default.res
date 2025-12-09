open Bastet_Test_Core

module Default = (T: TEST, Q: QUICKCHECK with type t = T.test) => {
  module Foldable: Interface.FOLDABLE with type t<'a> = list<'a> = {
    type t<'a> = list<'a>
    module Default = Bastet_Default

    module FM: Default.FOLD_MAP with type t<'a> = list<'a> = {
      type t<'a> = list<'a>

      module Fold_Map_Any = (M: Interface.MONOID_ANY) => {
        let fold_map = (f, x) => List.reduce(x, M.empty, (acc, x) => M.append(acc, f(x)))
      }

      module Fold_Map_Plus = (P: Interface.PLUS) => {
        let fold_map = (f, x) => List.reduce(x, P.empty, (acc, x) => P.alt(acc, f(x)))
      }
    }

    module Fold_Map = Bastet_List.Foldable.Fold_Map
    module Fold_Map_Any = FM.Fold_Map_Any
    module Fold_Map_Plus = FM.Fold_Map_Plus
    module F = Default.Fold(FM)

    let (fold_left, fold_right) = (F.fold_left_default, F.fold_right_default)
  }

  module Traversable = (A: Interface.APPLICATIVE) => {
    module List_Traversable: Interface.TRAVERSABLE
      with type applicative_t<'a> = A.t<'a>
      and type t<'a> = list<'a> = {
      type t<'a> = list<'a>

      type applicative_t<'a> = A.t<'a>

      include (Bastet_List.Functor: Interface.FUNCTOR with type t<'a> := t<'a>)

      include (Bastet_List.Foldable: Interface.FOLDABLE with type t<'a> := t<'a>)

      module Infix = Bastet_Infix

      module I = Infix.Apply(A)

      let sequence = xs => {
        open I
        List.reduceReverse(xs, A.pure(list{}), (x, acc) => {
          let ff = y => ys => list{y, ...ys}
          let ap = A.pure(ff)
          let ap1 = \"<*>"(ap, acc)
          \"<*>"(ap1, x)
        })
      }

      module D = Bastet_Default.Traverse({
        type t<'a> = list<'a>

        type applicative_t<'a> = A.t<'a>

        include (Bastet_List.Functor: Interface.FUNCTOR with type t<'a> := t<'a>)

        let sequence = sequence
      })

      let traverse = D.traverse_default
    }

    include List_Traversable
  }

  let foldable = {
    open Foldable
    T.suite(
      "Default.Foldable",
      list{
        T.test("should do a left fold", () => {
          T.check(T.int, fold_left(\"+", 0, list{1, 2, 3, 4, 5}), 15)
          T.check(T.int, fold_left(\"-", 10, list{3, 2, 1}), 4)
        }),
      },
    )
  }

  module Traverse = Traversable(Bastet_Option.Applicative)

  let traversable = {
    open Traverse
    T.suite(
      "Default.Traversable",
      list{
        T.test("should traverse the list", () => {
          let positive_int = x => x >= 0 ? Some(x) : None

          T.check(
            T.option(T.list(T.int)),
            traverse(positive_int, list{1, 2, 3}),
            Some(list{1, 2, 3}),
          )
        }),
      },
    )
  }

  let suites = list{foldable, traversable}
}
