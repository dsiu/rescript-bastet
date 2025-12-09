open Bastet_Test_Core

module String = (
  T: TEST,
  Q: QUICKCHECK with type t = T.test,
  A: ARBITRARY with type t = string and type arbitrary<'a> = Q.arbitrary<'a>,
) => {
  module M = Make(T, Q)
  module String = Bastet_String
  module Semigroup = M.Semigroup(String.Semigroup, A)
  module Monoid = M.Monoid(String.Monoid, A)
  module Quasigroup = M.Quasigroup(String.Quasigroup, A)
  module Loop = M.Loop(String.Loop, A)
  module Eq = M.Eq(String.Eq, A)
  module Ord = M.Ord(String.Ord, A)

  let suites =
    list{
      Semigroup.suite,
      Monoid.suite,
      Quasigroup.suite,
      Loop.suite,
      Eq.suite,
      Ord.suite,
    }->CoreList.map(suite => suite("String"))
}
