// Audit-specific regression tests and compile witnesses.
//
// This file is intentionally not a full copy of the original Bastet test suite.
// The generated law suites and translated original JS tests cover the broad
// module behavior. These tests lock down extra audit findings: public functor
// instantiation, argument-order traps, edge cases not directly tested upstream,
// and documented ReScript-target decisions.

module Stdlib_Array = Array
module Stdlib_Date = Date
module Stdlib_Dict = Dict
module Stdlib_Int = Int
module Stdlib_List = List
module Stdlib_Option = Option
module Stdlib_Result = Result

open! Bastet

open RescriptMocha.Mocha
open BsChai.Expect.Expect
open BsChai.Expect.Combos.End

module StringType: Interface.TYPE with type t = string = {
  type t = string
}

module IntType: Interface.TYPE with type t = int = {
  type t = int
}

module ArrayOptionTraversable = Array.Traversable(Option.Applicative)
module ListOptionTraversable = List.Traversable(Option.Applicative)
module OptionArrayTraversable = Option.Traversable(Array.Applicative)
module ResultStringApplicative = Result.Applicative(StringType)
module ResultStringMonad = Result.Monad(StringType)
module ResultIntStringOrd = Result.Ord(Int.Ord, String.Ord)
module ResultArrayTraversable = Result.Traversable(StringType, Array.Applicative)
module ResultArrayBitraversable = Result.Bitraversable(Array.Applicative)
module TupleIntApplicative = Tuple.Applicative(Int.Additive.Monoid)
module TupleIntMonad = Tuple.Monad(Int.Additive.Monoid)
module TupleArrayBitraversable = Tuple.Bitraversable(Array.Applicative)
module DictOptionTraversable = Dict.Traversable(Option.Applicative)
module EndoIntMonoid = Endo.Monoid
module DualStringMonoid = Dual.Monoid(String.Monoid)
module PPXOption = PPX_Let.Make(Option.Monad)

let force_type_witnesses = () => {
  let arraySequence = ArrayOptionTraversable.sequence([Some(1), Some(2)])
  let listSequence = ListOptionTraversable.sequence(list{Some(1), Some(2)})
  let optionTraverse = OptionArrayTraversable.traverse(x => [x + 1], Some(1))
  let resultPure = ResultStringApplicative.pure(1)
  let resultFlatMap = ResultStringMonad.flat_map(Ok(1), x => Ok(x + 1))
  let resultTraverse = ResultArrayTraversable.traverse(x => [x + 1], Ok(1))
  let resultBitraverse = ResultArrayBitraversable.bitraverse(x => [x + 1], x => [x ++ "!"], Error("x"))
  let tuplePure = TupleIntApplicative.pure(1)
  let tupleFlatMap = TupleIntMonad.flat_map((1, 2), x => (3, x + 1))
  let tupleBitraverse = TupleArrayBitraversable.bitraverse(x => [x + 1], x => [x ++ "!"], (1, "x"))
  let dictSequence = DictOptionTraversable.sequence(Dict.unsafe_from_object({"a": Some(1)}))
  let endo = EndoIntMonoid.append(Endo.Endo(x => x + 1), Endo.Endo(x => x * 2))
  let dual = DualStringMonoid.append(Dual.Dual("a"), Dual.Dual("b"))
  let ppx = PPXOption.Let_syntax.bind(Some(1), x => Some(x + 1))

  (
    arraySequence,
    listSequence,
    optionTraverse,
    resultPure,
    resultFlatMap,
    resultTraverse,
    resultBitraverse,
    tuplePure,
    tupleFlatMap,
    tupleBitraverse,
    dictSequence,
    endo,
    dual,
    ppx,
  )
}

describe("Semantic audit regressions", () => {
  describe("compile witnesses", () =>
    it("should instantiate representative public functors", () =>
      force_type_witnesses()->ignore
    )
  )

  describe("Interface", () => {
    it("should preserve ordering conversion and inversion", () =>
      to_be((#less_than, #equal_to, #greater_than), expect((
        Interface.int_to_ordering(-1),
        Interface.invert(#equal_to),
        Interface.unsafe_compare(2, 1),
      )), ...)
    )
  })

  describe("Array", () => {
    it("should zip_with to the shorter input", () =>
      to_be([11, 22], expect(Array.zip_with((a, b) => a + b, [1, 2, 3], [10, 20])), ...)
    )

    it("should preserve empty zip output", () =>
      to_be([], expect(Array.zip([], [1, 2])), ...)
    )
  })

  describe("Dict", () => {
    it("should keep left dict values on key collisions", () =>
      to_be(1, expect(Dict.merge(
        Stdlib_Dict.fromArray(Stdlib_List.toArray(list{("x", 1)})),
        Stdlib_Dict.fromArray(Stdlib_List.toArray(list{("x", 2)})),
      )->Stdlib_Dict.get("x")->Stdlib_Option.getOrThrow), ...)
    )

    it("should mutate and return the inserted dict", () => {
      let dict = Stdlib_Dict.make()
      to_be(2, expect(Dict.insert("x", 2, dict)->Stdlib_Dict.get("x")->Stdlib_Option.getOrThrow), ...)
    })
  })

  describe("Option", () => {
    it("should preserve maybe argument order", () =>
      to_be("none", expect(Option.maybe(~f=x => Stdlib_Int.toString(x), ~default="none", None)), ...)
    )
  })

  describe("Result", () => {
    it("should preserve result eliminator branch order", () =>
      to_be("error:bad", expect(Result.result(x => "ok:" ++ Stdlib_Int.toString(x), x => "error:" ++ x, Error("bad"))), ...)
    )

    it("should preserve Error before Ok ordering", () =>
      to_be(#less_than, expect(ResultIntStringOrd.compare(Error("a"), Ok(1))), ...)
    )
  })

  describe("Tuple", () => {
    it("should preserve first and second helpers", () =>
      to_be((1, "x"), expect((Tuple.first((1, "x")), Tuple.second((1, "x")))), ...)
    )
  })

  describe("Date", () => {
    it("should compare by epoch milliseconds", () =>
      to_be(#less_than, expect(Date.Ord.compare(Stdlib_Date.fromTime(1.0), Stdlib_Date.fromTime(2.0))), ...)
    )
  })

  describe("Float", () => {
    it("should use ReScript-native JS float show formatting", () =>
      to_be(
        ("0", "1", "1.5", "0.00001", "1000000000000", "NaN", "Infinity"),
        expect((
          Float.Show.show(0.0),
          Float.Show.show(1.0),
          Float.Show.show(1.5),
          Float.Show.show(0.00001),
          Float.Show.show(1.0e12),
          Float.Show.show(0.0 /. 0.0),
          Float.Show.show(1.0 /. 0.0),
        )),
        ...
      )
    )
  })
})
