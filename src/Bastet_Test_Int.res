open Bastet_Test_Core

module Int = (
  T: TEST,
  Q: QUICKCHECK with type t = T.test,
  A: ARBITRARY with type t = int and type arbitrary<'a> = Q.arbitrary<'a>,
) => {
  module M = Make(T, Q)
  module Int = Bastet_Int
  module Additive = {
    module Medial_Magma = M.Medial_Magma(Int.Additive.Medial_Magma, A)
    module Semigroup = M.Semigroup(Int.Additive.Semigroup, A)
    module Monoid = M.Monoid(Int.Additive.Monoid, A)
    module Quasigroup = M.Quasigroup(Int.Additive.Quasigroup, A)
    module Loop = M.Loop(Int.Additive.Loop, A)
    module Group = M.Group(Int.Additive.Group, A)
    module Abelian_Group = M.Abelian_Group(Int.Additive.Abelian_Group, A)
  }

  module Multiplicative = {
    module Medial_Magma = M.Medial_Magma(Int.Multiplicative.Medial_Magma, A)
    module Semigroup = M.Semigroup(Int.Multiplicative.Semigroup, A)
    module Monoid = M.Monoid(Int.Multiplicative.Monoid, A)
    module Quasigroup = M.Quasigroup(Int.Multiplicative.Quasigroup, A)
    module Loop = M.Loop(Int.Multiplicative.Loop, A)
  }

  module Subtractive = {
    module Medial_Magma = M.Medial_Magma(Int.Subtractive.Medial_Magma, A)
    module Quasigroup = M.Quasigroup(Int.Subtractive.Quasigroup, A)
  }

  module Eq = M.Eq(Int.Eq, A)
  module Ord = M.Ord(Int.Ord, A)
  module Bounded = M.Bounded(Int.Bounded, A)
  module Semiring = M.Semiring(Int.Semiring, A)
  module Ring = M.Ring(Int.Ring, A)
  module Commutative_Ring = M.Commutative_Ring(Int.Commutative_Ring, A)
  module Euclidean_Ring = M.Euclidean_Ring(Int.Euclidean_Ring, A)

  let suites = CoreList.flat(list{
    list{
      Additive.Medial_Magma.suite,
      Additive.Semigroup.suite,
      Additive.Monoid.suite,
      Additive.Quasigroup.suite,
      Additive.Loop.suite,
      Additive.Group.suite,
      Additive.Abelian_Group.suite,
    }->CoreList.map(suite => suite("Int.Additive")),
    list{
      Multiplicative.Medial_Magma.suite,
      Multiplicative.Semigroup.suite,
      Multiplicative.Monoid.suite,
      Multiplicative.Quasigroup.suite,
      Multiplicative.Loop.suite,
    }->CoreList.map(suite => suite("Int.Multiplicative")),
    list{Subtractive.Medial_Magma.suite, Subtractive.Quasigroup.suite}->CoreList.map(suite =>
      suite("Int.Subtractive")
    ),
    list{
      Eq.suite,
      Ord.suite,
      Bounded.suite,
      Semiring.suite,
      Ring.suite,
      Commutative_Ring.suite,
      Euclidean_Ring.suite,
    }->CoreList.map(suite => suite("Int")),
  })
}
