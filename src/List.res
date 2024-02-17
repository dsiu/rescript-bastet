@@uncurried
@@uncurried.swap

open Interface

module type EQ_F = (E: EQ) => (EQ with type t = list<E.t>)

module type SHOW_F = (S: SHOW) => (SHOW with type t = list<S.t>)

module type TRAVERSABLE_F = (A: APPLICATIVE) =>
(TRAVERSABLE with type t<'a> = list<'a> and type applicative_t<'a> = A.t<'a>)

module Functor: FUNCTOR with type t<'a> = list<'a> = {
  type t<'a> = list<'a>

  let map: ('a => 'b, list<'a>) => list<'b> = (f, xs) => ListLabels.map(~f, xs)
}

module Alt: ALT with type t<'a> = list<'a> = {
  include Functor

  let alt = ListLabels.append
}

module Apply: APPLY with type t<'a> = list<'a> = {
  include Functor

  let apply = (. fn_array, a) =>
    ListLabels.fold_left(~f=(acc, f) => Alt.alt(acc, map(f, a)), ~init=list{}, fn_array)
}

module Applicative: APPLICATIVE with type t<'a> = list<'a> = {
  include Apply

  let pure = a => list{a}
}

module Monad: MONAD with type t<'a> = list<'a> = {
  include Applicative

  let flat_map = (. x, f) =>
    ListLabels.fold_left(~f=(acc, a) => Alt.alt(acc, f(a)), ~init=list{}, x)
}

module Plus: PLUS with type t<'a> = list<'a> = {
  include Alt

  let empty = list{}
}

module Alternative: ALTERNATIVE with type t<'a> = list<'a> = {
  include Applicative

  include (Plus: PLUS with type t<'a> := t<'a>)
}

module Foldable: FOLDABLE with type t<'a> = list<'a> = {
  type t<'a> = list<'a>

  let fold_left: (('a, 'b) => 'a, 'a, list<'b>) => 'a = (f, init, xs) =>
    ListLabels.fold_left(~f, ~init, xs)

  and fold_right: (('a, 'b) => 'b, 'b, list<'a>) => 'b = (f, init, xs) =>
    ListLabels.fold_right(~f, ~init, xs)

  module Fold_Map = (M: MONOID) => {
    module D = Default.Fold_Map(
      M,
      {
        type t<'a> = list<'a>

        let fold_left = fold_left
        let fold_right = fold_right
      },
    )

    let fold_map = D.fold_map_default_left
  }

  module Fold_Map_Any = (M: MONOID_ANY) => {
    module D = Default.Fold_Map_Any(
      M,
      {
        type t<'a> = list<'a>

        let (fold_left, fold_right) = (fold_left, fold_right)
      },
    )

    let fold_map = D.fold_map_default_left
  }

  module Fold_Map_Plus = (P: PLUS) => {
    module D = Default.Fold_Map_Plus(
      P,
      {
        type t<'a> = list<'a>

        let (fold_left, fold_right) = (fold_left, fold_right)
      },
    )

    let fold_map = D.fold_map_default_left
  }
}

module Unfoldable: UNFOLDABLE with type t<'a> = list<'a> = {
  type t<'a> = list<'a>

  let rec unfold = (f, init) =>
    switch f(init) {
    | Some(a, next) => list{a, ...unfold(f, next)}
    | None => list{}
    }
}

module Traversable: TRAVERSABLE_F = (A: APPLICATIVE) => {
  type rec t<'a> = list<'a>

  and applicative_t<'a> = A.t<'a>

  include (Functor: FUNCTOR with type t<'a> := t<'a>)

  include (Foldable: FOLDABLE with type t<'a> := t<'a>)

  module I = Infix.Apply(A)

  let traverse = (f, xs: t<'a>) => {
    open I

    ListLabels.fold_right(~f=(acc, x) => {
      let ff = y => ys => list{y, ...ys}
      let ap = A.pure(ff)
      let ap1 = \"<*>"(ap, f(acc))
      \"<*>"(ap1, x)
    }, ~init=A.pure(list{}), xs)
  }

  module D = Default.Sequence({
    type t<'a> = list<'a>

    type applicative_t<'a> = A.t<'a>

    let traverse = traverse
  })

  let sequence = D.sequence_default
}

module Eq: EQ_F = (E: EQ) => {
  type t = list<E.t>

  let eq = (xs, ys) =>
    ListLabels.length(xs) == ListLabels.length(ys) &&
      ListLabels.fold_left(
        ~f=(acc, (a, b)) => acc && E.eq(a, b),
        ~init=true,
        ListLabels.combine(xs, ys),
      )
}

module Show: SHOW_F = (S: SHOW) => {
  module F = Functions.Foldable(Foldable)
  module M = F.Monoid(String.Monoid)

  type t = list<S.t>

  let show = xs => "[" ++ (M.intercalate(~separator=", ", Functor.map(S.show, xs)) ++ "]")
}

module Infix = {
  include Infix.Monad(Monad)
  include Infix.Alternative(Alternative)
}
