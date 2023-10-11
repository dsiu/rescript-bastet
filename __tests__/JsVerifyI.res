@@uncurried
@@uncurried.swap

module Quickcheck: Test.QUICKCHECK
  with type t = unit => unit
  and type arbitrary<'a> = BsJsverify.Verify.Arbitrary.arbitrary<'a> = {
  type t = unit => unit

  type arbitrary<'a> = BsJsverify.Verify.Arbitrary.arbitrary<'a>

  let arbitrary_int = BsJsverify.Verify.Arbitrary.arb_int(-1000, 1000)

  let default_name = ""

  let property = (~count=?, ~name=default_name, arbitrary, a) => {
    count |> ignore
    () => BsJsverify.Verify.Property.property1(name, arbitrary, a)
  }

  let property2 = (~count=?, ~name=default_name, arbitrary, a, b) => {
    count |> ignore
    () => BsJsverify.Verify.Property.property2(name, arbitrary, a, b)
  }

  let property3 = (~count=?, ~name=default_name, arbitrary, a, b, c) => {
    count |> ignore
    () => BsJsverify.Verify.Property.property3(name, arbitrary, a, b, c)
  }

  let property4 = (~count=?, ~name=default_name, arbitrary, a, b, c, d) => {
    count |> ignore
    () => BsJsverify.Verify.Property.property4(name, arbitrary, a, b, c, d)
  }
}
