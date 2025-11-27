open Bastet_Interface

module Magma: MAGMA with type t = Date.t = {
  type t = Date.t

  let append = (a, b) => Date.fromTime(Date.getTime(a) +. Date.getTime(b))
}

module Medial_Magma: MEDIAL_MAGMA with type t = Date.t = Magma

module Semigroup: SEMIGROUP with type t = Date.t = {
  include Magma
}

module Monoid: MONOID with type t = Date.t = {
  include Semigroup

  let empty = Date.fromTime(0.0)
}

module Eq: EQ with type t = Date.t = {
  type t = Date.t

  let eq = (a, b) => Date.getTime(a) == Date.getTime(b)
}

module Ord: ORD with type t = Date.t = {
  include Eq

  let compare = (a, b) => unsafe_compare(Date.getTime(a), Date.getTime(b))
}

module Infix = {
  include Bastet_Infix.Magma(Magma)
  include Bastet_Infix.Eq(Eq)
  include Bastet_Infix.Ord(Ord)
}
