open Bastet_Test_Core

module Bool = (
  T: TEST,
  Q: QUICKCHECK with type t = T.test,
  A: ARBITRARY with type t = bool and type arbitrary<'a> = Q.arbitrary<'a>,
) => {
  module M = Make(T, Q)
  module Bool = Bastet_Bool

  module Conjunctive = {
    module Medial_Magma = M.Medial_Magma(Bool.Conjunctive.Medial_Magma, A)
    module Semigroup = M.Semigroup(Bool.Conjunctive.Semigroup, A)
    module Monoid = M.Monoid(Bool.Conjunctive.Monoid, A)
  }

  module Disjunctive = {
    module Medial_Magma = M.Medial_Magma(Bool.Disjunctive.Medial_Magma, A)
    module Semigroup = M.Semigroup(Bool.Disjunctive.Semigroup, A)
    module Monoid = M.Monoid(Bool.Disjunctive.Monoid, A)
  }

  module Eq = M.Eq(Bool.Eq, A)
  module Ord = M.Ord(Bool.Ord, A)
  module Join_Semilattice = M.Join_Semilattice(Bool.Join_Semilattice, A)
  module Meet_Semilattice = M.Meet_Semilattice(Bool.Meet_Semilattice, A)
  module Bounded_Join_Semilattice = M.Bounded_Join_Semilattice(Bool.Bounded_Join_Semilattice, A)
  module Bounded_Meet_Semilattice = M.Bounded_Meet_Semilattice(Bool.Bounded_Meet_Semilattice, A)
  module Lattice = M.Lattice(Bool.Lattice, A)
  module Bounded_Lattice = M.Bounded_Lattice(Bool.Bounded_Lattice, A)
  module Distributive_Lattice = M.Distributive_Lattice(Bool.Distributive_Lattice, A)
  module Bounded_Distributive_Lattice = M.Bounded_Distributive_Lattice(
    Bool.Bounded_Distributive_Lattice,
    A,
  )
  module Heyting_Algebra = M.Heyting_Algebra(Bool.Heyting_Algebra, A)
  module Involutive_Heyting_Algebra = M.Involutive_Heyting_Algebra(
    Bool.Involutive_Heyting_Algebra,
    A,
  )
  module Boolean_Algebra = M.Boolean_Algebra(Bool.Boolean_Algebra, A)

  let suites = List.flat(list{
    list{
      Conjunctive.Medial_Magma.suite,
      Conjunctive.Semigroup.suite,
      Conjunctive.Monoid.suite,
    }->List.map(suite => suite("Bool.Conjunctive")),
    list{
      Disjunctive.Medial_Magma.suite,
      Disjunctive.Semigroup.suite,
      Disjunctive.Monoid.suite,
    }->List.map(suite => suite("Bool.Disjunctive")),
    list{
      Eq.suite,
      Ord.suite,
      Join_Semilattice.suite,
      Meet_Semilattice.suite,
      Bounded_Join_Semilattice.suite,
      Bounded_Meet_Semilattice.suite,
      Lattice.suite,
      Bounded_Lattice.suite,
      Distributive_Lattice.suite,
      Bounded_Distributive_Lattice.suite,
      Heyting_Algebra.suite,
      Involutive_Heyting_Algebra.suite,
      Boolean_Algebra.suite,
    }->List.map(suite => suite("Bool")),
  })
}
