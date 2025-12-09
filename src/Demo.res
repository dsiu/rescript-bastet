module Stdlib_String = String
open Bastet

// Examples

module T = Bastet.Functors.ListF.Option.Traversable

let seq = T.sequence(list{Some(1), Some(2), Some(3)})

Console.log(seq)

let res = Functors.ListF.Int.Show.show(list{1, 2, 3})

Console.log(res)

// Suggested Usage
let \">=>" = Option.Infix.\">=>"

type form = {name: string, address: option<string>}

let get_form: unit => option<form> = () => {
  Some({name: "Foo", address: Some("123 Bar St.")})
}

let get_address: form => option<string> = f => f.address

let get_form_address = \">=>"(get_form, get_address, _)

Console.log(get_form_address())

// Instantiated Functors
let fmap = Functors.ArrayF.Int.Additive.Fold_Map.fold_map

// Don't Overuse Infix

let trim_all = strings => {
  open Array.Infix
  \"<$>"(Stdlib_String.trim, strings)
}

Console.log(trim_all(["foo  ", "  bar  ", "  baz"]))

// Use Abbreviated Modules
type game = {score: int, disqualified: bool}

let total_score = (a, b) => {
  module I = Int.Additive.Semigroup
  module B = Bool.Disjunctive.Semigroup
  {score: I.append(a.score, b.score), disqualified: B.append(a.disqualified, b.disqualified)}
}

let result = {
  let game_1 = { score:4, disqualified:false }
  let game_2 = { score:2, disqualified:true }
  total_score(game_1, game_2)
}

Console.log(result)
