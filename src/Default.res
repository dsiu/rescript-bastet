@@ocaml.text(" This module provides default implementations for interfaces ")

let \"<." = Function.Infix.\"<."

module type FOLD = {
  type t<'a>

  let fold_left: (('a, 'b) => 'a, 'a, t<'b>) => 'a

  let fold_right: (('b, 'a) => 'a, 'a, t<'b>) => 'a
}

module Fold_Map = (M: Interface.MONOID, F: FOLD) => {
  module I = Infix.Magma(M)

  let fold_map_default_left = (f, x) => {
    open I
    F.fold_left((acc, x) => \"<:>"(acc, f(x)), M.empty, x)
  }

  and fold_map_default_right = (f, x) => {
    open I
    F.fold_right((x, acc) => \"<:>"(f(x), acc), M.empty, x)
  }
}

module Fold_Map_Any = (M: Interface.MONOID_ANY, F: FOLD) => {
  module I = Infix.Magma_Any(M)

  let fold_map_default_left = (f, x) => {
    open I
    F.fold_left((acc, x) => \"<:>"(acc, f(x)), M.empty, x)
  }

  and fold_map_default_right = (f, x) => {
    open I
    F.fold_right((x, acc) => \"<:>"(f(x), acc), M.empty, x)
  }
}

module Fold_Map_Plus = (P: Interface.PLUS, F: FOLD) => {
  module I = Infix.Alt(P)

  let fold_map_default_left = (f, x) => {
    open I
    F.fold_left((acc, x) => \"<|>"(acc, f(x)), P.empty, x)
  }

  and fold_map_default_right = (f, x) => {
    open I
    F.fold_right((x, acc) => \"<|>"(f(x), acc), P.empty, x)
  }
}

module type FOLD_MAP = {
  type t<'a>

  module Fold_Map_Any: (M: Interface.MONOID_ANY) =>
  {
    let fold_map: ('a => M.t<'b>, t<'a>) => M.t<'b>
  }

  module Fold_Map_Plus: (P: Interface.PLUS) =>
  {
    let fold_map: ('a => P.t<'b>, t<'a>) => P.t<'b>
  }
}

module Fold = (F: FOLD_MAP) => {
  type t<'a> = F.t<'a>

  module Dual_Endo = Dual.Monoid_Any(Endo.Monoid)
  module Dual_Fold_Map = F.Fold_Map_Any(Dual_Endo)
  module Endo_Fold_Map = F.Fold_Map_Any(Endo.Monoid)

  let fold_left_default = (f, init, xs) => {
    let Dual.Dual(Endo.Endo(r)) = Dual_Fold_Map.fold_map(
      \"<."(x => Dual.Dual(Endo.Endo(x)), y => Function.flip(f)(_, y)),
      xs,
    )

    r(init)
  }

  and fold_right_default = (f, init, xs) => {
    let Endo.Endo(r) = Endo_Fold_Map.fold_map(\"<."(x => Endo.Endo(x), f), xs)
    r(init)
  }
}

module type TRAVERSE = {
  type t<'a>

  type applicative_t<'a>

  let traverse: ('a => applicative_t<'b>, t<'a>) => applicative_t<t<'b>>
}

module type SEQUENCE = {
  type t<'a>

  type applicative_t<'a>

  include Interface.FUNCTOR with type t<'a> := t<'a>

  let sequence: t<applicative_t<'a>> => applicative_t<t<'a>>
}

module Sequence = (T: TRAVERSE) => {
  let sequence_default = xs => T.traverse(Function.Category.id, xs)
}

module Traverse = (S: SEQUENCE) => {
  let traverse_default = (f, xs) => S.sequence(S.map(f, xs))
}
