open RescriptMocha.Mocha
open BsJsverify.Verify.Arbitrary

module ArbitraryFloat: Bastet_Test.ARBITRARY
  with type t = float
  and type arbitrary<'a> = arbitrary<'a> = {
  type t = float

  type arbitrary<'a> = arbitrary<'a>

  // Use a constrained positive range to avoid floating-point overflow/precision issues
  // Note: Float is not a fully law-abiding member of algebraic structures
  // due to potential arithmetic overflows and floating point precision issues
  // (see Bastet_Float.res). We use a practical positive range that:
  // - Stays within Bounded.bottom and Bounded.top
  // - Prevents overflow when values are multiplied together
  // Using 1e50 as max ensures that even a*b*c stays well under maxValue (~1.8e308)
  let make = arb_float(Bastet_Float.Bounded.bottom, 1.0e50)
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
