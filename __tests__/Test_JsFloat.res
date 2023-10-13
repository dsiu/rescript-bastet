open RescriptMocha.Mocha
open BsJsverify.Verify.Arbitrary

module ArbitraryFloat: Test.ARBITRARY with type t = float and type arbitrary<'a> = arbitrary<'a> = {
  type t = float

  type arbitrary<'a> = arbitrary<'a>

  let make = arb_float(Float.Bounded.bottom, Float.Bounded.top ** (1. /. 150.))
}

module ApproximatelyEq = {
  type t = float

  let approx = Js.Float.toPrecisionWithPrecision(~digits=4)

  let eq = (a, b) => approx(a) == approx(b)
}

module TestFloat = Test.Float(ApproximatelyEq, MochaI.Test, JsVerifyI.Quickcheck, ArbitraryFloat)

describe("Float", () => MochaI.run(TestFloat.suites))
