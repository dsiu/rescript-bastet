@@uncurried
@@uncurried.swap

open Interface

module Magma: MAGMA with type t = string = {
  type t = string

  let append = \"^"
}

module Semigroup: SEMIGROUP with type t = string = {
  include Magma
}

module Monoid: MONOID with type t = string = {
  include Semigroup

  let empty = ""
}

module Quasigroup: QUASIGROUP with type t = string = {
  include Magma
}

module Loop: LOOP with type t = string = {
  include Quasigroup

  let empty = ""
}

module Eq: EQ with type t = string = {
  type t = string

  let eq = \"="
}

module Ord: ORD with type t = string = {
  include Eq

  let compare = unsafe_compare
}

module Show: SHOW with type t = string = {
  type t = string

  let show = Function.Category.id
}

module Infix = {
  include Infix.Magma(Magma)
  include Infix.Eq(Eq)
  include Infix.Ord(Ord)
}
