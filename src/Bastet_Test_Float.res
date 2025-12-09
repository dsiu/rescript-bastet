open Bastet_Test_Core

module Float = (
  E: Interface.EQ with type t = float,
  T: TEST,
  Q: QUICKCHECK with type t = T.test,
  A: ARBITRARY with type t = float and type arbitrary<'a> = Q.arbitrary<'a>,
) => {
  module M = Make(T, Q)

  module Float = Bastet_Float

  module Additive = {
    module Medial_Magma = M.Compare.Medial_Magma(Float.Additive.Medial_Magma, E, A)
    module Semigroup = M.Semigroup(Float.Additive.Semigroup, A)
    module Monoid = M.Monoid(Float.Additive.Monoid, A)
    module Quasigroup = M.Quasigroup(Float.Additive.Quasigroup, A)
    module Loop = M.Loop(Float.Additive.Loop, A)
    module Group = M.Group(Float.Additive.Group, A)
    module Abelian_Group = M.Abelian_Group(Float.Additive.Abelian_Group, A)
  }

  module Multiplicative = {
    module Medial_Magma = M.Compare.Medial_Magma(Float.Multiplicative.Medial_Magma, E, A)
    module Semigroup = M.Semigroup(Float.Multiplicative.Semigroup, A)
    module Monoid = M.Monoid(Float.Multiplicative.Monoid, A)
    module Quasigroup = M.Compare.Quasigroup(Float.Multiplicative.Quasigroup, E, A)
    module Loop = M.Loop(Float.Multiplicative.Loop, A)
  }

  module Subtractive = {
    module Medial_Magma = M.Compare.Medial_Magma(Float.Subtractive.Medial_Magma, E, A)
    module Quasigroup = M.Compare.Quasigroup(Float.Subtractive.Quasigroup, E, A)
  }

  module Divisive = {
    module Medial_Magma = M.Compare.Medial_Magma(Float.Divisive.Medial_Magma, E, A)
    module Quasigroup = M.Compare.Quasigroup(Float.Divisive.Quasigroup, E, A)
  }

  module Eq = M.Eq(Float.Eq, A)
  module Ord = M.Ord(Float.Ord, A)
  module Bounded = M.Bounded(Float.Bounded, A)
  module Semiring = M.Compare.Semiring(Float.Semiring, E, A)
  module Ring = M.Ring(Float.Ring, A)
  module Commutative_Ring = M.Commutative_Ring(Float.Commutative_Ring, A)
  module Division_Ring = M.Compare.Division_Ring(Float.Division_Ring, E, A)
  module Euclidean_Ring = M.Compare.Euclidean_Ring(Float.Euclidean_Ring, E, A)
  module Field = M.Field(Float.Field, A)

  let suites = List.flat(list{
    list{
      Additive.Medial_Magma.suite,
      Additive.Semigroup.suite,
      Additive.Monoid.suite,
      Additive.Quasigroup.suite,
      Additive.Loop.suite,
      Additive.Group.suite,
      Additive.Abelian_Group.suite,
    }->List.map(suite => suite("Float.Additive")),
    list{
      Multiplicative.Medial_Magma.suite,
      Multiplicative.Semigroup.suite,
      Multiplicative.Monoid.suite,
      Multiplicative.Quasigroup.suite,
      Multiplicative.Loop.suite,
    }->List.map(suite => suite("Float.Multiplicative")),
    list{Subtractive.Medial_Magma.suite, Subtractive.Quasigroup.suite}->List.map(suite =>
      suite("Float.Subtractive")
    ),
    list{Divisive.Medial_Magma.suite, Divisive.Quasigroup.suite}->List.map(suite =>
      suite("Float.Divisive")
    ),
    list{
      Eq.suite,
      Ord.suite,
      Bounded.suite,
      Semiring.suite,
      Ring.suite,
      Commutative_Ring.suite,
      Division_Ring.suite,
      Euclidean_Ring.suite,
      Field.suite,
    }->List.map(suite => suite("Float")),
  })
}
