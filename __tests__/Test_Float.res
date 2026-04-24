open RescriptMocha.Mocha
open BsJsverify.Verify.Arbitrary

module ArbitraryFloat: Bastet_Test.ARBITRARY
  with type t = float
  and type arbitrary<'a> = arbitrary<'a> = {
  type t = float

  type arbitrary<'a> = arbitrary<'a>

  // Use the same constrained positive range as original Test_JsFloat.ml.
  // Float is not fully law-abiding for these algebraic structures because of
  // overflow and precision limits, so the generator keeps multiplied values
  // comfortably below maxValue while preserving the original test domain.
  let make = arb_float(
    Bastet_Float.Bounded.bottom,
    Math.pow(Bastet_Float.Bounded.top, ~exp=1.0 /. 150.0),
  )
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
