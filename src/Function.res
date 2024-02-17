@@uncurried
@@uncurried.swap

open Interface

//let flip: (('a, 'b) => 'c, 'b, 'a) => 'c = (f, b, a) => f(a, b)
let flip: (. ('a, 'b) => 'c, 'b, 'a) => 'c = (f, b, a) => f(a, b)

and const: (. 'a, 'b) => 'a = (a, _) => a

module type FUNCTOR_F = (T: TYPE) => (FUNCTOR with type t<'a> = T.t => 'a)

module type APPLY_F = (T: TYPE) => (APPLY with type t<'a> = T.t => 'a)

module type INVARIANT_F = (T: TYPE) => (INVARIANT with type t<'a> = T.t => 'a)

module type CONTRAVARIANT_F = (T: TYPE) => (CONTRAVARIANT with type t<'a> = 'a => T.t)

module type BICONTRAVARIANT_F = (T: TYPE) => (BICONTRAVARIANT with type t<'a, 'b> = ('a, 'b) => T.t)

module Functor: FUNCTOR_F = (T: TYPE) => {
  type t<'b> = T.t => 'b

  let map_x = (. f, g) => x => f(g(x))
  let map = (f, g) => map_x(f, g)
}

module Apply: APPLY_F = (T: TYPE) => {
  module Functor = Functor(T)
  include Functor

  let apply_x = (. f, g) => x => f(x)(g(x))
  let apply = (. f, g) => apply_x(f, g)
}

module Semigroupoid: SEMIGROUPOID with type t<'a, 'b> = 'a => 'b = {
  type t<'a, 'b> = 'a => 'b

  let compose_x = (. f, g) => x => f(g(x))
  let compose = (. f, g) => compose_x(f, g)

  //  let compose = (. f, g) => x => f(g(x))
}

module Category: CATEGORY with type t<'a, 'b> = 'a => 'b = {
  include Semigroupoid

  let id = a => a
}

module Invariant: INVARIANT_F = (T: TYPE) => {
  module F = Functor(T)

  type t<'b> = T.t => 'b

  let imap: ('a => 'b, 'b => 'a, t<'a>) => t<'b> = (f, _, x) => F.map(f, x)
}

module Profunctor: PROFUNCTOR with type t<'a, 'b> = 'a => 'b = {
  module I = Infix.Semigroupoid(Semigroupoid)

  let \">." = I.\">."

  type t<'a, 'b> = 'a => 'b

  let dimap = (a_to_b, c_to_d, b_to_c) => \">."(\">."(a_to_b, b_to_c), c_to_d)
}

module Contravariant: CONTRAVARIANT_F = (T: TYPE) => {
  type t<'a> = 'a => T.t

  let cmap_x = (f, g, x) => g(f(x))
  let cmap = (f, g) => cmap_x(f, g, ...)
}

module Bicontravariant: BICONTRAVARIANT_F = (T: TYPE) => {
  type t<'a, 'b> = ('a, 'b) => T.t

  let bicmap_x = (f, g, h, a, b) => h(f(a), g(b))
  let bicmap = (f, g, h) => bicmap_x(f, g, h, ...)
}

module Infix = {
  include Infix.Semigroupoid(Semigroupoid)
}
