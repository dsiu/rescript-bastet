open Bastet_Interface

let \"<." = Bastet_Function.Infix.\"<."

@@ocaml.text(" Note: Promises are not actually Monads because you can't have `'a Js.Promise.t Js.Promise.t`
    Even though it's a valid bucklescript signature. Promises auto-flatten in this case.
    See the unit tests. ")

module Functor: FUNCTOR with type t<'a> = promise<'a> = {
  type t<'a> = promise<'a>

  let map = (f, a) => a->Promise.then(Promise.resolve->\"<."(f))
}

module Apply: APPLY with type t<'a> = promise<'a> = {
  include Functor

  let apply = (f, a) =>
    Promise.then(f, f' => Promise.then(a, a' => Promise.resolve(f'(a'))))
}

module Applicative: APPLICATIVE with type t<'a> = promise<'a> = {
  include Apply

  let pure = p => Promise.resolve(p)
}
