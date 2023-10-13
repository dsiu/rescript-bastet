open RescriptMocha.Mocha
open BsChai.Expect.Expect
open BsChai.Expect.Combos.End
open BsJsverify.Verify.Arbitrary
open BsJsverify.Verify.Property

let id = Function.Category.id

let \"<." = Function.Infix.\"<."

describe("Dict", () => {
  describe("Functor", () => {
    module V = Verify.Functor(Dict.Functor)
    property1("should satisfy identity", arb_dict(arb_nat), V.identity)
    property1(
      "should satisfy composition",
      arb_dict(arb_nat),
      a => V.composition(\"^"("!"), string_of_int, a),
    )
  })
  describe("Apply", () => {
    module V = Verify.Apply(Dict.Apply)
    property1(
      "should satisfy associative composition",
      arb_dict(arb_nat),
      n =>
        V.associative_composition(
          Js.Dict.fromList(list{("g", \"^"("!"))}),
          Js.Dict.fromList(list{("f", string_of_int)}),
          n,
        ),
    )
  })
  describe("Alt", () => {
    module V = Verify.Alt(Dict.Alt)
    property3(
      "should satisfy associativity",
      arb_dict(arb_nat),
      arb_dict(arb_nat),
      arb_dict(arb_nat),
      V.associativity,
    )
    property2(
      "should satisfy distributivity",
      arb_dict(arb_nat),
      arb_dict(arb_nat),
      V.distributivity(string_of_int),
    )
  })
  describe("Plus", () => {
    module V = Verify.Plus(Dict.Plus)
    it("should satisfy annihalation", () => expect(V.annihalation(string_of_int)) |> to_be(true))
    property1("should satisfy identity", arb_dict(arb_nat), V.identity)
  })
  describe("Foldable", () =>
    it(
      "should do a left fold",
      () => {
        expect(
          Dict.Foldable.fold_left(\"+", 0, Dict.unsafe_from_object({"a": 1, "b": 2, "c": 3})),
        ) |> to_be(6)
        expect(
          Dict.Foldable.fold_left(\"-", 10, Dict.unsafe_from_object({"a": 1, "b": 3, "c": 4})),
        ) |> to_be(2)
      },
    )
  )
  describe("Traversable", () => {
    module T = Dict.Traversable(Option.Applicative)
    it(
      "should sequence the dict",
      () => {
        expect(
          T.sequence(Dict.unsafe_from_object({"a": Some(123), "b": Some(456), "c": Some(789)})),
        ) |> to_be(Some(Dict.unsafe_from_object({"a": 123, "b": 456, "c": 789})))
        expect(
          T.sequence(Dict.unsafe_from_object({"a": Some(123), "b": None, "c": Some(789)})),
        ) |> to_be(None)
      },
    )
  })
})
