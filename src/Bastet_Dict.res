open Bastet_Interface
module Function = Bastet_Function
module Default = Bastet_Default
module Infix = Bastet_Infix

let \"<." = Function.Infix.\"<."

%%raw(`
globalThis.bastet_dict_fold_left = function(f, initial, a) {
  return Object.keys(a).reduce(function(acc, key) {
    return f(acc, a[key])
  }, initial)
};

globalThis.bastet_dict_fold_left_keys = function(f, initial, a) {
  return Object.keys(a).reduce(function(acc, key) {
    return f(acc, key, a[key])
  }, initial)
};

globalThis.bastet_dict_merge = function(a, b) {
  var obj = {}
  for (var key in b) obj[key] = b[key]
  for (var key in a) obj[key] = a[key]
  return obj
};
`)

@val external fold_left: (('a, 'b) => 'a, 'a, dict<'b>) => 'a = "bastet_dict_fold_left"

@val external fold_left_keys: (('a, string, 'b) => 'a, 'a, dict<'b>) => 'a = "bastet_dict_fold_left_keys"

@val external merge: (dict<'a>, dict<'a>) => dict<'a> = "bastet_dict_merge"

external unsafe_from_object: 'a => dict<'b> = "%identity"

let insert: (string, 'a, dict<'a>) => dict<'a> = (key, value, dict) => {
  Dict.set(dict, key, value)
  dict
}

module type TRAVERSABLE_F = (A: APPLICATIVE) =>
(TRAVERSABLE with type t<'a> = dict<'a> and type applicative_t<'a> = A.t<'a>)

module Functor: FUNCTOR with type t<'a> = dict<'a> = {
  type t<'a> = dict<'a>

  let map = (f, a) => Dict.mapValues(a, x => f(x))
}

module Apply: APPLY with type t<'a> = dict<'a> = {
  include Functor

  let apply = (fn_array, a) =>
    fold_left((acc, f) => merge(acc, map(f, a)), Obj.magic(Dict.make()), fn_array)
}

module Alt: ALT with type t<'a> = dict<'a> = {
  include Functor

  let alt = merge
}

module Plus: PLUS with type t<'a> = dict<'a> = {
  include Alt

  let empty = Obj.magic(Dict.make())
}

module Foldable: FOLDABLE with type t<'a> = dict<'a> = {
  type t<'a> = dict<'a>

  let fold_left = fold_left

  and fold_right: (('b, 'a) => 'a, 'a, t<'b>) => 'a = (f, init, a) =>
    Array.reduceRight(Dict.valuesToArray(a), init, (x, y) => f(y, x))

  module Fold_Map = (M: MONOID) => {
    module D = Default.Fold_Map(
      M,
      {
        type t<'a> = dict<'a>

        let (fold_left, fold_right) = (fold_left, fold_right)
      },
    )

    let fold_map = D.fold_map_default_left
  }

  module Fold_Map_Any = (M: MONOID_ANY) => {
    module D = Default.Fold_Map_Any(
      M,
      {
        type t<'a> = dict<'a>

        let (fold_left, fold_right) = (fold_left, fold_right)
      },
    )

    let fold_map = D.fold_map_default_left
  }

  module Fold_Map_Plus = (P: PLUS) => {
    module D = Default.Fold_Map_Plus(
      P,
      {
        type t<'a> = dict<'a>

        let (fold_left, fold_right) = (fold_left, fold_right)
      },
    )

    let fold_map = D.fold_map_default_left
  }
}

module Traversable: TRAVERSABLE_F = (A: APPLICATIVE) => {
  type rec t<'a> = dict<'a>

  and applicative_t<'a> = A.t<'a>

  include (Functor: FUNCTOR with type t<'a> := t<'a>)

  include (Foldable: FOLDABLE with type t<'a> := t<'a>)

  module I = Infix.Apply(A)

  let traverse_with_index = (f, a) => {
    open I
    fold_left_keys(
      (acc, k, v) => {
        let insert_flipped = dict => Function.flip((v, dict) => insert(k, v, dict), dict, _)
        \"<*>"(
          \"<$>"(insert_flipped, acc),
          f(k, v),
        )
      },
      A.pure(Dict.make()),
      a,
    )
  }

  //  let traverse = Obj.magic(\"<."(traverse_with_index, Function.const))
  let traverse = Obj.magic((f, ta) => traverse_with_index((_, a) => f(a), ta))

  module D = Default.Sequence({
    type rec t<'a> = dict<'a>

    and applicative_t<'a> = A.t<'a>

    let traverse = traverse
  })

  let sequence = D.sequence_default
}
