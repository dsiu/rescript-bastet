@@ocaml.text(" These helpers provide generative tests for implementations. ")

module type TEST = {
  type test
  type suite<'a>
  type check<'a>

  let int: check<int>
  let bool: check<bool>
  let string: check<string>
  let array: check<'a> => check<array<'a>>
  let option: check<'a> => check<option<'a>>
  let list: check<'a> => check<list<'a>>
  let tuple: (check<'a>, check<'b>) => check<('a, 'b)>
  let check: (check<'a>, ~name: string=?, 'a, 'a) => unit
  let test: (string, unit => unit) => test
  let suite: (string, list<test>) => suite<test>
}

module type ARBITRARY = {
  type t

  type arbitrary<'a>
  let make: arbitrary<t>
}

module type ARBITRARY_A = {
  @@ocaml.text(
    " Generic helper to make an [arbitrary(t('a))] type from a given [arbitrary('a)] type. "
  )

  type t<'a>
  type arbitrary<'a>

  let make: arbitrary<'a> => arbitrary<t<'a>>
  let make_bound: arbitrary<'a> => arbitrary<t<'a>>
}

module type QUICKCHECK = {
  @@ocaml.text(" This module type is required to create the generative tests. Provide the framework-specific
      implementations here (ie: qcheck, jsverify,etc). ")

  type t
  type arbitrary<'a>

  let arbitrary_int: arbitrary<int>

  let property: (~count: int=?, ~name: string=?, arbitrary<'a>, 'a => bool) => t

  let property2: (
    ~count: int=?,
    ~name: string=?,
    arbitrary<'a>,
    arbitrary<'b>,
    ('a, 'b) => bool,
  ) => t

  let property3: (
    ~count: int=?,
    ~name: string=?,
    arbitrary<'a>,
    arbitrary<'b>,
    arbitrary<'c>,
    ('a, 'b, 'c) => bool,
  ) => t

  let property4: (
    ~count: int=?,
    ~name: string=?,
    arbitrary<'a>,
    arbitrary<'b>,
    arbitrary<'c>,
    arbitrary<'d>,
    ('a, 'b, 'c, 'd) => bool,
  ) => t
}

module Make = (T: TEST, Q: QUICKCHECK with type t = T.test) => {
  type t

  type arbitrary<'a>

  let \"<." = Function.Infix.\"<."

  module Eq = (
    E: Interface.EQ,
    A: ARBITRARY with type t := E.t and type arbitrary<'a> := Q.arbitrary<'a>,
  ) => {
    module V = Verify.Eq(E)

    let suite = name =>
      T.suite(
        name ++ ".Eq",
        list{
          Q.property(~name="should satisfy reflexivity", A.make, V.reflexivity),
          Q.property2(~name="should satisfy symmetry", A.make, A.make, V.symmetry),
          Q.property3(~name="should satisfy transitivity", A.make, A.make, A.make, V.transitivity),
        },
      )
  }
}

module Int = (
  T: TEST,
  Q: QUICKCHECK with type t = T.test,
  A: ARBITRARY with type t = int and type arbitrary<'a> = Q.arbitrary<'a>,
) => {
  module M = Make(T, Q)

  module Eq = M.Eq(Int.Eq, A)

  let suites = RescriptCore.List.flat(list{
    list{Eq.suite}->RescriptCore.List.map(suite => suite("Int")),
  })
}
