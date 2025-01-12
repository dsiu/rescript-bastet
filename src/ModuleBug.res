module type TEST = {
  type test
}

module type ARBITRARY = {
  type t
  type arbitrary<'a>
}

module type QUICKCHECK = {
  type t
  type arbitrary<'a>
}

module Interface = {
  module type EQ = {
    type t

    let eq: (t, t) => bool
  }
}

module Make = (T: TEST, Q: QUICKCHECK with type t = T.test) => {
  type t
  type arbitrary<'a>

  module Eq = (
    E: Interface.EQ,
    A: ARBITRARY with type t := E.t and type arbitrary<'a> := Q.arbitrary<'a>,
  ) => {
    let suite = name => "suite: " ++ name
  }
}

module IntWithTest = (
  T: TEST,
  Q: QUICKCHECK with type t = T.test,
  A: ARBITRARY with type t := int and type arbitrary<'a> := Q.arbitrary<'a>,
) => {
  module IntEq: Interface.EQ = {
    type t = int

    let eq = (a, b) => RescriptCore.Int.equal(a, b)
  }
  module M = Make(T, Q)
  module EQ = M.Eq(IntEq, A)
}

module ArbitraryInt: ARBITRARY with type t = int and type arbitrary<'a> = array<'a> = {
  type t = int
  type arbitrary<'a> = array<'a>
}

module JsQuickCheck = {
  type t = int
  type arbitrary<'a> = array<'a>
}

module MochaTest = {
  type test = int
}

module TestInt = IntWithTest(MochaTest, JsQuickCheck, ArbitraryInt)

TestInt.EQ.suite->Console.log
