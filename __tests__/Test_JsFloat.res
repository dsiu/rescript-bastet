open RescriptMocha.Mocha
open BsJsverify.Verify.Arbitrary

module ArbitraryFloat: Bastet_Test.ARBITRARY
  with type t = float
  and type arbitrary<'a> = arbitrary<'a> = {
  type t = float

  type arbitrary<'a> = arbitrary<'a>

  let make = arb_float(Bastet_Float.Bounded.bottom, Bastet_Float.Bounded.top ** (1. /. 150.))
}

module ApproximatelyEq = {
  type t = float

  let approx = Float.toPrecision(_, ~digits=4)

  let eq = (a, b) => approx(a) == approx(b)
}

module TestFloat = Bastet_Test.Float(
  ApproximatelyEq,
  MochaI.Test,
  JsVerifyI.Quickcheck,
  ArbitraryFloat,
)

describe("Float", () => MochaI.run(TestFloat.suites))
